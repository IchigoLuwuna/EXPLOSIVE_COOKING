score: .res 3
update: .res 1

reset_score: ; call at the start of the game
    ldy #$00
score_loop:
    lda #0 ; clearing up the score to 0
    sta score, y
    iny
    cpy #$03
    bne score_loop


; we cant add more than 99 at a time to the score, so make it like 50 for each enemy killed?

add_score:
    clc
    adc score
    sta score
    cmp #99
    bcc @skip ; if value is <= 99 we go to our skip lapel
    sec
    sbc #100
    sta score
    inc score+1
    lda score+1
    cmp #99
    bcc @skip 

    sec
    sbc #100
    sta score+1
    inc score+2
    lda score+2
    cmp #99
    bcc @skip
    sec
    sbc #100
    sta score+2

@skip:
    lda #%000000001
    ora update ; ora = logical inclusive OR on accumulator
    sta update
    rts