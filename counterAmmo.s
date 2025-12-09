
add_ammo:
    lda ammoCount
    inc ammoCount
    rts
dec_counter:

    rts
cant_shoot:


    rts
can_shoot:
    ;just jump to your zapper func here

    dec ammoCount
    rts

ammo_oam:


draw_ammo:


check_ammo:
    lda ammoCount
    beq cant_shoot
    jmp can_shoot


ammoSprite: .byte $00 , $34 , $01, $80 ; y , tile , attr , x