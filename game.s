state_game:
state_game_init:
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
		lda dheeg_top_left, y
		sta $0200, y
		iny
	cpy #$04
	bmi :-

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
		ldx $0203 ; move dheeg to the right
		inx
		stx $0203
	:
	lda joypad
	and #PAD_LEFT
	cmp #PAD_LEFT
	bne :+
		ldx $0203 ; move dheeg to the left
		dex
		stx $0203
	:
	lda joypad
	and #PAD_DOWN
	cmp #PAD_DOWN
	bne :+
		ldx $0200 ; move dheeg downwards
		inx
		stx $0200
	:
	lda joypad
	and #PAD_UP
	cmp #PAD_UP
	bne :+
		ldx $0200 ; move dheeg upwards
		dex
		stx $0200
	:
	lda joypad
	and #PAD_START
	cmp #PAD_START
	bne :+
		and reg_c
		cmp #PAD_START
		beq :+ ; skip if start is held
		jmp state_menu_pause
	:

	jsr func_vblank_wait
jmp @forever
