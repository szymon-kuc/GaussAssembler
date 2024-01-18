.code
GaussEliminate proc
    ; Parameters:
    ; RCX - pointer to the matrix (int*)
    ; RDX - number of columns
    ; R8  - number of rows

    push rbp
    mov rbp, rsp
    sub rsp, 20h ; Allocate space on the stack for local variables (32 bytes)

    mov rsi, rcx ; rsi - pointer to the matrix

    ; Iteration through columns
    mov r9, rdx   ; r9 = number of columns
    mov r10, r8   ; r10 = number of rows

    mov r11, 0    ; r11 = index of the current column

next_column:

    ; Iteration through rows below the current column
    mov r12, r11    ; r12 = index of the current row
    inc r12          ; Skip the current column

next_row:

    ; Load element [r12][r11]
    mov rcx, r12
    imul rcx, r9
    add rcx, r11
    mov rax, [rsi + 4 * rcx]

    ; Load pivot [r11][r11]
    mov rcx, r11
    imul rcx, r9
    add rcx, r11
    mov rbx, [rsi + 4 * rcx]

    ; Check for division by zero
    test rbx, rbx
    jz division_by_zero

    cdq                  ; Extend eax to edx:eax
    idiv rbx             ; Divide edx:eax by rbx, eax = multiplier

    ; Iteration through the remaining columns
    mov r13, r11        ; r13 = index of the column to update
    inc r13             ; Skip the current column

update_column:

    ; Load element [r12][r13]
    mov rcx, r12
    imul rcx, r9
    add rcx, r13
    mov ecx, [rsi + 4 * rcx]

    ; Multiply by the multiplier
    imul ecx, eax

    ; Load the original element [r11][r13]
    mov rcx, r11
    imul rcx, r9
    add rcx, r13
    mov edx, [rsi + 4 * rcx]

    ; Update element [r12][r13]
    sub edx, ecx
    mov rcx, r12
    imul rcx, r9
    add rcx, r13
    mov [rsi + 4 * rcx], edx

    inc r13
    cmp r13, r9
    jl update_column

    ; Move to the next row
    inc r12
    cmp r12, r10
    jl next_row

; Move to the next column
inc r11
cmp r11, r9
jl next_column

division_by_zero:
; Handle division by zero error if needed

; Restore the original stack
mov rsp, rbp
pop rbp
ret
GaussEliminate endp
end