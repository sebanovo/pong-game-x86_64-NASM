bits 64
default rel

%include "colors.asm"
%include "keys.asm"
%include "state_game.asm"

; std
extern printf
; raylib
global main
extern InitWindow
extern SetTargetFPS
extern WindowShouldClose
extern BeginDrawing
extern ClearBackground
extern EndDrawing
extern CloseWindow
extern DrawCircle
extern DrawRectangle
extern IsKeyDown
extern DrawLine
extern DrawCircleLines
extern TextFormat
extern DrawText
extern DrawRectangleRounded
extern DrawCircleV
extern CheckCollisionCircleRec

section .data
    ; window 
    window_title db "Ping Pong Game", 0
    screen_width equ 1000 
    screen_height equ 650
    ; x_off_set equ 50
    radius_center_circle dd 50.0
    font_size equ 50
    max_score dd 50
    game_state db ONGOING

    ; ball 
    ball_radius dd 10.0
    ball_x dd 500.0 ; screen_width / 2
    ball_y dd 325.0 ; screen_height / 2

    ; ball_speed equ 10
    ball_speed_x dd 10.0 ; ball_speed
    ball_speed_y dd 10.0 ; ball_speed

    ; paddle 
    paddle_width dd 20.0
    paddle_height dd 100.0 
    paddle_speed_y_axis dd 10.0

    ; player1 
    player1_x dd 50.0
    player1_y dd 333.3333333333 ; screen_width / 3 
    player1_score dd 0

    ; player2
    player2_x dd 960.0 ; screen_width - x_off_set - paddle_width
    player2_y dd 333.3333333333 ; screen_width / 3 
    player2_score dd 0

section .rdata
    neg_mask dd 0x80000000 
    pos_mask dd 0x7FFFFFFF
    const_2 dd 2.0  
    const_0_1  dd 0.1
    score_format db "%u",0
    msg_player1_win db "Player 1 wins!", 10, 0
    msg_player2_win db "Player 2 wins!", 10,0
    msg_end_game db "FIN DEL JUEGO!", 10, 0

section .text
    global main

main:
    push rbp
    mov rbp, rsp

    sub rsp, 32
    mov rcx, screen_width
    mov rdx, screen_height
    mov r8, window_title
    call InitWindow
    add rsp, 32 

    sub rsp, 32
    mov rcx, 60
    call SetTargetFPS
    add rsp, 32

main_loop:
    sub rsp, 32
    call WindowShouldClose
    add rsp, 32
    test eax, eax
    jnz end_game

    mov al, [game_state]
    cmp al, ONGOING 
    jnz end_game

    sub rsp, 32
    call BeginDrawing
    add rsp, 32

    sub rsp, 32
    mov rcx, BLACK   
    call ClearBackground
    add rsp, 32

draw_halfway_line:
    sub rsp, 32 + 16
    mov ecx, screen_width / 2 
    mov edx, 0 
    mov r8d, screen_width / 2 
    mov r9d, screen_height 
    mov eax, WHITE 
    mov dword [rsp+32], eax
    call DrawLine 
    add rsp, 32 + 16


draw_score:
    sub rsp, 32
    mov ecx, score_format
    mov edx, [player1_score]
    call TextFormat
    add rsp, 32

    sub rsp, 32 + 16
    mov rcx, rax
    mov edx, screen_width / 4
    mov r8d, 10
    mov dword [rsp+32], RAYWHITE
    mov r9d, font_size 
    call DrawText
    add rsp, 32 + 16

    sub rsp, 32
    mov ecx, score_format
    mov edx, [player2_score]
    call TextFormat
    add rsp, 32

    sub rsp, 32 + 16
    mov rcx, rax
    mov edx, 3 * screen_width / 4
    mov r8d, 10
    mov dword [rsp+32], RAYWHITE
    mov r9d, font_size 
    call DrawText
    add rsp, 32 + 16

draw_centre_circle:
    sub rsp, 32
    mov ecx, screen_width / 2
    mov edx, screen_height / 2
    movss xmm2, dword[radius_center_circle]
    mov r9d, WHITE
    call DrawCircleLines
    add rsp, 32

