game_sub_state_zap:

; Set oam mirror to zapper page
lda #$03
sta reg_oam_addr

; Flush OAM
ldy #$00
:
	lda #$00
	sta $0300, y
	iny
bne :-

; Display black frame
jsr func_vblank_wait



game_sub_state_zap_return:
lda #$02
sta reg_oam_addr
rts
