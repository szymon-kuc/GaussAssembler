.code
GaussEliminate proc
    ; Inicjalizacja stosu dla procedury
    push rbp                     ; zapisz bazowy wskaŸnik stosu
    mov rbp, rsp                 ; ustaw bazowy wskaŸnik stosu na szczycie stosu

    ; Przypisanie parametrów do rejestrów
    mov rsi, rcx                 ; rsi = wskaŸnik na macierz (double*)
    mov r9, rdx                  ; r9 = liczba wierszy
    mov r10, r8                  ; r10 = liczba kolumn (w³¹cznie z wyrazami wolnymi)

    ; Inicjalizacja zmiennej dla obecnego pivotu
    xor rax, rax                 ; zerowanie rejestru rax (bie¿¹cy pivot)

    ; Pocz¹tek g³ównej pêtli po pivotach
pivot_loop_start:
    cmp rax, r9                  ; porównaj indeks obecnego pivotu z liczb¹ wierszy
    jge end_gauss                ; jeœli ju¿ przetworzono wszystkie pivoty, zakoñcz

    ; Przygotowanie do przeszukania wiersza w poszukiwaniu pivotu
    mov r11, rax                 ; kopia indeksu obecnego pivotu do r11
    imul r11, r10                ; r11 *= liczba kolumn
    shl r11, 3                   ; r11 *= 8 (rozmiar double)
    lea r11, [rsi + r11]         ; obliczenie adresu obecnego pivotu w macierzy

    ; Szukanie niezerowego pivotu w bie¿¹cym wierszu
    mov rcx, rax                 ; ustawienie licznika kolumn na indeks pivotu
    mov r12, r11                 ; kopia adresu obecnego pivotu do r12

find_pivot:
    cmp rcx, r10                 ; porównaj licznik kolumn z liczb¹ kolumn
    jge next_row                 ; jeœli osi¹gniêto koniec wiersza, przejdŸ do nastêpnego wiersza
    mov rax, [r12]               ; wczytaj wartoœæ kolumny do rax
    test rax, rax                ; sprawdŸ, czy wartoœæ jest niezerowa
    jne pivot_found              ; jeœli niezerowa, pivot znaleziony
    add r12, 8                   ; przejdŸ do nastêpnej kolumny
    inc rcx                      ; inkrementuj licznik kolumn
    jmp find_pivot               ; kontynuuj szukanie pivotu

next_row:
    inc rax                      ; przejdŸ do nastêpnego wiersza
    jmp pivot_loop_start         ; kontynuuj g³ówn¹ pêtlê po pivotach
pivot_found:
    cmp rax, rcx                 ; porównaj indeks obecnego pivotu z indeksem znalezionego
    je continue_with_pivot       ; jeœli pivot jest ju¿ na swoim miejscu, kontynuuj

    ; Zamiana wierszy, jeœli pivot nie jest na swoim miejscu
    mov r13, rcx                 ; kopia indeksu nowego wiersza pivotu do r13
    imul r13, r10                ; r13 *= liczba kolumn
    shl r13, 3                   ; r13 *= 8 (rozmiar double)
    lea r13, [rsi + r13]         ; obliczenie adresu nowego wiersza pivotu

    ; Pêtla zamieniaj¹ca wiersze
    mov r15, 0                   ; ustawienie licznika kolumn na 0
swap_rows_loop:
    cmp r15, r10
    jge continue_with_pivot      ; jeœli przetworzono wszystkie kolumny, kontynuuj

    ; Obliczenie adresu elementu w bie¿¹cym wierszu pivotu
    mov r14, rax
    imul r14, r10                ; r14 = indeks bie¿¹cego wiersza * liczba kolumn
    lea r11, [rsi + r14 * 8]     ; r11 = adres elementu w bie¿¹cym wierszu pivotu
    lea r11, [r11 + r15 * 8]     ; dodanie przesuniêcia dla bie¿¹cej kolumny

    ; Obliczenie adresu elementu w wierszu z nowym pivotem
    mov r14, rcx
    imul r14, r10                ; r14 = indeks nowego wiersza * liczba kolumn
    lea r14, [rsi + r14 * 8]     ; r14 = adres elementu w nowym wierszu pivotu
    lea r14, [r14 + r15 * 8]     ; dodanie przesuniêcia dla bie¿¹cej kolumny

    ; Zamiana elementów wierszy
    mov rax, [r11]               ; wczytaj wartoœæ z bie¿¹cego wiersza do rax
    movq xmm0, rax               ; przenieœ wartoœæ do rejestru xmm0
    mov rax, [r14]               ; wczytaj wartoœæ z nowego wiersza do rax
    movq xmm1, rax               ; przenieœ wartoœæ do rejestru xmm1
    movq rax, xmm0               ; przenieœ wartoœæ z xmm0 do rax
    mov [r14], rax               ; zapisz wartoœæ z rax do nowego wiersza
    movq rax, xmm1               ; przenieœ wartoœæ z xmm1 do rax
    mov [r11], rax               ; zapisz wartoœæ z rax do bie¿¹cego wiersza

    inc r15                      ; inkrementacja licznika kolumn
    jmp swap_rows_loop           ; powrót do pocz¹tku pêtli zamiany wierszy

