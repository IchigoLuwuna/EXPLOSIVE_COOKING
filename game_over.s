.segment "CODE"
state_menu_lose_start:
    ;jmp state_game_init
state_menu_lose_start_init:


	; Disable rendering BEFORE VRAM writes
	lda #$00
	sta $2001


	; Wait for vblank so VRAM is safe to write
	jsr func_vblank_wait


	ldy #$00
@clear_oam:
    lda #$00
    sta $0200, y
    iny
    bne @clear_oam

    jsr func_clear_nametable


    ; Drawing menu the middle
	lda #$00
	sta $2000
	sta $2001


    ; Set scroll to 0,0

    lda #$00
    sta $2005
    lda #$00
    sta $2005

    lda $2002
    lda #$21      ; high byte (row 12)
    sta $2006
    lda #$6B    ; low byte (column 12)
    sta $2006


ldx #$00
@lose_loop:
    lda lose_text, x
    sta $2007
    inx
    cpx #9
    bne @lose_loop
    
	lda #$00
	sta $2005
	lda #$00
	sta $2005
    ; Re-enable NMI + rendering
    lda #%10000000
    sta $2000
    lda #%00011110
    sta $2001
; ----------------------------
 ;Menu lose loop 
; ----------------------------
state_menu_lose_loop:



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
 


lose_text:
    .byte 30,20,26,0,17,20,24,9,4  ; "YOU LOSE"
