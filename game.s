state_game:
state_game_init:
	jsr func_seed_random

    lda #$00
    sta enemyflags    ; all enemies alive (0 = alive)

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

   lda #0
    sta reg_d              ; enemy index = 0

enemy_loop:

    lda reg_d              ; A = enemy index
    tay                    ; Y = enemy index

    lda enemyflags
    and mask,y         ; mask bit
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

	inc clock
	jsr func_vblank_wait
jmp forever