bits 64
default rel

%include "src/colors.inc"
%include "src/keys.inc"

; std
extern printf
; windows API
extern ExitProcess
; raylib
global main
extern InitWindow
extern SetTargetFPS
extern WindowShouldClose
extern BeginDrawing
extern ClearBackground
extern DrawText
extern EndDrawing
extern CloseWindow
extern DrawCircle
extern DrawRectangle
extern IsKeyDown

section .data
    ; window 
    screen_width equ 800
    screen_height equ 450
    window_title db "Ping Pong Game", 0
    message db "Congrats! You created your first window!", 0
    font_size equ 20
    text_color dd 0xFFFFFFFF
    msg db "FIN DEL JUEGO", 0
    ; ball
    ball_radius dd 5.0
    ball_velocity equ 10
    ball_x dd screen_width / 2
    ball_y dd screen_height / 2
    ball_dx dd ball_velocity
    ball_dy dd ball_velocity
    ball_velocity_x dd ball_velocity
    ball_velocity_y dd ball_velocity
    ; paddle
    paddle_width equ 20
    paddle_height equ 80
    paddle_x dd 50
    paddle_y dd (screen_height / 2) - (paddle_height / 2);
    paddle_velocity equ 10

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

mainLoop:
    sub rsp, 32
    call WindowShouldClose
    add rsp, 32
    test eax, eax
    jnz endGame 

    sub rsp, 32
    call BeginDrawing
    add rsp, 32

    sub rsp, 32
    mov rcx, BLACK   
    call ClearBackground
    add rsp, 32

drawBall:
    sub rsp, 32
    mov ecx, [ball_x]
    mov edx, [ball_y]
    movss xmm2, [ball_radius]
    mov r9d, GREEN
    call DrawCircle
    add rsp, 32

moveBall:
    mov eax, [ball_x]
    mov ebx, [ball_y]
    add eax, [ball_dx]
    sub ebx, [ball_dy]
    mov dword[ball_x], eax
    mov dword[ball_y], ebx

checkBoundaryCollision:
    if:
    mov eax, [ball_x]
    movss xmm0, dword [ball_radius]
    cvttss2si ecx, xmm0
    add eax, ecx 
    cmp eax, screen_width
    jg toogleDx
    mov eax, [ball_x]
    sub eax, ecx
    cmp eax, 0
    jl toogleDx
    elseif:
    mov eax, [ball_y]
    add eax, ecx
    cmp eax, screen_height 
    jg toggleDy
    mov eax, [ball_y]
    sub eax, ecx
    cmp eax, 0
    jl toggleDy
    jmp endCheckBoundaryCollision

    toogleDx:
    mov ebx, [ball_dx]
    neg ebx
    mov dword [ball_dx], ebx
    jmp endCheckBoundaryCollision 

    toggleDy:
    mov ebx, [ball_dy]
    neg ebx
    mov dword [ball_dy], ebx
    jmp endCheckBoundaryCollision 

    endCheckBoundaryCollision:

drawPaddle:
    sub rsp, 32 + 16
    mov ecx, [paddle_x]
    mov edx, [paddle_y]
    mov r8d, paddle_width
    mov r9d, paddle_height
    mov eax, WHITE 
    mov dword [rsp+32], eax
    call DrawRectangle 
    add rsp, 32 + 16

movePaddle:
    sub rsp, 32
    mov ecx, KEY_W
    call IsKeyDown
    add rsp, 32
    test eax, eax
    jz checkKey_S
    mov eax, [paddle_y]
    cmp eax, 0
    jle checkKey_S 
    sub eax, paddle_velocity
    mov [paddle_y], eax

    checkKey_S:
    sub rsp, 32
    mov ecx, KEY_S
    call IsKeyDown
    add rsp, 32
    test eax, eax
    jz endMovePaddle 
    mov eax, [paddle_y]
    mov ebx, screen_height
    sub ebx, paddle_height
    cmp eax,ebx 
    jge endMovePaddle
    add eax, paddle_velocity
    mov [paddle_y], eax
    endMovePaddle:

checkCollisionBetweenBallAndPaddle:
    mov eax, [ball_x]
    movss xmm0, dword[ball_radius]
    cvttss2si ecx, xmm0
    add eax, ecx
    mov ebx, [paddle_x]
    add ebx, paddle_width
    cmp eax, ebx 
    jg endCheckCollisionBetweenBallAndPaddle

    mov eax, [ball_y]
    mov ebx, [paddle_y]
    cmp eax, ebx 
    jle endCheckCollisionBetweenBallAndPaddle 

    add ebx, paddle_height
    cmp eax, ebx 
    jge endCheckCollisionBetweenBallAndPaddle  

    mov eax, [ball_dx]
    neg eax 
    mov [ball_dx], eax
    mov eax, [paddle_x]
    add eax, paddle_width
    add eax, ecx
    mov [ball_x], eax
    endCheckCollisionBetweenBallAndPaddle:

    sub rsp, 32
    call EndDrawing
    add rsp, 32

    jmp mainLoop

endGame:
    sub rsp ,32
    call CloseWindow
    add rsp, 32

    xor rcx, rcx
    call ExitProcess
    pop rbp
