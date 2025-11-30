.include "famistudio_ca65.s"
.include "shoot_sfx.s"

; a: sfx index
; before loading, set sfx_channel to the channel which the sfx should be played on
; sfx_channel = FAMISTUDIO_SFX_CH0 ... FAMISTUDIO_SFX_CH3
play_sfx:
    sta reg_d   ; temporarily store a in memory
    tya         ; push y
    pha
    txa         ; push x
    pha

    ; start function
    lda reg_d   ;  
    ldx sfx_channel 
    jsr famistudio_sfx_play

    ; end function

    pla     ; pull x
    tax
    pla     ; pull y
    tay

    rts