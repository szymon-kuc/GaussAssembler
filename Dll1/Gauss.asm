.code
section .text
global GaussEliminate

; GaussEliminate - Procedura eliminacji Gaussa dla macierzy
; Parametry:
;   rdi - wskaŸnik do macierzy (int[,])
; Zwracane wartoœci:
;   Brak (void)

GaussEliminate:
    push rbp
    mov rbp, rsp

    ; Pobierz adres macierzy do rsi
    mov rsi, rdi

    ; Zainicjuj zmienne
    xor ecx, ecx ; ecx - iteracja po pivotach
    xor edx, edx ; edx - wartoœæ wiersza
    xor eax, eax ; eax - wartoœæ kolumny
    xor ebx, ebx ; ebx - wartoœæ czynnika

outer_loop:
    cmp ecx, [rsi + 4] ; Porównaj ecx (iteracja po pivotach) z iloœci¹ wierszy - 1
    jge end_outer_loop ; Jeœli ecx >= iloœci wierszy - 1, zakoñcz pêtlê zewnêtrzn¹

    inc ecx ; Inkrementuj ecx (pivot)

    ; Ustaw wartoœci rejestrów
    xor edx, edx ; Zeruj edx (wartoœæ wiersza)
    mov eax, ecx ; eax = ecx (pivot)

inner_loop:
    cmp edx, [rsi + 8] ; Porównaj edx (wartoœæ wiersza) z iloœci¹ wierszy
    jge end_inner_loop ; Jeœli edx >= iloœci wierszy, zakoñcz pêtlê wewnêtrzn¹

    inc edx ; Inkrementuj edx (wartoœæ wiersza)

    ; Oblicz czynnik
    mov ebx, dword [rsi + rdx*4 + eax*4] ; ebx = matrix[row, pivot]
    cdq ; Rozszerzenie znaku wartoœci w eax do edx (EDX:EAX = eax)
    idiv dword [rsi + rcx*4 + rcx*4] ; eax = ebx / matrix[pivot, pivot]

    ; Aktualizuj wartoœci macierzy
    imul ebx, eax ; ebx = eax * matrix[pivot, pivot]
    neg eax ; eax = -eax
    add eax, edx ; eax = row
    lea rdi, [rsi + rax*4 + rcx*4] ; Adres matrix[row, pivot]
    mov eax, ecx ; eax = pivot

    inc eax ; Inkrementuj eax (kolumna)
    mov edx, [rsi + 8] ; edx = rowCount

update_matrix_loop:
    cmp eax, edx ; Porównaj eax (kolumna) z iloœci¹ kolumn
    jge inner_loop ; Jeœli eax >= iloœci kolumn, zakoñcz pêtlê aktualizacji macierzy

    mov eax, [rsi + rdx*4 + rcx*4] ; eax = matrix[row, col]
    imul eax, ebx ; eax = ebx * matrix[row, col]
    sub dword [rdi], eax ; matrix[row, col] -= eax

    add rdi, 4 ; Przesuñ wskaŸnik macierzy na kolejny element
    inc ecx ; Inkrementuj ecx (pivot)
    inc eax ; Inkrementuj eax (kolumna)
    jmp update_matrix_loop ; Powtórz pêtlê aktualizacji macierzy

end_inner_loop:
    jmp outer_loop ; Powtórz pêtlê zewnêtrzn¹

end_outer_loop:
    pop rbp
    ret

    end