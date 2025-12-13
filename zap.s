; Pauses the game to detect if an enemy got hit by the zapper
; Returns a mask that corresponds to the enemy slot that got hit
; Hi -> hit
; Lo -> not hit
; Return value is put into B
game_sub_state_zap:
; Acts as the "initialisation" of this state
; Ensures rendering is safely switched to zap detection
game_sub_state_zap_enter:
	; Disable NMI
	lda #%00000000 ; set bit 7 (NMI enable) to false
	sta $2000

	; Disable sprites and bg
	lda #%00000000 ; set bit 3 (render bg) and 4 (render sprites) to 0
	sta $2001

	; Set oam mirror to zapper page
	lda #$03
	sta reg_oam_addr

	; Flush page $03
	ldy #$00
	:
		lda #$00
		sta $0300, y
	iny
	bne :-

	; Fill page $03 with white squares representing enemies
	ldy #$00
	:
		; Select sprite & palette
		lda #$10 ; select tile 16
		sta $0301, y
		lda #%00000011 ; select sprite palette 3 -> black & white
		sta $0302, y
		lda #$10 ; select tile 16
		sta $0305, y
		lda #%00000011 ; select sprite palette 3 -> black & white
		sta $0306, y
		lda #$10 ; select tile 16
		sta $0309, y
		lda #%00000011 ; select sprite palette 3 -> black & white
		sta $030A, y
		lda #$10 ; select tile 16
		sta $030D, y
		lda #%00000011 ; select sprite palette 3 -> black & white
		sta $030E, y

		; Copy over position
		lda $0210, y ; Y top left
		sta $0300, y
		lda $0213, y ; X top left
		sta $0303, y

		lda $0214, y ; Y top right
		sta $0304, y
		lda $0217, y ; X top right
		sta $0307, y

		lda $0218, y ; Y bottom left
		sta $0308, y
		lda $021B, y ; X bottom left
		sta $030B, y

		lda $021C, y ; Y bottom right
		sta $030C, y
		lda $021F, y ; X bottom right
		sta $030F, y

		clc
	tya
	adc #$10
	tay
	cpy #$80 ; loop over all 8 enemies
	bne :-

	; Enable NMI
	lda #%10000000 ; set bit 7 (NMI enable) to true
	sta $2000

; Display black frame
jsr func_vblank_wait

; Enable sprites
lda #%00010000 ; set bit 4 (render sprites) to 1
sta $2001

; Initial test to early out in case of a miss
jsr func_is_light_detected

cmp reg_b
beq :+; return if missed
	jmp game_sub_state_zap_return ; relative address is too far so I had to get creative
:

; Hit detected -> single out enemy
; We use binary search to speed this up
lda #$FF ; prepare y position off-screen
sta $0340
sta $0344
sta $0348
sta $034C ; enemy slot 4

sta $0350
sta $0354
sta $0358
sta $035C ; enemy slot 5

sta $0360
sta $0364
sta $0368
sta $036C ; enemy slot 6

sta $0370
sta $0374
sta $0378
sta $037C ; enemy slot 7

; Display first 4 enemies
jsr func_is_light_detected

cmp reg_b
beq :+
	jmp game_sub_state_zap_l ; no hit -> go to left side
:                            ; else -> continue to right side

; enemies 0-3
game_sub_state_zap_r:
	lda #$FF ; prepare y position off-screen
	sta $0320
	sta $0324
	sta $0328
	sta $032C ; enemy slot 2

	sta $0330
	sta $0334
	sta $0338
	sta $033C ; enemy slot 3

	; wait for vblank to ensure syncing
	jsr func_vblank_wait

	jsr func_is_light_detected
	cmp reg_b
	bne game_sub_state_zap_rl ; no hit -> go to left side
							; else -> continue to right side

game_sub_state_zap_rr:
	lda #$FF ; prepare y position off-screen
	sta $0310
	sta $0314
	sta $0318
	sta $031C ; enemy slot 1

	; wait for vblank to ensure syncing
	jsr func_vblank_wait

	jsr func_is_light_detected
	cmp reg_b
	bne :+
	; if light is not detected
		; case rrr
		lda #%00000001 ; enemy slot 0
		sta reg_b
		jmp game_sub_state_zap_return ; return
	:
	; else
		; case rrl
		lda #%00000010 ; enemy slot 1
		sta reg_b
		jmp game_sub_state_zap_return ; return

