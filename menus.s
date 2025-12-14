.segment "CODE"
state_menu_start:
    ;jmp state_game_init
state_menu_start_init:


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
    lda #$68      ; low byte (column 12)
    sta $2006

     ; ----------------------------
    ; Initialize arrow sprite
    ; ----------------------------

    
ldx #$00
@menu_loop:
    lda menu_text, x
    sta $2007
    inx
    cpx #18
    bne @menu_loop


	; Write START (row 12, col 13)
    lda $2002
    lda #$21
    sta $2006
    lda #$CD
    sta $2006

ldx #$00
@start_loop:
    lda start_text, x
    sta $2007
    inx
    cpx #6
    bne @start_loop





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
 ;Menu loop — handle arrow movement + selection
; ----------------------------
state_menu_start_loop:

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
		jmp state_game
	:

	jsr func_vblank_wait
jmp @forever
 

menu_text:
  .byte 9,29,21,17,20,24,13,27,9,0,7,20,20,15,13,19,11,4   ; " explosive cooking!"
start_text:
  .byte 62 ,24,25,5,23,25  ; " START"
exit_text:
  .byte 9,29,13,25      ; " EXIT"

arrow_oam:    .res 4   ; 4 bytes for 1 sprite: Y, tile, attributes, X
