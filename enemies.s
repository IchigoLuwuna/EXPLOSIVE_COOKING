
enemies_to_oam:
    lda evilDheegs, y
    sta $0210, y      ; $0210 = shadow OAM for enemies
    iny
    cpy #$20           ; 16 bytes per enemy * 2 enemies = 32
    bne enemies_to_oam
    rts
	




enemies_init:
	jsr func_random_to_acc      ; get random byte in A
	and #%01111111              ; limit to 0-127 (screen height)
	ldy #$00                     ; base sprite offset in OAM for enemy 0
	lda #$00
	jsr func_move_16x16          ; X=0, Y=A → only move vertically

	jsr func_random_to_acc
	and #%01111111
	ldy #$10                     ; base sprite offset in OAM for enemy 1 (next 16x16 block)
	lda #$00
	jsr func_move_16x16          ; X=0, Y=A
    rts
;--------------------------------------------------------


   

enemy_loop:

    ldy reg_d              ; A = enemy index
                        ; Y = enemy index

    lda enemyflags
    and enemyMask,y         ; mask bit
    bne enemy_skip         ; if bit=1 → skip enemy

    ; Compute OAM offset (A = index)

    tya
    asl
    asl
    asl
    asl                    ; ×16
    clc
    adc #$10               ; base OAM offset

    ; movement
    ldx #$FF               ; dx
    ldy #$00               ; dy
    jsr func_move_16x16
    rts

enemy_skip:
    inc reg_d
    lda reg_d
    cmp #2
    bne enemy_loop
    rts


evilDheegs:

	amount_of_evilDheegs = $02
; Enemy 0
    .byte $80, $01, $00, $F0  ; top-left
    .byte $80, $02, $00, $F0+8 ; top-right
    .byte $88, $03, $00, $F0   ; bottom-left
    .byte $88, $04, $00, $F0+8 ; bottom-right
	; Enemy 1
    .byte $90, $01, $00, $10   ; top-left
    .byte $90, $02, $00, $18   ; top-right
    .byte $98, $03, $00, $10   ; bottom-left
    .byte $98, $04, $00, $18   ; bottom-right
	