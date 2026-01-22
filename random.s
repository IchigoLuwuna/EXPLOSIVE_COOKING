; ---------------------------------------------
; set seed for random number generation equal to clock (#$00 is invalid so use #$7f instead)
; seed stored in lfsr
func_seed_random:
    lda clock
    cmp #$00    ; if seed is #$00, set to #$7f
    bne :+
		lda #$7f
    :
    sta lfsr    ; store seed in lfsr

func_seed_random_end:
    rts
; ---------------------------------------------



; ---------------------------------------------
; get a new random number (using 8bit XOR-shift)
; return: random number -> register A
func_random_to_acc:
    lda reg_b   ; push register b
    pha

    ; ----------------------------------
    ; calculate next random number
    ; ----------------------------------

    ; store bit 7 in register B
    lda #%10000000          ; isolate bit 7
    and lfsr
    jsr func_acc_to_bool    ; convert to bool
    sta reg_b

    ; xor bit 5 with bit 7
    lda #%00100000          ; isolate bit 5
    and lfsr
    jsr func_acc_to_bool    ; convert to bool
    eor reg_b               ; xor with bit 7
    sta reg_b

    ; xor bit 4 with result of previous xor
    lda #%00010000          ; isolate bit 4
    and lfsr
    jsr func_acc_to_bool    ; convert to bool
    eor reg_b               ; xor with result of previous xor
    sta reg_b

    ; xor bit 3 with result of previous xor
    lda #%00001000          ; isolate bit 3
    and lfsr
    jsr func_acc_to_bool    ; convert to bool
    eor reg_b               ; xor with result of previous xor

    ; shift lfsr and shift in new bit
    asl lfsr
    ora lfsr    ; add new bit
    sta lfsr

func_random_to_acc_end:
    pla         ; pull register b
    sta reg_b

    lda lfsr    ; return random number in register A

    rts
; ---------------------------------------------



; ---------------------------------------------
; turns accumulator into boolean (helper function for func_random_to_acc)
; param: shifted boolean -> register A
; return: #$00 or #$01 -> register A
func_acc_to_bool:
    cmp #$00
    beq :+  ; if register A != #$00, return #$01
        lda #%00000001
    :

func_acc_to_bool_end:
    rts
; ---------------------------------------------