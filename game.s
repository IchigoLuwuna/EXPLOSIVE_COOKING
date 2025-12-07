state_game:
state_game_init:
	jsr func_seed_random

    lda #$10
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

    ldy reg_d              ; A = enemy index
                        ; Y = enemy index

    lda enemyflags
    and enemyMask,y         ; mask bit
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