draw_ball:
    sub rsp, 32
    movss xmm0, dword[ball_x]
    movss -8[rbp], xmm0
    movss xmm0, dword[ball_y]
    movss -4[rbp], xmm0
    mov rcx, -8[rbp]
    movss xmm1, dword[ball_radius]
    mov r8d, WHITE 
    call DrawCircleV
    add rsp, 32 

draw_paddles: 
    ; draw player 1
    sub rsp, 64
    movss xmm0, dword[player1_x]
    movss -16[rbp], xmm0
    movss xmm0, dword[player1_y]
    movss -12[rbp], xmm0
    movss xmm0, dword[paddle_width]
    movss -8[rbp], xmm0
    movss xmm0, dword[paddle_height]
    movss -4[rbp], xmm0
    mov rax, -16[rbp]
    mov rdx, -8[rbp]
    mov -32[rbp], rax
    mov -24[rbp], rdx
    lea rax, -32[rbp]
    mov rcx, rax
    movss xmm1, dword[ball_radius]
    mov r8d, 0
    mov r9d, WHITE
    call DrawRectangleRounded
    add rsp, 64

    ; draw player 2
    sub rsp, 64
    movss xmm0, dword[player2_x]
    movss -16[rbp], xmm0
    movss xmm0, dword[player2_y]
    movss -12[rbp], xmm0
    movss xmm0, dword[paddle_width]
    movss -8[rbp], xmm0
    movss xmm0, dword[paddle_height]
    movss -4[rbp], xmm0
    mov rax, -16[rbp]
    mov rdx, -8[rbp]
    mov -32[rbp], rax
    mov -24[rbp], rdx
    lea rax, -32[rbp]
    mov rcx, rax
    movss xmm1, dword[ball_radius]
    mov r8d, 0
    mov r9d, WHITE
    call DrawRectangleRounded
    add rsp, 64

mov_player1_KEY_W:
    sub rsp, 32
    mov rcx, KEY_W
    call IsKeyDown
    add rsp, 32
    cmp rax, 0 
    je  continue1
    
    movss xmm0, dword[player1_y]
    pxor    xmm1, xmm1
    comiss  xmm0, xmm1
    jbe     continue1

    movss xmm0, dword[player1_y]
    subss xmm0, dword [paddle_speed_y_axis]
    movss dword[player1_y], xmm0
    continue1:

mov_player1_KEY_S:
    sub rsp, 32
    mov rcx, KEY_S
    call IsKeyDown
    add rsp, 32
    cmp rax, 0 
    je  continue2

    mov eax, screen_height 
    cvtsi2ss xmm0, eax   
    subss   xmm0, dword[paddle_height]
    comiss  xmm0, dword[player1_y] 
    jbe     continue2

    movss xmm0, dword[player1_y]
    addss xmm0, dword [paddle_speed_y_axis]
    movss dword[player1_y], xmm0
    continue2:

mov_player2_KEY_UP:
    sub rsp, 32
    mov rcx, KEY_UP
    call IsKeyDown
    add rsp, 32
    cmp rax, 0 
    je  continue3
    
    movss xmm0, dword[player2_y]
    pxor    xmm1, xmm1
    comiss  xmm0, xmm1
    jbe     continue3

    movss xmm0, dword[player2_y]
    subss xmm0, dword [paddle_speed_y_axis]
    movss dword[player2_y], xmm0
    continue3:

mov_player2_KEY_DOWN:
    sub rsp, 32
    mov rcx, KEY_DOWN
    call IsKeyDown
    add rsp, 32
    cmp rax, 0 
    je  continue4

    mov eax, screen_height 
    cvtsi2ss xmm0, eax   
    subss   xmm0, dword[paddle_height]
    comiss  xmm0, dword[player2_y] 
    jbe     continue4

    movss xmm0, dword[player2_y]
    addss xmm0, dword [paddle_speed_y_axis]
    movss dword[player2_y], xmm0
    continue4:

