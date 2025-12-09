state_game:
state_game_init:
	jsr func_seed_random

    lda #$00
    sta enemy_alive ; all enemies alive (0 = alive)

	; Flush OAM
	ldy #$00
	:
		lda #$00
		sta $0200, y
		iny
	cpy #$FF
	bne :-



	; Initialize OAM
	ldy #$00
	:
		lda dheeg, y
		sta $0200, y
		iny
	cpy #$10
	bmi :-


;-------- Copy enemy sprites to OAM and randomize---------
	ldy #$00
copy_enemies_to_oam:
    lda evilDheegs, y
    sta $0210, y      ; $0210 = shadow OAM for enemies
    iny
    cpy #$20           ; 16 bytes per enemy * 2 enemies = 32
    bne copy_enemies_to_oam



	ldy #$00


	randomize_enemies:
	jsr func_random_to_acc
	and #%01111111
	sta $0210
	lda $0210
	clc
	adc #8
	sta $0214
	sta $0218
	adc #8
	sta $021C

	jsr func_random_to_acc
	and #%01111111
	sta $0220
	lda $0220
	clc
	adc #8
	sta $0224
	sta $0228
	adc #8
	sta $022C
;-----------------------------------------------------------

	ldx #$7F
	ldy #$7F
	lda dheeg_16x16_addr
	jsr func_move_16x16


    jsr draw_background  ; rendering off inside


    lda #%10000000 
    sta $2000
    lda #%00011110 ; enables sprites, background, leftmost 8 pixels
    sta $200

; allows jumping without reinitialising
state_game_loop:
forever:
	lda joypad
	sta reg_c ; store state of joypad on previous frame in reg_c -> allows for non-repeating actions on held input
	lda zapper
	sta reg_d ; store state of zapper on previous frame
	jsr func_get_input	; get controller input and store in joypad ($00)

	; Read zapper
	lda reg_d
	and #ZAPPER_HALF_PULLED
	cmp #ZAPPER_HALF_PULLED ; if was half pulled last frame
	bne :++
		lda zapper
		and #ZAPPER_HALF_PULLED
		cmp #00 ; if not half pulled this frame
		bne :+
			jsr game_sub_state_zap
		:
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
	bne :+++
		and reg_c
		cmp #PAD_START
		beq :++ ; skip if start is held
			:
			jmp :-
		:
	:

   lda #0
    sta reg_d              ; enemy index = 0

enemy_loop:
    ldy reg_d              ; A = enemy index
    lda enemy_alive
    and enemy_mask,y         ; mask bit
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

enemy_skip:
    inc reg_d
    lda reg_d
    cmp #2
    bne enemy_loop

	jsr func_handle_interactions

	inc clock
	jsr func_vblank_wait
jmp forever
