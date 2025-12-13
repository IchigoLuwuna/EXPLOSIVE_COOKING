draw_background:

    lda $2002 ; resetting the ppu latch

    jsr func_vblank_wait


    ;Turn off rendering while writing

    lda #%00000000
    sta $2000
    lda #%00000000
    sta $2001


   ; Set PPU address to $2000
    lda #$20
    sta $2006
    lda #$00
    sta $2006

    lda #<bg
    sta L_byte
    lda #>bg
    sta H_byte

    ldx #$04          ; 4 × 256 = 1024 bytes

next_page:
    ldy #$00
page_loop:
    lda (L_byte), y
    sta $2007
    iny
    bne page_loop

    inc H_byte
    dex
    bne next_page

        ;Reset scroll

    jsr reset_scroll

    rts