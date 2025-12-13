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

    txa
    pha
    tya
    pha

    ; loop over all walls
loop:
    ; collision checks with current wall
    ldy reg_b
    lda $00, y   ; wall x
    sec
    sbc #$10     ; player width
    cmp reg_c
    bpl :+  ; if player position x is too low to collide, skip
        lda $00, y      ; wall x
        adc $02, y      ; wall width
        cmp reg_c
        bmi :+  ; if player position x is too high to collide, skip
            lda $01, y      ; wall y
            sec
            sbc #$10        ; player height
            cmp reg_d
            bpl :+  ; if player position y is too low to collide, skip
                lda $01, y      ; wall y
                adc $03, y      ; wall height
                cmp reg_d
                bmi :+  ; if player position y is too high to collide, skip
                    ; player will collide with this wall
                    pla
                    tay
                    pla
                    tax

                    lda #$01
                    jmp player_walls_collision_end
    :

    ; to next iteration or break out of loop
next_loop:
    lda reg_b
    sec
    sbc #$10
    clc
    cmp #first_wall_addr
    beq :+
        adc #$14
        clc
        sta reg_b
        jmp loop
    :

    pla
    tay
    pla
    tax

    lda #$00
player_walls_collision_end:
    rts

; Input parameters -> x & y: enemy position
func_enemy_walls_collision:
    lda #first_wall_addr    ; store pWall in register b
    sta reg_b

    ; store enemy pos in reg_c and reg_d
    stx reg_c

    sty reg_d

    txa
    pha
    tya
    pha

    ; loop over all walls
enemy_collision_loop:
    ; collision checks with current wall
    ldy reg_b
    lda $00, y   ; wall x
    sec
    sbc #$10     ; enemy width
    cmp reg_c
    bpl :+  ; if enemy position x is too low to collide, skip
        lda $00, y      ; wall x
        adc $02, y      ; wall width
        cmp reg_c
        bmi :+  ; if enemy position x is too high to collide, skip
            lda $01, y      ; wall y
            sec
            sbc #$10        ; enemy height
            cmp reg_d
            bpl :+  ; if enemy position y is too low to collide, skip
                lda $01, y      ; wall y
                adc $03, y      ; wall height
                cmp reg_d
                bmi :+  ; if enemy position y is too high to collide, skip
                    ; enemy will collide with this wall
                    pla
                    tay
                    pla
                    tax

                    lda #$01
                    jmp enemy_walls_collision_end
    :

    ; to next iteration or break out of loop
next_enemy_collision_loop:
    lda reg_b
    sec
    sbc #$10
    clc
    cmp #first_wall_addr
    beq :+
        adc #$14
        clc
        sta reg_b
        jmp enemy_collision_loop
    :

    pla
    tay
    pla
    tax

    lda #$00
enemy_walls_collision_end:
    rts

func_initialize_walls:
    lda #$46
    sta first_wall_addr + $00
    lda #$20
    sta first_wall_addr + $01
    lda #$08
    sta first_wall_addr + $02
    lda #$80
    sta first_wall_addr + $03

    lda #$48
    sta first_wall_addr + $04
    lda #$4E
    sta first_wall_addr + $05
    lda #$80
    sta first_wall_addr + $06
    lda #$10
    sta first_wall_addr + $07

    lda #$B3
    sta first_wall_addr + $08
    lda #$20
    sta first_wall_addr + $09
    lda #$08
    sta first_wall_addr + $0A
    lda #$80
    sta first_wall_addr + $0B

    lda #$48
    sta first_wall_addr + $0C
    lda #$9F
    sta first_wall_addr + $0D
    lda #$80
    sta first_wall_addr + $0E
    lda #$10
    sta first_wall_addr + $0F

    lda #$73
    sta first_wall_addr + $10
    lda #$7F
    sta first_wall_addr + $11
    lda #$1B
    sta first_wall_addr + $12
    lda #$20
    sta first_wall_addr + $13

    rts
