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

	ldy #$00
	:
		lda evilDheegs,y
		sta $0210, y
		iny
	cpy #$08
	bmi :-
	



	ldx #$7F
	ldy #$7F
	lda dheeg_16x16_addr
	jsr func_move_16x16

; allows jumping without reinitialising
state_game_loop:
forever:
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

    ldx #$03           ; first enemy X byte (0210 + 3 = 0213)

move_enemies:
    lda $0210, x       ; load X from shadow OAM
    sec
    sbc #$01           ; X -= 1
    sta $0210, x       ; store back into shadow OAM

    inx
    inx
    inx
    inx                ; move to next enemy's X byte

    cpx #$0B           ; 3 + 8 = 11 -> past last X
    bne move_enemies

	inc clock
	jsr func_vblank_wait
jmp forever