bits 64
default rel

%include "struc_game.asm"
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
    radius_of_center_circle dd 50.0
    font_size equ 50
    x_off_set equ 50
game:
   istruc  Game 
   at Game.title,      db "Ping Pong Game", 0
   at Game.width,      dd 1000
   at Game.height,     dd 650 
   at Game.max_score,  dd 50 
   at Game.state,      db ONGOING 
   iend

ball:
   istruc Ball 
   at Ball.x,          dd 325.0
   at Ball.y,          dd 500.0
   at Ball.radius,     dd 10.0
   at Ball.speed_x,    dd 10.0
   at Ball.speed_y,    dd 10.0
   iend

paddle:
   istruc Paddle 
   at Paddle.width,    dd 20.0
   at Paddle.height,   dd 100.0
   at Paddle.speed,    dd 10.0 
   iend

player1:
   istruc Player 
   at Player.x,        dd 50.0
   at Player.y,        dd 333.3333333333
   at Player.score,    dd 0 
   iend

player2:
   istruc Player 
   at Player.x,        dd 960.0
   at Player.y,        dd 333.3333333333
   at Player.score,    dd 0 
   iend

section .rdata
    score_format:    db "%u",0

    msg_player1_win: db "Player 1 wins!", 10, 0
    msg_player2_win: db "Player 2 wins!", 10 ,0
    msg_end_game:    db "FIN DEL JUEGO!", 10, 0

    const_2:         dd 2.0  
    const_0_1:       dd 0.1
    neg_mask:        dd 0x80000000 
    pos_mask:        dd 0x7FFFFFFF

section .text
    global main

main:
    push rbp
    mov rbp, rsp

    sub rsp, 32
    mov ecx, [game + Game.width]
    mov edx, [game + Game.height]
    mov r8, game + Game.title
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

    mov al, [game + Game.state]
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
    sub rsp, 48
    mov ecx, [game + Game.width]
    shr ecx, 1
    mov edx, 0 
    mov r8d, [game + Game.width]
    shr r8d, 1
    mov r9d, [game + Game.height]
    mov eax, WHITE 
    mov dword [rsp+32], eax
    call DrawLine 
    add rsp, 48


draw_score:
    sub rsp, 32
    mov ecx, score_format
    mov edx, [player1 + Player.score]
    call TextFormat
    add rsp, 32

    sub rsp, 48
    mov rcx, rax
    mov edx, [game + Game.width]
    shr edx, 2
    mov r8d, 10
    mov dword [rsp+32], RAYWHITE
    mov r9d, font_size 
    call DrawText
    add rsp, 48

    sub rsp, 32
    mov ecx, score_format
    mov edx, [player2 + Player.score]
    call TextFormat
    add rsp, 32

    sub rsp, 48
    mov rcx, rax
    mov edx, [game + Game.width]
    imul edx,3
    shr edx,2
    mov r8d, 10
    mov dword [rsp+32], RAYWHITE
    mov r9d, font_size 
    call DrawText
    add rsp, 48

draw_centre_circle:
    sub rsp, 32
    mov ecx, [game + Game.width]
    shr ecx, 1
    mov edx, [game + Game.height]
    shr edx, 1
    movss xmm2, dword[radius_of_center_circle]
    mov r9d, WHITE
    call DrawCircleLines
    add rsp, 32

draw_ball:
    sub rsp, 32
    movss xmm0, dword[ball + Ball.x]
    movss -8[rbp], xmm0
    movss xmm0, dword[ball + Ball.y]
    movss -4[rbp], xmm0
    mov rcx, -8[rbp]
    movss xmm1, dword[ball + Ball.radius]
    mov r8d, WHITE 
    call DrawCircleV
    add rsp, 32 

draw_players:

