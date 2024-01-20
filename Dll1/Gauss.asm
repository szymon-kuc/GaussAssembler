.code
GaussEliminate proc
    ; Inicjalizacja stosu dla procedury
    push rbp                     ; zapisz bazowy wska�nik stosu
    mov rbp, rsp                 ; ustaw bazowy wska�nik stosu na szczycie stosu

    ; Przypisanie parametr�w do rejestr�w
    mov rsi, rcx                 ; rsi = wska�nik na macierz (double*)
    mov r9, rdx                  ; r9 = liczba wierszy
    mov r10, r8                  ; r10 = liczba kolumn (w��cznie z wyrazami wolnymi)

    ; Inicjalizacja zmiennej dla obecnego pivotu
    xor rax, rax                 ; zerowanie rejestru rax (bie��cy pivot)

    ; Pocz�tek g��wnej p�tli po pivotach
pivot_loop_start:
    cmp rax, r9                  ; por�wnaj indeks obecnego pivotu z liczb� wierszy
    jge end_gauss                ; je�li ju� przetworzono wszystkie pivoty, zako�cz

    ; Przygotowanie do przeszukania wiersza w poszukiwaniu pivotu
    mov r11, rax                 ; kopia indeksu obecnego pivotu do r11
    imul r11, r10                ; r11 *= liczba kolumn
    shl r11, 3                   ; r11 *= 8 (rozmiar double)
    lea r11, [rsi + r11]         ; obliczenie adresu obecnego pivotu w macierzy

    ; Szukanie niezerowego pivotu w bie��cym wierszu
    mov rcx, rax                 ; ustawienie licznika kolumn na indeks pivotu
    mov r12, r11                 ; kopia adresu obecnego pivotu do r12

find_pivot:
    cmp rcx, r10                 ; por�wnaj licznik kolumn z liczb� kolumn
    jge next_row                 ; je�li osi�gni�to koniec wiersza, przejd� do nast�pnego wiersza
    mov rax, [r12]               ; wczytaj warto�� kolumny do rax
    test rax, rax                ; sprawd�, czy warto�� jest niezerowa
    jne pivot_found              ; je�li niezerowa, pivot znaleziony
    add r12, 8                   ; przejd� do nast�pnej kolumny
    inc rcx                      ; inkrementuj licznik kolumn
    jmp find_pivot               ; kontynuuj szukanie pivotu

next_row:
    inc rax                      ; przejd� do nast�pnego wiersza
    jmp pivot_loop_start         ; kontynuuj g��wn� p�tl� po pivotach
pivot_found:
    cmp rax, rcx                 ; por�wnaj indeks obecnego pivotu z indeksem znalezionego
    je continue_with_pivot       ; je�li pivot jest ju� na swoim miejscu, kontynuuj

    ; Zamiana wierszy, je�li pivot nie jest na swoim miejscu
    mov r13, rcx                 ; kopia indeksu nowego wiersza pivotu do r13
    imul r13, r10                ; r13 *= liczba kolumn
    shl r13, 3                   ; r13 *= 8 (rozmiar double)
    lea r13, [rsi + r13]         ; obliczenie adresu nowego wiersza pivotu

    ; P�tla zamieniaj�ca wiersze
    mov r15, 0                   ; ustawienie licznika kolumn na 0
swap_rows_loop:
    cmp r15, r10
    jge continue_with_pivot      ; je�li przetworzono wszystkie kolumny, kontynuuj

    ; Obliczenie adresu elementu w bie��cym wierszu pivotu
    mov r14, rax
    imul r14, r10                ; r14 = indeks bie��cego wiersza * liczba kolumn
    lea r11, [rsi + r14 * 8]     ; r11 = adres elementu w bie��cym wierszu pivotu
    lea r11, [r11 + r15 * 8]     ; dodanie przesuni�cia dla bie��cej kolumny

    ; Obliczenie adresu elementu w wierszu z nowym pivotem
    mov r14, rcx
    imul r14, r10                ; r14 = indeks nowego wiersza * liczba kolumn
    lea r14, [rsi + r14 * 8]     ; r14 = adres elementu w nowym wierszu pivotu
    lea r14, [r14 + r15 * 8]     ; dodanie przesuni�cia dla bie��cej kolumny

    ; Zamiana element�w wierszy
    mov rax, [r11]               ; wczytaj warto�� z bie��cego wiersza do rax
    movq xmm0, rax               ; przenie� warto�� do rejestru xmm0
    mov rax, [r14]               ; wczytaj warto�� z nowego wiersza do rax
    movq xmm1, rax               ; przenie� warto�� do rejestru xmm1
    movq rax, xmm0               ; przenie� warto�� z xmm0 do rax
    mov [r14], rax               ; zapisz warto�� z rax do nowego wiersza
    movq rax, xmm1               ; przenie� warto�� z xmm1 do rax
    mov [r11], rax               ; zapisz warto�� z rax do bie��cego wiersza

    inc r15                      ; inkrementacja licznika kolumn
    jmp swap_rows_loop           ; powr�t do pocz�tku p�tli zamiany wierszy

