.segment "HEADER"
	; .byte "NES", $1A      ; iNES header identifier
	.byte $4E, $45, $53, $1A
	.byte 2               ; 2x 16KB PRG code
	.byte 1               ; 1x  8KB CHR data
	.byte $01, $00        ; mapper 0, vertical mirroring

.segment "ZEROPAGE_DATA"
	reg_b = $00 ; 1bt: extra B register
	reg_c = $01 ; 1bt: extra C register
	reg_d = $02 ; 1bt: extra D register
	reg_swap = $FF ; 1bt: volatile register
	game_flags = $03 ; 1bt: extra flags
		; 0 and 1: gamestate
			; %00 = menu
			; %01 = playing
			; %10 = win
			; %11 = lose
		; 2: zapper half-pulled
	game_flags_mask_gamestate = %00000011
	game_flags_mask_zapper = %00000100
	clock = $04 ; 1bt: Clock counter
	lfsr = $05  ; 1bt: linear feedback shift register (used for rng)
	joypad = $10 ; 1bt: Controller readout
	zapper = $11 ; 1bt: Zapper readout

.segment "VECTORS"
	;; When an NMI happens (once per frame if enabled) the label nmi:
	.addr nmi
	;; When the processor first turns on or is reset, it will jump to the label reset:
	.addr reset
	;; External interrupt IRQ (unused)
	.addr $00

; "nes" linker config requires a STARTUP section, even
; if it's empty
.segment "STARTUP"

; Main code segment for the program
.segment "CODE"
reset:
	sei		; disable IRQs
	cld		; disable decimal mode
	ldx #$40
	stx $4017	; disable APU frame IRQ
	ldx #$ff 	; Set up stack
	txs		;  .
	inx		; now X = 0
	stx $2000	; disable NMI
	stx $2001 	; disable rendering
	stx $4010 	; disable DMC IRQs

;; first wait for vblank to make sure PPU is ready
jsr func_vblank_wait

clear_memory:
	lda #$00
	sta $0000, x
	sta $0100, x
	sta $0200, x
	sta $0300, x
	sta $0400, x
	sta $0500, x
	sta $0600, x
	sta $0700, x
	inx
	bne clear_memory

;; second wait for vblank, PPU is ready after this

; load palettes into PPU
load_palettes:
	lda $2002
	lda #$3f
	sta $2006
	lda #$00
	sta $2006
	ldx #$00
	@loop:
		lda palettes, x
		sta $2007
		inx
		cpx #$20
		bne @loop

jsr func_vblank_wait

enable_rendering:
	lda #%10000000	; Enable NMI
	sta $2000
	lda #%00010000	; Enable Sprites
	sta $2001

; Game Start
jmp state_menu_start

; Subroutines
func_vblank_wait:
	php
	pha

	@loop:
		bit $2002
		bpl @loop

	pla
	plp
	rts

nmi:
	; push state before interrupt
	php
	pha
	txa
	pha
	tya
	pha

	; copy Shadow OAM to PPU OAM
	ldx #$02 ; Shadow OAM is on page 2
	stx $4014 ; write to OAMDMA PPU register at hardware address $4014

	; pull state after interrupt
	pla
	tay
	pla
	tax
	pla
	plp
	rti

dheeg:
	dheeg_16x16_addr = $00
	dheeg_top_left: .byte $00, $00, $00, $00
	dheeg_top_right: .byte $00, $00, $00, $00
	dheeg_bottom_left: .byte $00, $00, $00, $00
	dheeg_bottom_right: .byte $00, $00, $00, $00

evilDheeg:
	.byte $80 , $00 , $00 , $F0; y , x , tile , attr
evilDheeg2:
  .byte $40, $10, $01, $F0  ; Enemy 2
; Includes
.include "bitmasks.s"
.include "input.s"
.include "random.s"
.include "game.s"
.include "menus.s"
.include "palettes.s"
.include "sprite_utils.s"
.include "math.s"

; Character memory
.segment "CHARS"
	.incbin "character_rom.chr"
