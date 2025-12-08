
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
    	ldy #$00
	:
		ammoSprite, Y
		sta $0218 , y ;$2018 -> shadow OAM for ammo
		iny
	cpy #$04
	bmi :-
    rts

draw_ammo:


check_ammo:
    lda ammoCount
    beq cant_shoot
    jmp can_shoot

.segment "ammo Number"
ammoSprite: .byte $00 , $34 , $01, $80 ; y , tile , attr , x