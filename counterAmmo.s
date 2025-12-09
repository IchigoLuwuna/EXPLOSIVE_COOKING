
add_ammo:
    lda ammo_count
    inc ammo_count
    rts
dec_counter:

    rts
cant_shoot:


    rts
can_shoot:
    ;just jump to your zapper func here

    dec ammo_count
    rts

ammo_oam:


draw_ammo:


check_ammo:
    lda ammo_count
    beq cant_shoot
    jmp can_shoot


ammo_sprite: .byte $00 , $34 , $01, $80 ; y , tile , attr , x