.code
GaussEliminate proc
    ; Parametry:
    ; RCX - wskaŸnik na macierz (double*)
    ; RDX - liczba wierszy
    ; R8  - liczba kolumn (w³¹cznie z wyrazami wolnymi)

    push rbp
    mov rbp, rsp

    mov rsi, rcx  ; rsi - wskaŸnik na macierz
    mov r9, rdx   ; r9 - liczba wierszy
    mov r10, r8   ; r10 - liczba kolumn (w tym wyrazy wolne)

    xor rax, rax  ; rax - bie¿¹cy pivot

pivot_loop_start:
    cmp rax, r9
    jge end_gauss ; Wyjœcie z pêtli, jeœli wszystkie pivoty zosta³y przetworzone

     mov r11, rax       ; Skopiuj indeks pivotu do r11
    imul r11, r10      ; Pomnó¿ przez liczbê kolumn
    shl r11, 3         ; Pomnó¿ przez 8 (rozmiar double)
    lea r11, [rsi + r11] ; Dodaj wskaŸnik na macierz do przesuniêcia

    ; Przeszukiwanie wiersza w poszukiwaniu niezerowego pivotu
    mov rcx, rax
    mov r12, r11

find_pivot:
    cmp rcx, r10
    jge next_row
    mov rax, [r12]      ; Wczytaj wartoœæ z pamiêci
    test rax, rax       ; SprawdŸ, czy wartoœæ jest niezerowa
    jne pivot_found     ; Skocz, jeœli znaleziono niezerowy pivot
    add r12, 8          ; Przesuñ do nastêpnej kolumny
    inc rcx
    jmp find_pivot

next_row:
    inc rax
    jmp pivot_loop_start
pivot_found:
     ; Znaleziono niezerowy pivot
    cmp rax, rcx
    je continue_with_pivot ; Jeœli pivot jest ju¿ na swoim miejscu

    ; Zamiana wierszy, jeœli pivot nie jest na swoim miejscu
    mov r13, rcx         ; Skopiuj indeks nowego wiersza pivotu do r13
    imul r13, r10        ; Pomnó¿ przez liczbê kolumn
    shl r13, 3           ; Pomnó¿ przez 8 (rozmiar double)
    lea r13, [rsi + r13] ; Dodaj wskaŸnik na macierz do przesuniêcia
    mov r15, 0
swap_rows_loop:
    cmp r15, r10
    jge continue_with_pivot
    ; Obliczenie adresu elementu w bie¿¹cym wierszu pivotu
    mov r14, rax
    imul r14, r10      ; r14 = rax * r10
    lea r11, [rsi + r14 * 8] ; r11 = adres elementu w bie¿¹cym wierszu pivotu
    lea r11, [r11 + r15 * 8] ; Dodanie przesuniêcia dla kolumny

    ; Obliczenie adresu elementu w wierszu z nowym pivotem
    mov r14, rcx
    imul r14, r10      ; r14 = rcx * r10
    lea r14, [rsi + r14 * 8] ; r14 = adres elementu w wierszu z nowym pivotem
    lea r14, [r14 + r15 * 8] ; Dodanie przesuniêcia dla kolumny

    ; Zamiana elementów
    mov rax, [r11]         ; Wczytaj 64-bitow¹ wartoœæ z pamiêci do rax
    movq xmm0, rax         ; Przenieœ wartoœæ z rax do xmm0
    mov rax, [r14]         ; Wczytaj 64-bitow¹ wartoœæ z pamiêci do rax
    movq xmm1, rax         ; Przenieœ wartoœæ z rax do xmm1
    movq rax, xmm0         ; Przenieœ wartoœæ z xmm0 do rax
    mov [r14], rax         ; Zapisz 64-bitow¹ wartoœæ z rax do pamiêci
    movq rax, xmm1         ; Przenieœ wartoœæ z xmm1 do rax
    mov [r11], rax         ; Zapisz 64-bitow¹ wartoœæ z rax do pamiêci

    inc r15
    jmp swap_rows_loop

continue_with_pivot:
    mov rax, [r11]  ; £adowanie wartoœci pivotu
    movq xmm1, rax  ; Przeniesienie wartoœci pivotu do xmm1

    ; Aktualizacja wierszy poni¿ej pivotu
    mov rdx, rax
    inc rdx
row_loop_start:
    cmp rdx, r9
    jge pivot_loop_end

  ; Obliczanie mno¿nika
    mov r14, rdx           ; Skopiuj rdx do r14
    imul r14, r10          ; r14 = rdx * r10
    shl r14, 3             ; r14 = r14 * 8 (przeskaluj do rozmiaru double)
    lea r13, [rsi + r14]   ; r13 = adres pocz¹tku wiersza poni¿ej pivotu
    mov rax, [r13]                 ; Wczytaj 64-bitow¹ wartoœæ z pamiêci do rax
    movq xmm2, rax                 ; Przenieœ wartoœæ z rax do xmm2
    divsd xmm2, xmm1               ; xmm2 = xmm2 / xmm1 (mno¿nik)

    ; Aktualizacja wiersza
    mov rcx, 0
column_loop_start:
    lea r13, [r11 + rcx * 8] ; SprawdŸ, czy r13 jest prawid³owym adresem
    lea r14, [r13 + rcx * 8] ; SprawdŸ, czy r14 jest prawid³owym adresem
    cmp rcx, r10
    jge row_loop_end

    lea r13, [r11 + rcx * 8] ; Obliczanie adresu elementu w pivotowym wierszu
    mov rax, [r13]           ; Wczytaj 64-bitow¹ wartoœæ z pamiêci do rax
    movq xmm3, rax           ; Przenieœ wartoœæ z rax do xmm3
    mulsd xmm3, xmm2         ; xmm3 *= xmm2 (mno¿nik)

    lea r14, [r13 + rcx * 8] ; Obliczanie adresu aktualnego elementu w wierszu
    mov rax, [r14]           ; Wczytaj 64-bitow¹ wartoœæ z pamiêci do rax
    movq xmm4, rax           ; Przenieœ wartoœæ z rax do xmm4
    subsd xmm4, xmm3         ; xmm4 -= xmm3

    movq rax, xmm4           ; Przenieœ zmodyfikowan¹ wartoœæ z xmm4 do rax
    mov [r14], rax           ; Zapisz wynik z rax do pamiêci

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