game_sub_state_zap_rl:
	; Restore enemy slot 2
	lda $0230
	sta $0320
	lda $0234
	sta $0324
	lda $0238
	sta $0328
	lda $023C
	sta $032C

	lda #$FF ; prepare y position off-screen
	sta $0300
	sta $0304
	sta $0308
	sta $030C ; enemy slot 0

	sta $0310
	sta $0314
	sta $0318
	sta $031C ; enemy slot 1

	; wait for vblank to ensure syncing
	jsr func_vblank_wait

	jsr func_is_light_detected
	cmp reg_b
	bne :+
	; if light is not detected
		; case rlr
		lda #%00000100 ; enemy slot 2
		sta reg_b
		jmp game_sub_state_zap_return ; return
	:
	; else
		; case rll
		lda #%00001000 ; enemy slot 3
		sta reg_b
		jmp game_sub_state_zap_return ; return

; enemies 4-7
game_sub_state_zap_l:
	; Restore enemy slot 4
	lda $0250
	sta $0340
	lda $0254
	sta $0344
	lda $0258
	sta $0348
	lda $025C
	sta $034C

	; Restore enemy slot 5
	lda $0250
	sta $0340
	lda $0254
	sta $0344
	lda $0258
	sta $0348
	lda $025C
	sta $034C

	; Hide enemies 0-3
	lda #$FF ; prepare y position off-screen
	sta $0300
	sta $0304
	sta $0308
	sta $030C ; enemy slot 0

	sta $0310
	sta $0314
	sta $0318
	sta $031C ; enemy slot 1

	sta $0320
	sta $0324
	sta $0328
	sta $032C ; enemy slot 2

	sta $0330
	sta $0334
	sta $0338
	sta $033C ; enemy slot 3

	; wait for vblank to ensure syncing
	jsr func_vblank_wait

	jsr func_is_light_detected
	cmp reg_b
	bne game_sub_state_zap_ll ; no hit -> go to left side
							; else -> continue to right side

game_sub_state_zap_lr:
	; Hide enemy 5
	lda #$FF ; prepare y position off-screen
	sta $0350
	sta $0354
	sta $0358
	sta $035C ; enemy slot 5

	; wait for vblank to ensure syncing
	jsr func_vblank_wait

	jsr func_is_light_detected
	cmp reg_b
	bne :+
	; if light is not detected
		; case lrr
		lda #%00010000 ; enemy slot 4
		sta reg_b
		jmp game_sub_state_zap_return ; return
	:
	; else
		; case lrl
		lda #%00100000 ; enemy slot 5
		sta reg_b
		jmp game_sub_state_zap_return ; return

game_sub_state_zap_ll:
	; Restore enemy slot 6
	lda $0270
	sta $0360
	lda $0274
	sta $0364
	lda $0278
	sta $0368
	lda $027C
	sta $036C

	; Hide enemies 4 & 5
	lda #$FF ; prepare y position off-screen
	sta $0340
	sta $0344
	sta $0348
	sta $034C ; enemy slot 4

	sta $0350
	sta $0354
	sta $0358
	sta $035C ; enemy slot 5

	; wait for vblank to ensure syncing
	jsr func_vblank_wait

	jsr func_is_light_detected
	cmp reg_b
	bne :+
	; if light is not detected
		; case lrr
		lda #%01000000 ; enemy slot 6
		sta reg_b
		jmp game_sub_state_zap_return ; return
	:
	; else
		; case lrl
		lda #%10000000 ; enemy slot 7
		sta reg_b
		jmp game_sub_state_zap_return ; return

; Acts as the "destructor" of this state
; Makes sure that the game can propperly return to normal rendering and gameplay
game_sub_state_zap_return:
	lda #$02
	sta reg_oam_addr

	; Enable sprites and bg
	lda #%00011110 ; set bit 3 (render bg) and 4 (render sprites) to 1
	sta $2001
rts



; Constantly polls zapper and returns 1 if light is detected or 0 if it is not detected after an amount of frames (cycle count can be changed to decrease difficulty)
func_is_light_detected: ; return -> b
lda #$00
sta reg_b
ldy #$00 ; y -> vblank counter
func_is_light_detected_loop:
	jsr func_get_input
	lda zapper
	and #ZAPPER_LIGHT_NOT_DETECTED
	cmp #$00
	bne :+
		; Return after vblank
		lda #$01
		sta reg_b
		jmp func_is_light_detected_return
	:
	bit $2002
	bpl :+
		iny
		cpy #$01 ; show for 1 frames
		beq func_is_light_detected_return
	:

	jmp func_is_light_detected_loop
func_is_light_detected_return:
jsr func_vblank_wait
rts
