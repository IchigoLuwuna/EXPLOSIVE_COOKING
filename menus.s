.segment "CODE"
state_menu_start:
state_menu_start_init:
	; Flush OAM
	ldy #$00
@flush:
	lda #$00
	sta $0200, y
	iny
	cpy #$FF
	bmi @flush


    ; Drawing menu the middle

	lda #$20        ; high byte of $2000
	sta $2006
	lda #$AE        ; low byte
	sta $2006

	; Set scroll to 0,0 
	lda #$00
	sta $2005
	lda #$00
	sta $2005

	ldx #$00        
menu_text_loop:
    lda menu_text, x
    sta $2007      ; write tile to PPU
    inx
    cpx #4
    bne menu_text_loop

	; Enable NMI and rendering
	lda #%10000000   ; enable NMI
	sta $2000
	lda #%00011110   ; show background + sprites 
	sta $2001

state_menu_start_loop:
@forever:
	jsr func_get_input	; get controller input and store in joypad ($00)
	lda joypad
	and #PAD_START
	cmp #PAD_START
	bne :+
		and reg_c
		cmp #PAD_START
		beq @loop_continue   ; if Start not pressed, stay in loop

		jmp state_game
	:

@loop_continue:
	jsr func_vblank_wait    ; wait for vblank
	jmp @forever            ; loop again


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


menu_text:
    .byte 18, 9, 19, 26  ; M E N U
