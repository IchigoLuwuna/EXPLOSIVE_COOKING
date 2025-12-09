

ammo_addr_hi = $20    ; high byte of $2010
ammo_addr_lo = $30    ; low byte of $2010

add_ammo:
    lda ammo_count
    cmp #$03
    bcs @done
    inc ammo_count
    lda #%00000001   ; set "update ammo" flag
    sta update_ammo
@done:
    rts


dec_counter: ; not done yet 
    dec ammo_count
    jsr draw_ammo_number
    rts


can_shoot:
    ;just jump to your zapper func here

    dec ammo_count
    rts


check_update_ammo:
    lda update_ammo
    beq @skip
    jsr draw_ammo_number
    lda #$00
    sta update_ammo
    lda #$00
    sta $2005
    lda #$00
    sta $2005

@skip:
    rts



draw_ammo_number:
    lda $2002          ; reset latch

    lda #ammo_addr_hi
    sta $2006          ; set high byte

    lda #ammo_addr_lo
    sta $2006          ; set low byte ($2010)

    lda ammo_count
    tay
    lda ammo_tiles, y  ; get the tile for 0–3
    sta $2007          ; write ONE TILE

    rts

ammo_tiles: 
    .byte $20  ; tile for 0
    .byte $21  ; tile for 1
    .byte $22  ; tile for 2
    .byte $23  ; tile for 3