check_boundary_collision:
    L1:
    movss   xmm0, [ball_x]
    addss   xmm0, dword[ball_radius]
    mov eax, screen_width
    cvtsi2ss xmm1, eax 
    comiss  xmm0, xmm1 
    jbe L2

    mov eax, 2
    cvtsi2ss xmm1, eax ; 2
    mov ebx, screen_width
    cvtsi2ss xmm0, ebx
    divss   xmm0, xmm1
    movss dword[ball_x], xmm0

    mov ebx, screen_height 
    cvtsi2ss xmm0, ebx
    divss   xmm0, xmm1
    movss dword[ball_y], xmm0

    movss xmm0, dword[ball_speed_x]
    movd xmm1, dword [neg_mask] 
    xorps   xmm0, xmm1
    movss [ball_speed_x], xmm0
    inc dword[player1_score]
    jmp  exit_check_boundary_collision

    L2:
    movss   xmm0, dword[ball_x]
    movaps  xmm1, xmm0
    subss   xmm1, dword[ball_radius] 
    pxor    xmm0, xmm0
    comiss  xmm0, xmm1
    jbe     L3

    mov eax, 2
    cvtsi2ss xmm1, eax ; 2
    mov ebx, screen_width
    cvtsi2ss xmm0, ebx
    divss   xmm0, xmm1
    movss dword[ball_x], xmm0

    mov ebx, screen_height 
    cvtsi2ss xmm0, ebx
    divss   xmm0, xmm1
    movss dword[ball_y], xmm0

    movss xmm0, dword[ball_speed_x]
    movd xmm1, dword [neg_mask] 
    xorps   xmm0, xmm1
    movss [ball_speed_x], xmm0
    inc dword[player2_score]
    jmp  exit_check_boundary_collision

    L3:
    movss   xmm0, dword[ball_y]
    addss   xmm0, dword[ball_radius] 
    mov eax, screen_height
    cvtsi2ss xmm1, eax
    comiss  xmm0, xmm1 
    ja      L7
    movss   xmm0, dword[ball_y] 
    movaps  xmm1, xmm0
    subss   xmm1, dword[ball_radius] 
    pxor    xmm0, xmm0
    comiss  xmm0, xmm1
    jbe     L4

    L7:
    movss xmm0, dword[ball_speed_y]
    movd xmm1, dword [neg_mask] 
    xorps   xmm0, xmm1
    movss [ball_speed_y], xmm0

    L4: 
    exit_check_boundary_collision:

move_ball:
    movss xmm0, dword[ball_x]
    addss xmm0, dword[ball_speed_x] 
    movss dword[ball_x] ,xmm0
    movss xmm0, dword[ball_y]
    addss xmm0, dword[ball_speed_y] 
    movss dword[ball_y] ,xmm0