.draw_player1:
    sub rsp, 64
    movss xmm0, dword[player1 + Player.x]
    movss -16[rbp], xmm0
    movss xmm0, dword[player1 + Player.y]
    movss -12[rbp], xmm0
    movss xmm0, dword[paddle + Paddle.width]
    movss -8[rbp], xmm0
    movss xmm0, dword[paddle + Paddle.height]
    movss -4[rbp], xmm0
    mov rax, -16[rbp]
    mov rdx, -8[rbp]
    mov -32[rbp], rax
    mov -24[rbp], rdx
    lea rax, -32[rbp]
    mov rcx, rax
    movss xmm1, dword[ball + Ball.radius]
    mov r8d, 0
    mov r9d, WHITE
    call DrawRectangleRounded
    add rsp, 64

.draw_player2:
    sub rsp, 64
    movss xmm0, dword[player2 + Player.x]
    movss -16[rbp], xmm0
    movss xmm0, dword[player2 + Player.y]
    movss -12[rbp], xmm0
    movss xmm0, dword[paddle + Paddle.width]
    movss -8[rbp], xmm0
    movss xmm0, dword[paddle + Paddle.height]
    movss -4[rbp], xmm0
    mov rax, -16[rbp]
    mov rdx, -8[rbp]
    mov -32[rbp], rax
    mov -24[rbp], rdx
    lea rax, -32[rbp]
    mov rcx, rax
    movss xmm1, dword[ball + Ball.radius]
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
    je .done 
    
    movss xmm0, dword[player1 + Player.y]
    pxor xmm1, xmm1
    comiss xmm0, xmm1
    jbe .done 

    movss xmm0, dword[player1 + Player.y]
    subss xmm0, dword [paddle + Paddle.speed]
    movss dword[player1 + Player.y], xmm0
.done:

mov_player1_KEY_S:
    sub rsp, 32
    mov rcx, KEY_S
    call IsKeyDown
    add rsp, 32
    cmp rax, 0 
    je .done 

    cvtsi2ss xmm0, dword[game + Game.height]
    subss   xmm0,  dword[paddle + Paddle.height]
    comiss  xmm0,  dword[player1 + Player.y] 
    jbe .done 

    movss xmm0, dword[player1 + Player.y]
    addss xmm0, dword [paddle + Paddle.speed]
    movss dword[player1 + Player.y], xmm0
.done:

mov_player2_KEY_UP:
    sub rsp, 32
    mov rcx, KEY_UP
    call IsKeyDown
    add rsp, 32
    cmp rax, 0 
    je .done 
    
    movss xmm0, dword[player2 + Player.y]
    pxor    xmm1, xmm1
    comiss  xmm0, xmm1
    jbe .done 

    movss xmm0, dword[player2 + Player.y]
    subss xmm0, dword [paddle + Paddle.speed]
    movss dword[player2 + Player.y], xmm0
.done:

mov_player2_KEY_DOWN:
    sub rsp, 32
    mov rcx, KEY_DOWN
    call IsKeyDown
    add rsp, 32
    cmp rax, 0 
    je .done 

    cvtsi2ss xmm0, dword[game + Game.height]
    subss   xmm0, dword[paddle + Paddle.height]
    comiss  xmm0, dword[player2 + Player.y] 
    jbe .done 

    movss xmm0, dword[player2 + Player.y]
    addss xmm0, dword [paddle + Paddle.speed]
    movss dword[player2 + Player.y], xmm0
.done:

check_boundary_collision:

.L1:
    movss xmm0, [ball + Ball.x]
    addss xmm0, dword[ball + Ball.radius]
    cvtsi2ss xmm1, dword[game + Game.width]
    comiss xmm0, xmm1 
    jbe .L2

    movss xmm1, dword[const_2] 

    cvtsi2ss xmm0, [game + Game.width]
    divss xmm0, xmm1
    movss dword[ball + Ball.x], xmm0

    cvtsi2ss xmm0, [game + Game.height]
    divss xmm0, xmm1
    movss dword[ball + Ball.y], xmm0

    movss xmm0, dword[ball + Ball.speed_x]
    movd xmm1, dword [neg_mask] 
    xorps xmm0, xmm1
    movss [ball + Ball.speed_x], xmm0
    inc dword[player1 + Player.score]
    jmp .done

