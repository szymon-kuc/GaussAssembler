.code

; Eksport funkcji GaussEliminate
GaussEliminate proc
    ; Parametry:
    ; RCX - wska�nik na macierz 3x3 (int*)

    push rbp
    mov rbp, rsp
    sub rsp, 20h ; Alokacja miejsca na stosie dla zmiennych lokalnych

    mov rsi, rcx ; rsi - wska�nik na macierz

    ; Eliminacja Gaussa dla pierwszego pivotu (element [0][0])
    mov eax, [rsi+4*3]   ; Wczytaj element [1][0]
    mov ebx, [rsi]       ; Wczytaj pivot [0][0] do ebx
    cdq                  ; Rozszerz eax do edx:eax
    idiv ebx             ; Dzieli edx:eax przez ebx, eax = mno�nik dla drugiego wiersza
    mov ebx, eax         ; Zapisz mno�nik w ebx

    ; Aktualizuj drugi wiersz
    mov edx, [rsi+4*4]  ; Wczytaj [1][1]
    imul edx, ebx       ; Pomn� [1][1] przez mno�nik
    sub [rsi+4*4], edx  ; Aktualizuj [1][1] przez odejmowanie
    mov edx, [rsi+4*5]  ; Wczytaj [1][2]
    imul edx, ebx       ; Pomn� [1][2] przez mno�nik
    sub [rsi+4*5], edx  ; Aktualizuj [1][2] przez odejmowanie

   ; Przygotuj do aktualizacji trzeciego wiersza
mov eax, [rsi+4*6]  ; Wczytaj [2][0]
mov ebx, [rsi]      ; Wczytaj pivot [0][0] do ebx
cdq                 ; Rozszerz eax do edx:eax
idiv ebx            ; Dzieli edx:eax przez ebx, eax = mno�nik dla trzeciego wiersza
mov ebx, eax        ; Zapisz mno�nik w ebx

; Aktualizuj trzeci wiersz
mov eax, [rsi+4*7]  ; Wczytaj [2][1]
imul eax, ebx       ; Pomn� [2][1] przez mno�nik
sub [rsi+4*7], eax  ; Aktualizuj [2][1] przez odejmowanie
mov eax, [rsi+4*8]  ; Wczytaj [2][2]
imul eax, ebx       ; Pomn� [2][2] przez mno�nik
sub [rsi+4*8], eax  ; Aktualizuj [2][2] przez odejmowanie

    ; Przywr�cenie oryginalnego stosu
    mov rsp, rbp
    pop rbp
    ret
GaussEliminate endp
end
