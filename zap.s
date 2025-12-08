game_sub_state_zap:

; Disable NMI
lda #%00000000 ; set bit 7 (NMI enable) to false
sta $2000

; Disable sprites and bg
lda #%00000000 ; set bit 3 (render bg) and 4 (render sprites) to 0
sta $2001

; Set oam mirror to zapper page
lda #$03
sta reg_oam_addr

; Enable NMI
lda #%10000000 ; set bit 7 (NMI enable) to true
sta $2000

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
cpy #$40 ; compare with 32
bne :-

; Display black frame
jsr func_vblank_wait

; Enable sprites
lda #%00010000 ; set bit 4 (render sprites) to 1
sta $2001

; Display zap frame
jsr func_vblank_wait

game_sub_state_zap_return:
lda #$02
sta reg_oam_addr

; Enable sprites and bg
lda #%00011000 ; set bit 3 (render bg) and 4 (render sprites) to 1
sta $2001

rts
