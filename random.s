func_seed_random:
    ; set seed for random number generation equal to clock
    ; a seed of 0 does not work
    lda clock
    cmp #$00    ; if seed is 0, set to 1
    beq :+
    lda #%01
    :
    sta lfsr    ; store seed in lfsr

    rts

func_random_to_acc:
    ; store bit 7 in register b
    lda #%10000000
    and lfsr    ; isolate bit 7
    jsr func_acc_to_bool
    sta reg_b
    ; xor bit 5 with register b and store in register b
    lda #%00100000
    and lfsr    ; isolate bit 5
    jsr func_acc_to_bool
    eor reg_b
    sta reg_b
    ; xor bit 4 with register b and store in register b
    lda #%00010000
    and lfsr    ; isolate bit 4
    jsr func_acc_to_bool
    eor reg_b
    sta reg_b
    ; xor bit 3 with register b and store in a
    lda #%00001000
    and lfsr    ; isolate bit 3
    jsr func_acc_to_bool
    eor reg_b

    ; shift lfsr and or with x
    asl lfsr
    ora lfsr
    sta lfsr

    lda lfsr

    rts     ; return from subroutine

func_acc_to_bool:
    ldx #%00000000
    cmp #$00    ; turn accumulator into boolean
    beq :+
    ldx #%00000001
    :
    txa
    rts