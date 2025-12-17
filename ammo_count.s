
ammo_sprite_slot = $02C0


init_ammo:
    lda #$03
    sta ammo_count
    jsr draw_ammo
    rts

;--------------------------
; adds register A to ammo_count
;--------------------------
add_ammo:
    adc ammo_count
    clc
    cmp #$06          ; max ammo = 6
    bpl :+
        sta ammo_count
        jmp add_ammo_end
    :
    lda #$06
    sta ammo_count
add_ammo_end:
    jsr update_ammo
    rts

dec_ammo:
    lda ammo_count
    beq @done
    dec ammo_count
@done:
    jsr update_ammo
    rts

update_ammo:

    ldy ammo_count
    lda ammo_tiles, y
    sta ammo_sprite_slot+1    ; update tile in sprite
    rts

draw_ammo:
    ldy #$0        ; start at offset 0
copy_loop:
    lda ammo_sprite, y
    sta ammo_sprite_slot, y
    iny
    cpy #$04       ; we have 4 bytes: Y, tile, attr, X
    bne copy_loop
    rts

ammo_tiles: 
    .byte $20  ; tile 0
    .byte $21  ; tile 1
    .byte $22  ; tile 2
    .byte $23  ; tile 3

ammo_sprite: .byte $07, $20, $00, $10  ; Y=5, tile=0, attr=1, X=16