.L2:
    movss xmm0, dword[ball + Ball.x]
    movaps xmm1, xmm0
    subss xmm1, dword[ball + Ball.radius] 
    pxor xmm0, xmm0
    comiss xmm0, xmm1
    jbe .L3

    movss xmm1, dword[const_2] 
    cvtsi2ss xmm0, [game + Game.width]
    divss xmm0, xmm1
    movss dword[ball + Ball.x], xmm0

    cvtsi2ss xmm0, dword[game + Game.height]
    divss xmm0, xmm1
    movss dword[ball + Ball.y], xmm0

    movss xmm0, dword[ball + Ball.speed_x]
    movd xmm1, dword [neg_mask] 
    xorps xmm0, xmm1
    movss [ball + Ball.speed_x], xmm0
    inc dword[player2 + Player.score]
    jmp .L5

.L3:
    movss xmm0, dword[ball + Ball.y]
    addss xmm0, dword[ball + Ball.radius] 
    cvtsi2ss xmm1, dword[game + Game.height]
    comiss xmm0, xmm1 
    ja .L4
    movss xmm0, dword[ball + Ball.y] 
    movaps xmm1, xmm0
    subss xmm1, dword[ball + Ball.radius] 
    pxor xmm0, xmm0
    comiss xmm0, xmm1
    jbe .done

.L4:
    movss xmm0, dword[ball + Ball.speed_y]
    movd xmm1, dword [neg_mask] 
    xorps xmm0, xmm1
    movss [ball + Ball.speed_y], xmm0

.L5: 

.done:

move_ball:
    movss xmm0, dword[ball + Ball.x]
    addss xmm0, dword[ball + Ball.speed_x] 
    movss dword[ball + Ball.x], xmm0
    movss xmm0, dword[ball + Ball.y]
    addss xmm0, dword[ball + Ball.speed_y] 
    movss dword[ball + Ball.y], xmm0

check_collision_between_ball_and_paddles:

if_for_player1:
    sub rsp, 80
    movss xmm0, dword[ball + Ball.x] 
    movss -12[rbp], xmm0
    movss xmm0, dword[ball + Ball.y] 
    movss -8[rbp], xmm0
    movss xmm0, dword[ball + Ball.radius] 
    movss -4[rbp], xmm0

    movss xmm0, dword[player1 + Player.x] 
    movss -32[rbp], xmm0
    movss xmm0, dword[player1 + Player.y] 
    movss -28[rbp], xmm0
    movss xmm0, dword[paddle + Paddle.width]
    movss -24[rbp], xmm0
    movss xmm0, dword[paddle + Paddle.height] 
    movss -20[rbp], xmm0

    mov rax, -32[rbp]
    mov rdx, -24[rbp]
    mov -48[rbp], rax
    mov -40[rbp], rdx
    lea rdx, -48[rbp]
    movss xmm0, -4[rbp]
    mov rax, -12[rbp]
    mov r8, rdx
    movaps xmm1, xmm0
    mov rcx, rax
    call CheckCollisionCircleRec
    add rsp, 80
    test al, al
    je .done 

    movss xmm0, dword[player1 + Player.x] 
    addss xmm0, dword[paddle + Paddle.width] 
    addss xmm0, dword[ball + Ball.radius]
    movss dword[ball + Ball.x], xmm0
    movss xmm0, dword[ball + Ball.speed_x]
    movss xmm1, dword[pos_mask] 
    andps xmm0, xmm1
    movss dword[ball + Ball.speed_x], xmm0
    movss xmm0, dword[ball + Ball.y] 
    movss xmm2, dword[player1 + Player.y]  
    movss xmm1, dword[paddle + Paddle.height] 
    movss xmm3, dword[const_2]
    divss xmm1, xmm3
    addss xmm1, xmm2
    subss xmm0, xmm1
    mulss xmm0, dword[const_0_1] 
    movss dword[ball + Ball.speed_y], xmm0
    .done:

