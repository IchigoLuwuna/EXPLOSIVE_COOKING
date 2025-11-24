state_menu_start:
state_menu_start_init:
	; Flush OAM
	ldy #$00
	:
		lda #$00
		sta $0200, y
		iny
	cpy #$FF
	bmi :-

state_menu_start_loop:
@forever:
	jsr func_get_input	; get controller input and store in joypad ($00)
	lda joypad
	and #PAD_START
	cmp #PAD_START
	bne :+
		and reg_c
		cmp #PAD_START
		beq :+ ; skip if start is held
		jmp state_game
	:

	inc clock
	jsr func_vblank_wait
jmp @forever

state_menu_pause:
state_menu_pause_loop:
@forever:
	lda joypad
	sta reg_c ; store state of joypad on previous frame in reg_c -> allows for non-repeating actions on held input
	jsr func_get_input	; get controller input and store in joypad ($00)
	lda joypad
	and #PAD_START
	cmp #PAD_START
	bne :+
		and reg_c
		cmp #PAD_START
		beq :+ ; skip if start is held
		jmp state_game_loop
	:

	jsr func_vblank_wait
jmp @forever