continue_with_pivot:
    ; Kontynuacja z obecnym pivotem
    mov rax, [r11]               ; wczytanie warto�ci pivotu
    movq xmm1, rax               ; przeniesienie warto�ci pivotu do xmm1

    ; Aktualizacja wierszy poni�ej pivotu
    mov rdx, rax
    inc rdx                      ; przejd� do nast�pnego wiersza
row_loop_start:
    cmp rdx, r9
    jge pivot_loop_end           ; je�li przetworzono wszystkie wiersze, zako�cz

    ; Obliczanie mno�nika dla aktualizacji wiersza
    mov r14, rdx                 ; kopia indeksu wiersza do r14
    imul r14, r10                ; r14 *= liczba kolumn
    shl r14, 3                   ; r14 *= 8 (rozmiar double)
    lea r13, [rsi + r14]         ; r13 = adres pocz�tku wiersza poni�ej pivotu
    mov rax, [r13]               ; wczytaj warto�� z wiersza poni�ej pivotu do rax
    movq xmm2, rax               ; przenie� warto�� do xmm2
    divsd xmm2, xmm1             ; xmm2 = xmm2 / xmm1 (obliczenie mno�nika)

    ; P�tla aktualizuj�ca kolumny w wierszu
    mov rcx, 0
column_loop_start:
    lea r13, [r11 + rcx * 8] ; Oblicza adres elementu w macierzy (pivotowego wiersza) i zapisuje go w rejestrze r13
    lea r14, [r13 + rcx * 8] ; Oblicza adres kolejnego elementu w macierzy, zale�nego od wcze�niej obliczonego adresu w r13, i zapisuje go w r14
    cmp rcx, r10             ; Por�wnuje licznik p�tli (rcx) z ograniczeniem p�tli (r10)
    jge row_loop_end         ; Skacze do etykiety row_loop_end, je�li rcx jest wi�kszy lub r�wny r10

    lea r13, [r11 + rcx * 8] ; Ponownie oblicza adres elementu w pivotowym wierszu (by� mo�e do innego celu ni� wcze�niej)
    mov rax, [r13]           ; Wczytuje 64-bitow� warto�� z pami�ci pod adresem r13 i zapisuje j� w rejestrze rax
    movq xmm3, rax           ; Przenosi warto�� z rax do rejestru xmm3 (rejestru zmiennoprzecinkowego)
    mulsd xmm3, xmm2         ; Mno�y warto�� w xmm3 przez warto�� w xmm2 (operacja na liczbach zmiennoprzecinkowych)

    lea r14, [r13 + rcx * 8] ; Oblicza adres kolejnego elementu w wierszu
    mov rax, [r14]           ; Wczytuje 64-bitow� warto�� z pami�ci pod adresem r14 i zapisuje j� w rax
    movq xmm4, rax           ; Przenosi warto�� z rax do xmm4
    subsd xmm4, xmm3         ; Odejmuje warto�� w xmm3 od warto�ci w xmm4 (operacja na liczbach zmiennoprzecinkowych)

    movq rax, xmm4           ; Przenosi zmodyfikowan� warto�� z xmm4 z powrotem do rax
    mov [r14], rax           ; Zapisuje wynik z rax z powrotem do pami�ci pod adresem r14

    inc rcx                  ; Inkrementuje licznik p�tli rcx
    jmp column_loop_start    ; Skacze z powrotem na pocz�tek p�tli kolumnowej

row_loop_end:
    inc rdx                  ; Inkrementuje licznik p�tli rdx (prawdopodobnie odnosz�cy si� do wierszy)
    jmp row_loop_start       ; Skacze na pocz�tek p�tli wierszowej (nie zdefiniowanej w tym fragmencie kodu)

pivot_loop_end:
    inc rax                  ; Inkrementuje licznik p�tli rax (prawdopodobnie odnosz�cy si� do kolejnego pivotu)
    jmp pivot_loop_start     ; Skacze na pocz�tek p�tli pivotowej (nie zdefiniowanej w tym fragmencie kodu)

end_gauss:
    mov rsp, rbp             ; Przywraca oryginalny stos wska�nika stosu (rsp) z rejestru bazowego wska�nika (rbp)
    pop rbp                  ; Usuwa warto�� ze szczytu stosu i zapisuje j� w rbp
    ret                      ; Zwraca sterowanie do wywo�uj�cego
GaussEliminate endp
end 