if_for_player2:
    sub rsp, 80
    movss xmm0, dword[ball + Ball.x] 
    movss  -12[rbp], xmm0
    movss xmm0, dword[ball + Ball.y] 
    movss -8[rbp], xmm0
    movss xmm0, dword[ball + Ball.radius] 
    movss -4[rbp], xmm0

    movss xmm0, dword[player2 + Player.x] 
    movss -32[rbp], xmm0
    movss xmm0, dword[player2 + Player.y] 
    movss -28[rbp], xmm0
    movss xmm0, dword[paddle + Paddle.width]
    movss -24[rbp], xmm0
    movss xmm0, dword[paddle + Paddle.height] 
    movss -20[rbp], xmm0

    mov rax, -32[rbp]
    mov rdx, -24[rbp]
    mov -48[rbp], rax
    mov -40[rbp], rdx
    lea rdx, -48[rbp]
    movss xmm0, -4[rbp]
    mov rax, -12[rbp]
    mov r8, rdx
    movaps xmm1, xmm0
    mov rcx, rax
    call CheckCollisionCircleRec
    add rsp, 80
    test al, al
    je .done 

    movss xmm0, dword[player2 + Player.x] 
    subss xmm0, dword[ball + Ball.radius] 
    movss dword[ball + Ball.x], xmm0
    movss xmm0, dword[ball + Ball.speed_x]
    movss xmm1, dword[pos_mask] 
    andps xmm0, xmm1
    movss xmm1, dword[neg_mask]
    xorps xmm0,  xmm1 
    movss dword[ball + Ball.speed_x] , xmm0
    movss xmm0, dword[ball + Ball.y] 
    movss xmm2, dword[player2 + Player.y]  
    movss xmm1, dword[paddle + Paddle.height] 
    movss xmm3, dword[const_2]
    divss xmm1, xmm3
    addss xmm1, xmm2
    subss xmm0, xmm1
    mulss xmm0, dword[const_0_1] 
    movss dword[ball + Ball.speed_y], xmm0

    .done:

check_winner:

.L1:
    mov edx, [player1 + Player.score]
    mov eax, [game + Game.max_score]
    cmp edx, eax
    jb .L2
    mov eax, [player1 + Player.score]
    mov edx, [player2 + Player.score]
    cmp edx, eax
    jnb .L2
    mov byte[game + Game.state], PLAYER1_WIN
    jmp .done
.L2:
    mov edx, [player2 + Player.score]
    mov eax, [game + Game.max_score]
    cmp edx, eax
    jb .L4
    mov eax, [player2 + Player.score]
    mov edx, [player1 + Player.score]
    cmp edx, eax
    jnb .L4
    mov byte[game + Game.state], PLAYER2_WIN
    jmp .done
.L4:
    mov byte[game + Game.state], ONGOING
.done:

    sub rsp, 32
    call EndDrawing
    add rsp, 32

    jmp main_loop

end_game:
    sub rsp ,32
    call CloseWindow
    add rsp, 32

.switch_case:
    cmp byte[game + Game.state], PLAYER1_WIN
    je .print1
    cmp byte[game + Game.state], PLAYER2_WIN
    je .print2
    cmp byte[game + Game.state], ONGOING
    je .print3

.print1:
    sub rsp, 32
    mov rcx, msg_player1_win
    call printf
    add rsp, 32
    jmp .print3 
.print2:
    sub rsp, 32
    mov rcx, msg_player2_win
    call printf
    add rsp, 32
    jmp .print3 

.print3:
    sub rsp, 32
    mov rcx, msg_end_game
    call printf
    add rsp, 32

    pop rbp
    ret
