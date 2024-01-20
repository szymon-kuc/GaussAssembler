.code
GaussEliminate proc
    ; Parametry:
    ; RCX - wska�nik na macierz (double*)
    ; RDX - liczba wierszy
    ; R8  - liczba kolumn (w��cznie z wyrazami wolnymi)

    push rbp
    mov rbp, rsp

    mov rsi, rcx  ; rsi - wska�nik na macierz
    mov r9, rdx   ; r9 - liczba wierszy
    mov r10, r8   ; r10 - liczba kolumn (w tym wyrazy wolne)

    xor rax, rax  ; rax - bie��cy pivot

pivot_loop_start:
    cmp rax, r9
    jge end_gauss ; Wyj�cie z p�tli, je�li wszystkie pivoty zosta�y przetworzone

     mov r11, rax       ; Skopiuj indeks pivotu do r11
    imul r11, r10      ; Pomn� przez liczb� kolumn
    shl r11, 3         ; Pomn� przez 8 (rozmiar double)
    lea r11, [rsi + r11] ; Dodaj wska�nik na macierz do przesuni�cia

    ; Przeszukiwanie wiersza w poszukiwaniu niezerowego pivotu
    mov rcx, rax
    mov r12, r11

find_pivot:
    cmp rcx, r10
    jge next_row
    mov rax, [r12]      ; Wczytaj warto�� z pami�ci
    test rax, rax       ; Sprawd�, czy warto�� jest niezerowa
    jne pivot_found     ; Skocz, je�li znaleziono niezerowy pivot
    add r12, 8          ; Przesu� do nast�pnej kolumny
    inc rcx
    jmp find_pivot

next_row:
    inc rax
    jmp pivot_loop_start
pivot_found:
     ; Znaleziono niezerowy pivot
    cmp rax, rcx
    je continue_with_pivot ; Je�li pivot jest ju� na swoim miejscu

    ; Zamiana wierszy, je�li pivot nie jest na swoim miejscu
    mov r13, rcx         ; Skopiuj indeks nowego wiersza pivotu do r13
    imul r13, r10        ; Pomn� przez liczb� kolumn
    shl r13, 3           ; Pomn� przez 8 (rozmiar double)
    lea r13, [rsi + r13] ; Dodaj wska�nik na macierz do przesuni�cia
    mov r15, 0
swap_rows_loop:
    cmp r15, r10
    jge continue_with_pivot
    ; Obliczenie adresu elementu w bie��cym wierszu pivotu
    mov r14, rax
    imul r14, r10      ; r14 = rax * r10
    lea r11, [rsi + r14 * 8] ; r11 = adres elementu w bie��cym wierszu pivotu
    lea r11, [r11 + r15 * 8] ; Dodanie przesuni�cia dla kolumny

    ; Obliczenie adresu elementu w wierszu z nowym pivotem
    mov r14, rcx
    imul r14, r10      ; r14 = rcx * r10
    lea r14, [rsi + r14 * 8] ; r14 = adres elementu w wierszu z nowym pivotem
    lea r14, [r14 + r15 * 8] ; Dodanie przesuni�cia dla kolumny

    ; Zamiana element�w
    mov rax, [r11]         ; Wczytaj 64-bitow� warto�� z pami�ci do rax
    movq xmm0, rax         ; Przenie� warto�� z rax do xmm0
    mov rax, [r14]         ; Wczytaj 64-bitow� warto�� z pami�ci do rax
    movq xmm1, rax         ; Przenie� warto�� z rax do xmm1
    movq rax, xmm0         ; Przenie� warto�� z xmm0 do rax
    mov [r14], rax         ; Zapisz 64-bitow� warto�� z rax do pami�ci
    movq rax, xmm1         ; Przenie� warto�� z xmm1 do rax
    mov [r11], rax         ; Zapisz 64-bitow� warto�� z rax do pami�ci

    inc r15
    jmp swap_rows_loop

continue_with_pivot:
    mov rax, [r11]  ; �adowanie warto�ci pivotu
    movq xmm1, rax  ; Przeniesienie warto�ci pivotu do xmm1

    ; Aktualizacja wierszy poni�ej pivotu
    mov rdx, rax
    inc rdx
row_loop_start:
    cmp rdx, r9
    jge pivot_loop_end

  ; Obliczanie mno�nika
    mov r14, rdx           ; Skopiuj rdx do r14
    imul r14, r10          ; r14 = rdx * r10
    shl r14, 3             ; r14 = r14 * 8 (przeskaluj do rozmiaru double)
    lea r13, [rsi + r14]   ; r13 = adres pocz�tku wiersza poni�ej pivotu
    mov rax, [r13]                 ; Wczytaj 64-bitow� warto�� z pami�ci do rax
    movq xmm2, rax                 ; Przenie� warto�� z rax do xmm2
    divsd xmm2, xmm1               ; xmm2 = xmm2 / xmm1 (mno�nik)

    ; Aktualizacja wiersza
    mov rcx, 0
column_loop_start:
    lea r13, [r11 + rcx * 8] ; Sprawd�, czy r13 jest prawid�owym adresem
    lea r14, [r13 + rcx * 8] ; Sprawd�, czy r14 jest prawid�owym adresem
    cmp rcx, r10
    jge row_loop_end

    lea r13, [r11 + rcx * 8] ; Obliczanie adresu elementu w pivotowym wierszu
    mov rax, [r13]           ; Wczytaj 64-bitow� warto�� z pami�ci do rax
    movq xmm3, rax           ; Przenie� warto�� z rax do xmm3
    mulsd xmm3, xmm2         ; xmm3 *= xmm2 (mno�nik)

    lea r14, [r13 + rcx * 8] ; Obliczanie adresu aktualnego elementu w wierszu
    mov rax, [r14]           ; Wczytaj 64-bitow� warto�� z pami�ci do rax
    movq xmm4, rax           ; Przenie� warto�� z rax do xmm4
    subsd xmm4, xmm3         ; xmm4 -= xmm3

    movq rax, xmm4           ; Przenie� zmodyfikowan� warto�� z xmm4 do rax
    mov [r14], rax           ; Zapisz wynik z rax do pami�ci

    inc rcx
    jmp column_loop_start

row_loop_end:
    inc rdx
    jmp row_loop_start

pivot_loop_end:
    inc rax
    jmp pivot_loop_start

end_gauss:
    mov rsp, rbp
    pop rbp
    ret
GaussEliminate endp
end