state_game:
state_game_init:
	jsr func_seed_random

	; Flush OAM
	ldy #$00
	:
		lda #$00
		sta $0200, y
		iny
	cpy #$FF
	bmi :-

	; Initialize OAM
	ldy #$00
	:
		lda dheeg, y
		sta $0200, y
		iny
	cpy #$10
	bmi :-

	;intialize evilDheeg position

	ldx evilDheeg
	stx $0210 ; Y position of the enemy

	ldy #$01

	ldx evilDheeg, y ; Tile index of the enemy
	stx $0211

	ldy #$02
	ldx evilDheeg, y ; Attributes of the enemy
	stx $0212

	ldy #$03
	ldx evilDheeg, y ; X position of the enemy
	stx $0213
	; set dheeg initial position

	ldx #$7F
	ldy #$7F
	lda dheeg_16x16_addr
	jsr func_move_16x16

; allows jumping without reinitialising
state_game_loop:
@forever:
	lda joypad
	sta reg_c ; store state of joypad on previous frame in reg_c -> allows for non-repeating actions on held input
	jsr func_get_input	; get controller input and store in joypad ($00)
	lda joypad
	and #PAD_RIGHT
	cmp #PAD_RIGHT
	bne :+
		ldx #$01
		ldy #$00
		lda #$00
		jsr func_move_16x16
	:

	lda joypad
	and #PAD_LEFT
	cmp #PAD_LEFT
	bne :+
		lda #$01
		jsr func_opposite_a
		tax
		ldy #$00
		lda #$00
		jsr func_move_16x16
	:

	lda joypad
	and #PAD_DOWN
	cmp #PAD_DOWN
	bne :+
		ldx #$00
		ldy #$01
		lda #$00
		jsr func_move_16x16
	:

	lda joypad
	and #PAD_UP
	cmp #PAD_UP
	bne :+
		ldx #$00
		lda #$01
		jsr func_opposite_a
		tay
		lda #$00
		jsr func_move_16x16
	:

	lda joypad
	and #PAD_START
	cmp #PAD_START
	bne :++
		and reg_c
		cmp #PAD_START
		beq :+ ; skip if start is held
			jmp state_menu_pause
		:
	:

	; Update evilDheeg position
	ldx $0213
	dex
	stx $0213

	jsr func_handle_interactions

	inc clock
	jsr func_vblank_wait
jmp @forever
