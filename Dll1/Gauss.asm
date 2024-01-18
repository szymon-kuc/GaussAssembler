.code

GaussEliminate proc
    ; Parametry:
    ; RCX - wskaŸnik na macierz 3x3 (int*)

    push rbp
    mov rbp, rsp
    sub rsp, 20h ; Alokacja miejsca na stosie dla zmiennych lokalnych

    mov rsi, rcx ; rsi - wskaŸnik na macierz

    ; Pierwszy krok eliminacji Gaussa (pierwszy pivot)
    ; Eliminacja elementów w kolumnie poni¿ej pierwszego pivotu
    mov eax, [rsi+4*3]   ; Wczytaj element [1][0]
    mov ebx, [rsi]       ; Wczytaj pivot [0][0] do ebx
    cdq                  ; Rozszerz eax do edx:eax
    idiv ebx             ; Dzieli edx:eax przez ebx, eax = mno¿nik dla drugiego wiersza 

    ; Teraz wykonaj operacjê eax = eax - (eax * ebx)
    ;imul ebx            ; Pomnó¿ eax przez ebx, wynik w eax
    ;neg eax             ; Neguj eax, aby zamieniæ wynik mno¿enia na wartoœæ ujemn¹
    ;add eax, [rsi+4*3]  ; Dodaj oryginalny element [1][0] do eax (który teraz zawiera -eax*ebx)

    ; Aktualizuj drugi wiersz
    mov ebx, eax         ; Zapisz mno¿nik w ebx
    mov ecx, [rsi+4]     ; Wczytaj element [0][1]
    imul ecx, ebx        ; Pomnó¿ przez mno¿nik
    mov edx, [rsi+4*4]   ; Wczytaj [1][1] 
    sub edx, ecx         ; Aktualizuj [1][1]
    mov [rsi+4*4], edx   ; Zapisz now¹ wartoœæ [1][1]
    mov ecx, [rsi+8]     ; Wczytaj element [0][2]
    imul ecx, ebx        ; Pomnó¿ przez mno¿nik
    mov edx, [rsi+4*5]   ; Wczytaj [1][2]
    sub edx, ecx         ; Aktualizuj [1][2]
    mov [rsi+4*5], edx   ; Zapisz now¹ wartoœæ [1][2]

    ; Aktualizuj trzeci wiersz
    mov eax, [rsi+4*6]   ; Wczytaj [2][0]
    mov ebx, [rsi]       ; Wczytaj pivot [0][0] do ebx
    cdq                  ; Rozszerz eax do edx:eax
    idiv ebx             ; Dzieli edx:eax przez ebx, eax = mno¿nik dla trzeciego wiersza
    mov ebx, eax         ; Zapisz mno¿nik w ebx
    mov ecx, [rsi+4]     ; Wczytaj element [0][1]
    imul ecx, ebx        ; Pomnó¿ przez mno¿nik
    mov edx, [rsi+4*7]   ; Wczytaj [2][1]
    sub edx, ecx         ; Aktualizuj [2][1]
    mov [rsi+4*7], edx   ; Zapisz now¹ wartoœæ [2][1]
    mov ecx, [rsi+8]     ; Wczytaj element [0][2]
    imul ecx, ebx        ; Pomnó¿ przez mno¿nik
    mov edx, [rsi+4*8]   ; Wczytaj [2][2]
    sub edx, ecx         ; Aktualizuj [2][2]
    mov [rsi+4*8], edx   ; Zapisz now¹ wartoœæ [2][2]

    ; Drugi krok eliminacji Gaussa (drugi pivot)
    mov eax, [rsi+4*7]   ; Wczytaj element [2][1] (ju¿ zmodyfikowany)
    mov ebx, [rsi+4*4]   ; Wczytaj pivot [1][1] do ebx
    cdq                  ; Rozszerz eax do edx:eax
    idiv ebx             ; Dzieli edx:eax przez ebx, eax = mno¿nik dla trzeciego wiersza
    mov ebx, eax         ; Zapisz mno¿nik w ebx
    mov ecx, [rsi+4*5]   ; Wczytaj element [1][2]
    imul ecx, ebx        ; Pomnó¿ przez mno¿nik
    mov edx, [rsi+4*8]   ; Wczytaj [2][2]
    sub edx, ecx         ; Aktualizuj [2][2]
    mov [rsi+4*8], edx   ; Zapisz now¹ wartoœæ [2][2]

    ; Przywrócenie oryginalnego stosu
    mov rsp, rbp
    pop rbp
    ret
GaussEliminate endp
end
