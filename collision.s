; wall;
;   AxB rectangle
;       topleft coordinate
;       width
;       height

; when attempt movement, check if it would cause collisions
;   Don't allow movement if it would cause collisions
;
; wall* pWall{address of first wall};
; for(count{0}; count < 4; ++count)
; {
;   if(player_future_pos inside *pWall)
;   {
;       Return #$01
;   }
;   pWall += 4;
; }


; loads #$01 into A if colliding with wall (otherwise #$00)
; x: player x movement ($00, $01 or $FF(=-1))
; y: player y movement ($00, $01 or $FF(=-1))
func_player_walls_collision:
    lda #first_wall_addr    ; store pWall in register b
    sta reg_b

    stx reg_c   ; store x movement in register c
    sty reg_d   ; store y movement in register d

    ; set player pos to the one if it would move
    lda PLR_POSX_ADDR
    adc reg_c
    clc
    sta PLR_POSX_ADDR

    lda PLR_POSY_ADDR
    adc reg_d
    clc
    sta PLR_POSY_ADDR

    ; loop over all walls
func_player_walls_collision_loop:
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
        jmp func_player_walls_collision_loop
    :

    lda #$00
player_walls_collision_end:
    lda PLR_POSX_ADDR
    sbc reg_c
    clc
    sta PLR_POSX_ADDR

    lda PLR_POSY_ADDR
    sbc reg_d
    clc
    sta PLR_POSY_ADDR

    rts
