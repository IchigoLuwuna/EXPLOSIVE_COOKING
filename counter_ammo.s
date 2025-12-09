

ammo_addr_hi = $20    ; high byte of $2010
ammo_addr_lo = $30    ; low byte of $2010

init_ammo:
    lda #$01
    sta ammo_count
    lda #$01
    sta update_ammo

    rts

add_ammo:
    lda ammo_count
    cmp #$03
    bcs @done
    inc ammo_count
    lda #%00000001   ; set "update ammo" flag
    sta update_ammo
@done:
    rts


dec_counter:
    lda ammo_count    ; load current ammo
    beq @done         ; if 0, don’t decrement
    dec ammo_count    ; decrease ammo
    jsr draw_ammo_number  ; update display
    jsr reset_scroll
@done:
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
    jsr reset_scroll

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