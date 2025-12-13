FAMISTUDIO_CFG_EXTERNAL     = 1
FAMISTUDIO_CFG_SFX_SUPPORT  = 1
FAMISTUDIO_CFG_SFX_STREAMS     = 1
FAMISTUDIO_USE_VOLUME_TRACK     = 1
FAMISTUDIO_USE_PITCH_TRACK     = 1
FAMISTUDIO_USE_SLIDE_NOTES     = 1
FAMISTUDIO_USE_RELEASE_NOTES     = 1

.define FAMISTUDIO_CA65_ZP_SEGMENT ZEROPAGE
.define FAMISTUDIO_CA65_ZP_SEGMENT BSS
.define FAMISTUDIO_CA65_ZP_SEGMENT CODE

.include "famistudio_ca65.s"


; initialize sfx and music for famistudio
func_audio_init:
    lda #$00
    ldx #.lobyte(sfx_data)
    ldy #.hibyte(sfx_data)
    jsr famistudio_sfx_init
    rts