; Handle collisions between player and walls

; player:
;   16x16 square
;       topleft coordinate
;       width = height
;   Only position changes

; wall;
;   AxB rectangle
;       topleft coordinate
;       width
;       height

; pointer for wall index
; walls should be contiguous in memory

; loop over all walls



; when attempt movement, check if it would cause collisions
;   Don't allow movement if it would cause collisions
;
; wall* pWall{address of first wall};
; for(count{0}; count < 4; ++count)
; {
;   if(!(player_pos inside *pWall))
;   {
;       Return to prev pos
;   }
;   pWall += 4;
; }

; needs:
;   Way to move back
;   Address of first wall



; loads #$01 into A if colliding with wall (otherwise #$00)
; x: player x movement ($00, $01 or $FF(=-1))
; y: player y movement ($00, $01 or $FF(=-1))
func_player_walls_collision:
    lda #first_wall_addr    ; store pWall in register b
    sta reg_b

    ; loop over all walls
@loop:
    ; collision checks with current wall
    lda reg_b + $00   ; wall x
    sbc #$10        ; player width
    clc
    cmp PLR_POSX_ADDR
    bpl :+  ; if player position x is too low to collide, skip
        lda reg_b + $00   ; wall x
        adc reg_b + $02   ; wall width
        clc
        cmp PLR_POSX_ADDR
        bmi :+  ; if player position x is too high to collide, skip
            lda reg_b + $01   ; wall y
            sbc #$10        ; player height
            clc
            cmp PLR_POSY_ADDR
            bpl :+  ; if player position y is too low to collide, skip
                lda reg_b + $01   ; wall y
                adc reg_b + $03   ; wall height
                clc
                cmp PLR_POSY_ADDR
                bmi :+  ; if player position y is too high to collide, skip
                    ; player will collide with this wall
                    lda #$01
                    jmp player_walls_collision_end
    :
    
    ; to next iteration or break out of loop
next_loop:
    lda reg_b
    sbc #$12
    clc
    cmp #first_wall_addr
    beq :+
        adc #$04
        clc
        sta reg_b
        jmp @loop
    :

    lda #$00
player_walls_collision_end:
    rts