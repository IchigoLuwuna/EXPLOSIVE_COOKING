state_game:
state_game_init:
	; Initialize OAM
	@loop:
		lda dheeg_top_left, y
		sta $0200, y
		iny
	cpy #$04
	bmi @loop


@forever:
	jsr func_get_input	; get controller input and store in joypad ($00)
	lda joypad
	and #%10000000
	cmp #%10000000
	bne :+
		ldx $0203 ; move dheeg to the right
		inx
		stx $0203
	:
	lda joypad
	and #%01000000
	cmp #%01000000
	bne :+
		ldx $0203 ; move dheeg to the left
		dex
		stx $0203
	:
	lda joypad
	and #%00100000
	cmp #%00100000
	bne :+
		ldx $0200 ; move dheeg downwards
		inx
		stx $0200
	:
	lda joypad
	and #%00010000
	cmp #%00010000
	bne :+
		ldx $0200 ; move dheeg upwards
		dex
		stx $0200
	:

	jsr func_vblank_wait
jmp @forever
