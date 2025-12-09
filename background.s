draw_background:

    lda $2002 ; resetting the ppu latch

    jsr func_vblank_wait


    ;Turn off rendering while writing

    lda #%00000000
    sta $2000
    lda #%00000000
    sta $2001

    ; Set PPU address to $2000 (nametable start)
    lda #$20
    sta $2006
    lda #$00
    sta $2006


    ;Setup zero-page pointer

    lda #<bg
    sta L_byte
    lda #>bg
    sta H_byte
    ldx #$00          ; page counter

next_page:
    ldy #$00
page_loop:
    lda (L_byte), y ; load byte from bg
    sta $2007
    iny
    bne page_loop ; loop until 256 bytes written

    inc H_byte
    inx
    cpx #$03
    bne next_page ; loop for 4 pages

    ; last 192 bytes
    ldy #$00
last_chunk:
    lda (L_byte), y
    sta $2007
    iny
    cpy #192
    bne last_chunk ; loop until 192 bytes written


    ;Reset scroll
	jsr draw_ammo_number
    jsr reset_scroll

    rts