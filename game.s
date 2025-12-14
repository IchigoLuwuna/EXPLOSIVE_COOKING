state_game:
state_game_init:
	jsr func_clear_nametable
	jsr func_seed_random
	jsr func_initialize_walls
	jsr func_initialize_cook


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
	init_oam_loop:
		lda dheeg, y
		sta $0200, y
		iny
		cpy #$10
	bmi init_oam_loop

	jsr enemies_init
	jsr init_ammo

	jsr func_init_button_prompts

	; Set player initial position
	lda #$00
	sta $0200
	sta $0203
	ldx #$75
	ldy #$68
	lda dheeg_16x16_addr
	jsr func_move_16x16



	jsr draw_background  ; rendering off inside


	lda #%10000000
    sta $2000
	lda #%00011110 ; enables sprites, background, leftmost 8 pixels
	sta $2001

	lda #$FF
	sta kitchen_hp ; set kitchen HP to max

	lda #$00
	sta clock ; reset clock

; allows jumping without reinitialising
state_game_loop:
forever:
	lda joypad
	sta joypad_previous; store state of joypad on previous frame -> allows for non-repeating actions on held input
	lda zapper
	sta reg_d ; store state of zapper on previous frame
	jsr func_get_input	; get controller input and store in joypad ($00)

	; Read zapper
	lda reg_d
	and #ZAPPER_HALF_PULLED
	cmp #ZAPPER_HALF_PULLED ; if was half pulled last frame
	bne :+
		lda zapper
		and #ZAPPER_HALF_PULLED
		cmp #00 ; if not half pulled this frame
		bne :+
			; zapper trigger is fully pulled
			lda ammo_count ; load ammo count to check if empty
			beq :+ ; skip if zero flag is set -> no ammo
			dec ammo_count ; decrease ammo count

			jsr game_sub_state_zap ; shoot >:D
			lda reg_b ; load into a -> sets 0 flag if reg_b is empty
			beq :+ ; skip if zero flag is set -> no enemy has been hit
				; an enemy has been hit
				jsr enemy_die
				
				; award 50 points for hitting an enemy
				lda #$05
				jsr add_score
				;
	:

	; Read joypad
	lda joypad
	and #PAD_RIGHT
	cmp #PAD_RIGHT
	bne :+
		ldx #$01
		ldy #$00
		jsr func_player_walls_collision
		cmp #$01
		beq :+
			lda #$00
			jsr func_move_16x16
	:
	lda joypad
	and #PAD_LEFT
	cmp #PAD_LEFT
	bne :+
		ldx #$FF ; -1
		ldy #$00
		jsr func_player_walls_collision
		cmp #$01
		beq :+
			lda #$00
			jsr func_move_16x16
	:

	lda joypad
	and #PAD_DOWN
	cmp #PAD_DOWN
	bne :+
		ldx #$00
		ldy #$01
		jsr func_player_walls_collision
		cmp #$01
		beq :+
			lda #$00
			jsr func_move_16x16
	:

	lda joypad
	and #PAD_UP
	cmp #PAD_UP
	bne :+
		ldx #$00
		ldy #$FF ; -1
		jsr func_player_walls_collision
		cmp #$01
		beq :+
			lda #$00
			jsr func_move_16x16
	:

	lda joypad
	and #PAD_START
	cmp #PAD_START
	bne :++
		and joypad_previous
		cmp #PAD_START
		beq :+ ; skip if start is held
			jmp state_menu_pause
		:
	:

	jsr func_handle_interactions

	jsr enemy_loop


	inc clock
	bne :+ ; if clock is 0
		; Award player 10 points for surviving 256 frames
		lda #$01
		jsr add_score ; add 10 to score
	:

	jsr func_vblank_wait
	jsr display_score   ; safe to write to PPU now
	jsr reset_scroll
jmp forever