check_collision_between_ball_and_paddles:
    if_for_player1:
    sub rsp, 80
    movss   xmm0, dword[ball_x] 
    movss    -12[rbp], xmm0
    movss   xmm0, dword[ball_y] 
    movss   -8[rbp], xmm0
    movss   xmm0, dword[ball_radius] 
    movss   -4[rbp], xmm0

    movss   xmm0, dword[player1_x] 
    movss   -32[rbp], xmm0
    movss   xmm0, dword[player1_y] 
    movss   -28[rbp], xmm0
    movss   xmm0, dword[paddle_width]
    movss   -24[rbp], xmm0
    movss   xmm0, dword[paddle_height] 
    movss   -20[rbp], xmm0

    mov     rax, -32[rbp]
    mov     rdx, -24[rbp]
    mov     -48[rbp], rax
    mov     -40[rbp], rdx
    lea     rdx, -48[rbp]
    movss   xmm0, -4[rbp]
    mov     rax, -12[rbp]
    mov     r8, rdx
    movaps  xmm1, xmm0
    mov     rcx, rax
    call    CheckCollisionCircleRec
    add rsp, 80
    test    al, al
    je      fin1

    ;; dentro del if
    movss xmm0, dword[player1_x] 
    addss xmm0, dword[paddle_width] 
    addss xmm0, dword[ball_radius]
    movss dword[ball_x], xmm0
    movss   xmm0, dword[ball_speed_x]
    movss   xmm1, dword[pos_mask] 
    andps   xmm0, xmm1
    movss   dword[ball_speed_x] , xmm0
    movss   xmm0, dword[ball_y] 
    movss   xmm2, dword[player1_y]  
    movss   xmm1, dword[paddle_height] 
    movss   xmm3, dword[const_2]
    divss   xmm1, xmm3
    addss   xmm1, xmm2
    subss   xmm0, xmm1
    mulss   xmm0, dword[const_0_1] 
    movss dword[ball_speed_y], xmm0
    fin1:

    if_for_player2:
    sub rsp, 80
    movss   xmm0, dword[ball_x] 
    movss    -12[rbp], xmm0
    movss   xmm0, dword[ball_y] 
    movss   -8[rbp], xmm0
    movss   xmm0, dword[ball_radius] 
    movss   -4[rbp], xmm0

    movss   xmm0, dword[player2_x] 
    movss   -32[rbp], xmm0
    movss   xmm0, dword[player2_y] 
    movss   -28[rbp], xmm0
    movss   xmm0, dword[paddle_width]
    movss   -24[rbp], xmm0
    movss   xmm0, dword[paddle_height] 
    movss   -20[rbp], xmm0

    mov     rax, -32[rbp]
    mov     rdx, -24[rbp]
    mov     -48[rbp], rax
    mov     -40[rbp], rdx
    lea     rdx, -48[rbp]
    movss   xmm0, -4[rbp]
    mov     rax, -12[rbp]
    mov     r8, rdx
    movaps  xmm1, xmm0
    mov     rcx, rax
    call    CheckCollisionCircleRec
    add rsp, 80
    test    al, al
    je      fin2 

    ;; dentro del if
    movss xmm0, dword[player2_x] 
    subss xmm0, dword[ball_radius] 
    movss dword[ball_x], xmm0
    movss   xmm0, dword[ball_speed_x]
    movss   xmm1, dword[pos_mask] 
    andps   xmm0, xmm1
    movss   xmm1, dword[neg_mask]
    xorps   xmm0,  xmm1 
    movss   dword[ball_speed_x] , xmm0
    movss   xmm0, dword[ball_y] 
    movss   xmm2, dword[player2_y]  
    movss   xmm1, dword[paddle_height] 
    movss   xmm3, dword[const_2]
    divss   xmm1, xmm3
    addss   xmm1, xmm2
    subss   xmm0, xmm1
    mulss   xmm0, dword[const_0_1] 
    movss dword[ball_speed_y], xmm0
    fin2:

check_winner:
    .L1:
        mov     edx, [player1_score]
        mov     eax, [max_score]
        cmp     edx, eax
        jb      .L2
        mov     eax, [player1_score]
        mov     edx, [player2_score]
        cmp     edx, eax
        jnb     .L2
        mov     byte[game_state], PLAYER1_WIN
        jmp     .L3
    .L2:
        mov     edx, [player2_score]
        mov     eax, [max_score]
        cmp     edx, eax
        jb      .L4
        mov     eax, [player2_score]
        mov     edx, [player1_score]
        cmp     edx, eax
        jnb     .L4
        mov     byte[game_state], PLAYER2_WIN
        jmp     .L3
    .L4:
        mov     byte[game_state], ONGOING
    .L3:

    sub rsp, 32
    call EndDrawing
    add rsp, 32

    jmp main_loop

end_game:
    sub rsp ,32
    call CloseWindow
    add rsp, 32

    switch_case:
        cmp byte[game_state], PLAYER1_WIN
        je  .print1
        cmp byte[game_state], PLAYER2_WIN
        je  .print2
        cmp byte[game_state], ONGOING
        je  .print3

    .print1:
        sub rsp, 32
        mov rcx, msg_player1_win
        call printf
        add rsp, 32
        jmp   .print3 
    .print2:
        sub rsp, 32
        mov rcx, msg_player2_win
        call printf
        add rsp, 32
        jmp   .print3 

    .print3:
        sub rsp, 32
        mov rcx, msg_end_game
        call printf
        add rsp, 32

    pop rbp
    ret
