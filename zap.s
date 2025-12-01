game_sub_state_zap:
; Set OAM clone to page 03
lda #$03
sta reg_oam_addr

jsr func_vblank_wait

game_sub_state_zap_return:
lda #$02
sta reg_oam_addr
rts
