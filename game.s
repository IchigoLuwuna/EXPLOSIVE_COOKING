state_game:
state_game_init:

	jsr func_clear_nametable
	jsr func_seed_random


	jsr func_vblank_wait ; wait for safe vblank

	jsr enemies_init_timers

	; Flush shadow OAM
	@clear_oam:
		lda #$00
		sta $0200, y
		iny
		cpy #$00   ; loop until Y wraps from $FF to $00
		bne @clear_oam

	; Initialize OAM 
	ldy #$00
	: 
		lda dheeg, y 
		sta $0200, y 
		iny 
		cpy #$10
	bmi :- 

	jsr enemies_to_oam
	jsr enemies_init
	jsr init_ammo
	
	; Set player initial position
	ldx #$7F
	ldy #$7F
	lda dheeg_16x16_addr
	jsr func_move_16x16


 
	jsr draw_background  ; rendering off inside


	lda #%10000000 
    sta $2000
	lda #%00011110 ; enables sprites, background, leftmost 8 pixels
	sta $2001

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





	jsr enemy_loop
	
	inc clock
	jsr func_vblank_wait

jmp forever