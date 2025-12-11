
enemies_to_oam:
    ldy #$00
@loop:
    lda evilDheegs, y
    sta $0210, y
    iny
    cpy #$20
    bne @loop
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

    lda enemy_alive
    and enemy_mask,y         ; mask bit
    bne enemy_skip         ; if bit=1 → skip enemy

    ; Compute OAM offset (A = index)

    tya
    asl
    asl
    asl
    asl                    ; ×16
    adc #$10               ; base OAM offset
    clc
    ; movement
    ldx #$FF               ; dx
    ldy #$00               ; dy

	pha ; put OAM offset on stack

    jsr func_move_16x16

	; /-----------------\
	; | Enemy collision |
	; \-----------------/
	pla
	sta reg_swap
	tax ; enemy offset is in x
	ldy $0200, x
	tya ; y pos is now in a
	ldy reg_swap ; enemy offset is in y
	ldx $0203, y ; x now contains enemy x pos
	tay ; y now contains enemy y pos

	lda reg_d ; enemy walls collision clobbers d so it has to be pushed
	pha
	lda reg_swap ; enemy offset needs to be stored for later
	pha

	jsr func_enemy_walls_collision
	sta reg_swap ; swap now contains returned variable

	pla
	sta reg_d ; restore d
	pla
	tay ; y now contains enemy offset
	lda reg_swap ; a now contains return code

	cmp #$01 ; if enemy hit wall
	bne :+
		dec kitchen_hp
		; TODO replace this bit of code with the enemy dying, current enemy offset is in y rn
		ldy reg_d
		lda #$FF
		sta $0200, y
		;
	:

	; -------------------

    rts

enemy_skip:
    inc reg_d
    lda reg_d
    cmp #$02
    bne enemy_loop
    rts


evilDheegs:

	amount_of_evilDheegs = $02
; Enemy 0
    .byte $80, $01, $00, $F0  ; top-left ; Y pos , tile , attr , x pos
    .byte $80, $02, $00, $F0+8 ; top-right
    .byte $88, $03, $00, $F0   ; bottom-left
    .byte $88, $04, $00, $F0+8 ; bottom-right
	; Enemy 1
    .byte $90, $01, $00, $10   ; top-left
    .byte $90, $02, $00, $18   ; top-right
    .byte $98, $03, $00, $10   ; bottom-left
    .byte $98, $04, $00, $18   ; bottom-right

