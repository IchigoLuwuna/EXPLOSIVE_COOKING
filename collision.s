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

    ; store player pos in reg_c and reg_d
    txa
    adc PLR_POSX_ADDR
    clc
    sta reg_c

    tya
    adc PLR_POSY_ADDR
    clc
    sta reg_d

    ; loop over all walls
loop:
    ; collision checks with current wall
    lda reg_b + $00   ; wall x
    sbc #$10        ; player width
    clc
    cmp reg_c
    bpl :+  ; if player position x is too low to collide, skip
        lda reg_b + $00   ; wall x
        adc reg_b + $02   ; wall width
        clc
        cmp reg_c
        bmi :+  ; if player position x is too high to collide, skip
            lda reg_b + $01   ; wall y
            sbc #$10        ; player height
            clc
            cmp reg_d
            bpl :+  ; if player position y is too low to collide, skip
                lda reg_b + $01   ; wall y
                adc reg_b + $03   ; wall height
                clc
                cmp reg_d
                bmi :+  ; if player position y is too high to collide, skip
                    ; player will collide with this wall
                    lda #$01
                    jmp player_walls_collision_end
    :
    
    ; to next iteration or break out of loop
;next_loop:
;    lda reg_b
;    sbc #$00
;    clc
;    cmp #first_wall_addr
;    beq :+
;        adc #$10
;        clc
;        sta reg_b
;        jmp loop
;    :

    lda #$00
player_walls_collision_end:

    rts



func_initialize_walls:
    lda #$10
    sta first_wall_addr + $00
    lda #$10
    sta first_wall_addr + $01
    lda #$08
    sta first_wall_addr + $02
    lda #$30
    sta first_wall_addr + $03

    rts