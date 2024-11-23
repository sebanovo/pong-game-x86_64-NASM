%ifndef STRUC_GAME_H 
%define STRUC_GAME_H

struc Game
    .title:       resb 50
    .width:       resd 1
    .height:      resd 1
    .max_score:   resd 1
    .state:       resb 1
endstruc

struc Ball 
    .x:           resd 1
    .y:           resd 1
    .radius:      resd 1
    .speed_x:     resd 1    
    .speed_y:     resd 1    
endstruc

struc Player 
    .x:           resd 1
    .y:           resd 1
    .score:       resd 1
endstruc

struc Paddle 
    .width:       resd 1
    .height:      resd 1
    .speed:       resd 1
endstruc

%endif