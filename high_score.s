reset_score: ; call at the start of the game
    ldy #$00
score_loop:
    lda #0 ; clearing up the score to 0
    sta score, y
    iny
    cpy #$03
    bne score_loop
    rts 
    ; doing it in a loop to not repeat code




add_score:
; we cant add more than 99 at a time to the score or else it"ll break
; example of adding score:
;           lda #25
;           jsr add_score
    clc
    adc score
    sta score
    cmp #99
    bcc @skip ; if value is <= 99 we go to our skip lapel
    sec
    sbc #100 ; subtract 100 from score
    sta score   
    inc score+1
    lda score+1 
    cmp #99 ; if the score is > 99 we need to carry over
    bcc @skip 

    sec
    sbc #100 ; subtract 100 from score again
    sta score+1
    inc score+2
    lda score+2 
    cmp #99 ; if the score is > 99 we need to carry a third time
    bcc @skip
    sec
    sbc #100 
    sta score+2 

@skip:
    lda #$01
    ora update ; ora = logical inclusive OR on accumulator
    sta update
    rts



; decimal converter from the megablast.s project
dec99_to_bytes:

    ldx #0
    cmp #50 ; A = 0-99
    bcc try20
    sbc #50
    ldx #5
    bne try20

div20:
    inx
    inx 
    sbc #20

try20:
    cmp #20
    bcs div20

try10:
    cmp #10
    bcc @finished
    sbc #10
    inx

@finished:
    rts 


display_score:
    ; Set PPU address to top-right, row 1, col 30
    lda #$20    ; high byte of $203E
    sta $2006
    lda #$38    ; low byte of $203E
    sta $2006

    lda score+2
    jsr dec99_to_bytes
    stx temp ; tens
    sta temp+1; ones

    ;process tens bytes
    lda score+1
    jsr dec99_to_bytes
    stx temp+2 ; hundreds
    sta temp+3 ; tens
    
    lda score
    jsr dec99_to_bytes
    stx temp+4 ; tens
    sta temp+5 ; ones

    ldx #0
@loop:
    lda temp, x        ; number 0-9
    tay                ; use Y to index
    lda digit_tiles, y ; get actual CHR tile
    sta $2007
    inx
    cpx #6
    bne @loop
    lda digit_tiles
    sta $2007
    rts


;if as sprite the following functions are necessary for it 
digit_tiles:
    .byte $20, $21, $22, $23, $24, $25, $26, $27, $28, $29