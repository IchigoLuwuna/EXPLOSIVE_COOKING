.segment "CODE"
state_menu_start:
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
    cpy #$FF
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
    lda #$8E      ; low byte (column 12)
    sta $2006

     ; ----------------------------
    ; Initialize arrow sprite
    ; ----------------------------

    lda #$60        ; row 12 tile = 96
    sec
    sbc #$02        
    sta arrow_y
	lda #$60           ; column for X position
	sec
	sbc #$08           ; shift left to sit before text
	sta arrow_x

	lda #$20           ; CHR tile index for arrow
	sta arrow_tile
	lda #$00           ; start on first menu item
	sta menu_selection

ldx #$00
@menu_loop:
    lda menu_text, x
    sta $2007
    inx
    cpx #4
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



    lda $2002
    lda #$22
    sta $2006
    lda #$0E
    sta $2006

	ldx #$00
@exit_loop:
    lda exit_text, x
    sta $2007
    inx
    cpx #4
    bne @exit_loop

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
@forever:
    jsr func_get_input

    ; Move arrow UP
    lda joypad
    and #PAD_UP
    beq @check_down
    lda menu_selection
    sec
    sbc #1
    cmp #$00
    bmi @menu_selection_zero
    sta menu_selection
    jmp @check_down
@menu_selection_zero:
    lda #$00
    sta menu_selection

@check_down:
    lda joypad
    and #PAD_DOWN
    beq @update_arrow
    lda menu_selection
    cmp #1
    bcs @update_arrow
    clc
    adc #1
    sta menu_selection

; Update arrow Y position based on selection
@update_arrow:
    lda menu_selection
    cmp #$00
    beq @arrow_start
    lda #$80       ; Y for EXIT
    jmp @arrow_done
@arrow_start:
    lda #$70      ; Y for START
@arrow_done:
    sta arrow_y

; Write arrow sprite to shadow OAM
    lda arrow_y
    sta $0200        ; Y
    lda arrow_tile
    sta $0201        ; Tile
    lda #$00
    sta $0202        ; Attributes
    lda arrow_x
    sta $0203        ; X
    lda #$02
    sta $4014        ; DMA to OAM

; Check START button
; Check START button
    lda joypad
    and #PAD_START
    beq @wait_vblank        ; not pressed, skip
    lda reg_c
    and #PAD_START
    bne @wait_vblank        ; held from previous frame, skip

    ; Only start game if START is selected
    lda menu_selection
    cmp #$00                ; 0 = START
    bne @wait_vblank        ; if not START, do nothing
    jmp state_game           ; otherwise start game
@wait_vblank:
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


menu_text:
  .byte 18,9,19,26   ; " MENU"
start_text:
  .byte 0 ,24,25,5,23,25  ; " START"
exit_text:
  .byte 9,29,13,25      ; " EXIT"

  arrow_oam:    .res 4   ; 4 bytes for 1 sprite: Y, tile, attributes, X
