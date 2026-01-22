; ---------------------------------------------
; Wall struct

; left x    : 1 byte
; top y     : 1 byte
; width     : 1 byte
; height    : 1 byte
; ---------------------------------------------



; ---------------------------------------------
; Checks if player will collide with walls if it moves by (x, y)
; param: player x movement (#$00, #$01 or #$FF(=-1)) -> register X
; param: player y movement (#$00, #$01 or #$FF(=-1)) -> register X
; return: #$01 if colliding, else #$00 -> register A
func_player_walls_collision:
    txa     ; push x movement and y movement
    pha
    tya
    pha

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

    ; for(wall in pWalls)
@loop:
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

                    lda #$01    ; set return value
                    sta reg_b
                    jmp func_player_walls_collision_end ; return
    :

    ; to next iteration or break out of loop
    lda reg_b
    sec
    sbc #$10
    clc
    cmp #first_wall_addr    ; if pWall_current - 16 = pWall, break;
    beq :+
        adc #$14
        clc
        sta reg_b
        jmp @loop
    :

    lda #$00    ; set return value
    sta reg_b

func_player_walls_collision_end:
    pla     ; pull x movement and y movement
    tay
    pla
    tax

    lda reg_b   ; get return value

    rts
; ---------------------------------------------



; ---------------------------------------------
; Checks if enemy is colliding with walls
; param: enemy x position -> register X
; param: enemy y position -> register X
; return: #$01 if colliding, else #$00 -> register A
func_enemy_walls_collision:
    txa     ; push x and y position
    pha
    tya
    pha

    lda #first_wall_addr    ; store pWall in register b
    sta reg_b

    ; store enemy pos in reg_c and reg_d
    stx reg_c
    sty reg_d

    ; for(wall in pWalls)
@enemy_collision_loop:
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

                    lda #$01    ; set return value
                    sta reg_b
                    jmp func_enemy_walls_collision_end
    :

    ; to next iteration or break out of loop
    lda reg_b
    sec
    sbc #$10
    clc
    cmp #first_wall_addr    ; if pWall_current - 16 = pWall, break;
    beq :+
        adc #$14
        clc
        sta reg_b
        jmp @enemy_collision_loop
    :

    lda #$00    ; set return value
    sta reg_b

func_enemy_walls_collision_end:
    pla     ; pull x and y position
    tay
    pla
    tax

    lda reg_b   ; get return value

    rts
; ---------------------------------------------



; ---------------------------------------------
; Initializes wall array
func_initialize_walls:
    ; wall 1
    lda #$46    ; left x
    sta first_wall_addr + $00
    lda #$30    ; top y
    sta first_wall_addr + $01
    lda #$0A    ; width
    sta first_wall_addr + $02
    lda #$80    ; height
    sta first_wall_addr + $03

    ; wall 2
    lda #$48
    sta first_wall_addr + $04
    lda #$2E
    sta first_wall_addr + $05
    lda #$80
    sta first_wall_addr + $06
    lda #$10
    sta first_wall_addr + $07

    ; wall 3
    lda #$B1
    sta first_wall_addr + $08
    lda #$30
    sta first_wall_addr + $09
    lda #$0A
    sta first_wall_addr + $0A
    lda #$80
    sta first_wall_addr + $0B

    ; wall 4
    lda #$48
    sta first_wall_addr + $0C
    lda #$AF
    sta first_wall_addr + $0D
    lda #$80
    sta first_wall_addr + $0E
    lda #$10
    sta first_wall_addr + $0F

    ; wall 5
    lda #$53
    sta first_wall_addr + $10
    lda #$5F
    sta first_wall_addr + $11
    lda #$3D
    sta first_wall_addr + $12
    lda #$2F
    sta first_wall_addr + $13

func_initialize_walls_end:
    rts
; ---------------------------------------------