continue_with_pivot:
    ; Kontynuacja z obecnym pivotem
    mov rax, [r11]               ; wczytanie wartoœci pivotu
    movq xmm1, rax               ; przeniesienie wartoœci pivotu do xmm1

    ; Aktualizacja wierszy poni¿ej pivotu
    mov rdx, rax
    inc rdx                      ; przejdŸ do nastêpnego wiersza
row_loop_start:
    cmp rdx, r9
    jge pivot_loop_end           ; jeœli przetworzono wszystkie wiersze, zakoñcz

    ; Obliczanie mno¿nika dla aktualizacji wiersza
    mov r14, rdx                 ; kopia indeksu wiersza do r14
    imul r14, r10                ; r14 *= liczba kolumn
    shl r14, 3                   ; r14 *= 8 (rozmiar double)
    lea r13, [rsi + r14]         ; r13 = adres pocz¹tku wiersza poni¿ej pivotu
    mov rax, [r13]               ; wczytaj wartoœæ z wiersza poni¿ej pivotu do rax
    movq xmm2, rax               ; przenieœ wartoœæ do xmm2
    divsd xmm2, xmm1             ; xmm2 = xmm2 / xmm1 (obliczenie mno¿nika)

    ; Pêtla aktualizuj¹ca kolumny w wierszu
    mov rcx, 0
column_loop_start:
    lea r13, [r11 + rcx * 8] ; Oblicza adres elementu w macierzy (pivotowego wiersza) i zapisuje go w rejestrze r13
    lea r14, [r13 + rcx * 8] ; Oblicza adres kolejnego elementu w macierzy, zale¿nego od wczeœniej obliczonego adresu w r13, i zapisuje go w r14
    cmp rcx, r10             ; Porównuje licznik pêtli (rcx) z ograniczeniem pêtli (r10)
    jge row_loop_end         ; Skacze do etykiety row_loop_end, jeœli rcx jest wiêkszy lub równy r10

    lea r13, [r11 + rcx * 8] ; Ponownie oblicza adres elementu w pivotowym wierszu (byæ mo¿e do innego celu ni¿ wczeœniej)
    mov rax, [r13]           ; Wczytuje 64-bitow¹ wartoœæ z pamiêci pod adresem r13 i zapisuje j¹ w rejestrze rax
    movq xmm3, rax           ; Przenosi wartoœæ z rax do rejestru xmm3 (rejestru zmiennoprzecinkowego)
    mulsd xmm3, xmm2         ; Mno¿y wartoœæ w xmm3 przez wartoœæ w xmm2 (operacja na liczbach zmiennoprzecinkowych)

    lea r14, [r13 + rcx * 8] ; Oblicza adres kolejnego elementu w wierszu
    mov rax, [r14]           ; Wczytuje 64-bitow¹ wartoœæ z pamiêci pod adresem r14 i zapisuje j¹ w rax
    movq xmm4, rax           ; Przenosi wartoœæ z rax do xmm4
    subsd xmm4, xmm3         ; Odejmuje wartoœæ w xmm3 od wartoœci w xmm4 (operacja na liczbach zmiennoprzecinkowych)

    movq rax, xmm4           ; Przenosi zmodyfikowan¹ wartoœæ z xmm4 z powrotem do rax
    mov [r14], rax           ; Zapisuje wynik z rax z powrotem do pamiêci pod adresem r14

    inc rcx                  ; Inkrementuje licznik pêtli rcx
    jmp column_loop_start    ; Skacze z powrotem na pocz¹tek pêtli kolumnowej

row_loop_end:
    inc rdx                  ; Inkrementuje licznik pêtli rdx (prawdopodobnie odnosz¹cy siê do wierszy)
    jmp row_loop_start       ; Skacze na pocz¹tek pêtli wierszowej (nie zdefiniowanej w tym fragmencie kodu)

pivot_loop_end:
    inc rax                  ; Inkrementuje licznik pêtli rax (prawdopodobnie odnosz¹cy siê do kolejnego pivotu)
    jmp pivot_loop_start     ; Skacze na pocz¹tek pêtli pivotowej (nie zdefiniowanej w tym fragmencie kodu)

end_gauss:
    mov rsp, rbp             ; Przywraca oryginalny stos wskaŸnika stosu (rsp) z rejestru bazowego wskaŸnika (rbp)
    pop rbp                  ; Usuwa wartoœæ ze szczytu stosu i zapisuje j¹ w rbp
    ret                      ; Zwraca sterowanie do wywo³uj¹cego
GaussEliminate endp
end 