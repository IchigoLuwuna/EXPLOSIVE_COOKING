
ammo_sprite_slot = $0290


init_ammo:
    lda #$01
    sta ammo_count
    jsr draw_ammo
    rts

add_ammo:
    lda ammo_count
    cmp #$03          ; max ammo = 3
    bcs @done
    inc ammo_count
@done:
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
