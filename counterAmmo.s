
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

check_ammo:
    lda ammoCount
    beq cant_shoot
    jmp can_shoot

.segment "ammo Number"
ammoSprite: .byte  