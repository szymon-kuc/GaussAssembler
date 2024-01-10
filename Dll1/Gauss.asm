.code
section .text
global GaussEliminate

; GaussEliminate - Procedura eliminacji Gaussa dla macierzy
; Parametry:
;   rdi - wska�nik do macierzy (int[,])
; Zwracane warto�ci:
;   Brak (void)

GaussEliminate:
    push rbp
    mov rbp, rsp

    ; Pobierz adres macierzy do rsi
    mov rsi, rdi

    ; Zainicjuj zmienne
    xor ecx, ecx ; ecx - iteracja po pivotach
    xor edx, edx ; edx - warto�� wiersza
    xor eax, eax ; eax - warto�� kolumny
    xor ebx, ebx ; ebx - warto�� czynnika

outer_loop:
    cmp ecx, [rsi + 4] ; Por�wnaj ecx (iteracja po pivotach) z ilo�ci� wierszy - 1
    jge end_outer_loop ; Je�li ecx >= ilo�ci wierszy - 1, zako�cz p�tl� zewn�trzn�

    inc ecx ; Inkrementuj ecx (pivot)

    ; Ustaw warto�ci rejestr�w
    xor edx, edx ; Zeruj edx (warto�� wiersza)
    mov eax, ecx ; eax = ecx (pivot)

inner_loop:
    cmp edx, [rsi + 8] ; Por�wnaj edx (warto�� wiersza) z ilo�ci� wierszy
    jge end_inner_loop ; Je�li edx >= ilo�ci wierszy, zako�cz p�tl� wewn�trzn�

    inc edx ; Inkrementuj edx (warto�� wiersza)

    ; Oblicz czynnik
    mov ebx, dword [rsi + rdx*4 + eax*4] ; ebx = matrix[row, pivot]
    cdq ; Rozszerzenie znaku warto�ci w eax do edx (EDX:EAX = eax)
    idiv dword [rsi + rcx*4 + rcx*4] ; eax = ebx / matrix[pivot, pivot]

    ; Aktualizuj warto�ci macierzy
    imul ebx, eax ; ebx = eax * matrix[pivot, pivot]
    neg eax ; eax = -eax
    add eax, edx ; eax = row
    lea rdi, [rsi + rax*4 + rcx*4] ; Adres matrix[row, pivot]
    mov eax, ecx ; eax = pivot

    inc eax ; Inkrementuj eax (kolumna)
    mov edx, [rsi + 8] ; edx = rowCount

update_matrix_loop:
    cmp eax, edx ; Por�wnaj eax (kolumna) z ilo�ci� kolumn
    jge inner_loop ; Je�li eax >= ilo�ci kolumn, zako�cz p�tl� aktualizacji macierzy

    mov eax, [rsi + rdx*4 + rcx*4] ; eax = matrix[row, col]
    imul eax, ebx ; eax = ebx * matrix[row, col]
    sub dword [rdi], eax ; matrix[row, col] -= eax

    add rdi, 4 ; Przesu� wska�nik macierzy na kolejny element
    inc ecx ; Inkrementuj ecx (pivot)
    inc eax ; Inkrementuj eax (kolumna)
    jmp update_matrix_loop ; Powt�rz p�tl� aktualizacji macierzy

end_inner_loop:
    jmp outer_loop ; Powt�rz p�tl� zewn�trzn�

end_outer_loop:
    pop rbp
    ret

    end