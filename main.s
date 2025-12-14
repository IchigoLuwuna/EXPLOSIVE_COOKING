.segment "HEADER"
	.byte "NES", $1A      ; iNES header identifier
	.byte $02             ; 2x 16KB PRG code
	.byte $01             ; 1x  8KB CHR data
	.byte $01, $00        ; mapper 0, vertical mirroring
	.byte $00, $01        ; PAL

.segment "ZEROPAGE_DATA"

	reg_b = $00 ; 1bt: extra B register
	reg_c = $01 ; 1bt: extra C register
	reg_d = $02 ; 1bt: extra D register
	reg_swap = $FF ; 1bt: volatile register
	reg_oam_addr = $0F ; stores OAM page, for zapper
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
	joypad_previous = $12 ; 1bt: Controller readout
	zapper = $11 ; 1bt: Zapper readout
	enemy_alive = $30 ; bit 0 = enemy 0, bit 1 = enemy 1

	station_index = $20
	cooking_status = $21 ; 1bt
		; 0, 1, 2, 3: times pressed
		; 4 and 5: %00=not cooking, %01=start succeeded, %10=forging succeeded
	bullets = $22
	material_inventory = $23
	required_materials = $24
	input_sequence = $25	; 4 x 2bits
		; bit 	7 6 5 4 3 2 1 0
		; input 3	2	1	0
		; 	%00 = up
		; 	%01 = right
		;	%10 = down
		; 	%11 = left

	menu_selection = $31  ; 0 = START, 1 = EXIT
	arrow_x = $32
	arrow_y = $33
	arrow_tile = $34

	first_wall_addr = $E0	; 16bt array
	enemy_mask = $40       ; one byte to hold bitmask
	ammo_count = $41 ; holds the amount of bullets (starts at max)
	L_byte = $42 ; low byte for the background
	H_byte = $43 ; high byte for the background
	score  = $44  ; uses $44, $45, $46
	update = $47  ; single byte
	temp   = $48  ; uses $48-$4D (6 bytes)

	kitchen_hp = $60 ; 1bt: contains the kitchen's HP
	enemyClock = $4E ; 8 bytes 4E - 55 


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
lda #$02
sta reg_oam_addr
jmp state_menu_start

; Subroutines
func_vblank_wait:
	@loop:
		bit $2002
		bpl @loop
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
	lda reg_oam_addr
	sta $4014 ; write to OAMDMA PPU register at hardware address $4014

	; pull state after interrupt
	pla
	tay
	pla
	tax
	pla
	plp
	rti

dheeg:
	dheeg_top_left: .byte $00, $01, $00, $00
	dheeg_top_right: .byte $00, $02, $00, $00
	dheeg_bottom_left: .byte $00, $03, $00, $00
	dheeg_bottom_right: .byte $00, $03, $40, $00
	dheeg_16x16_addr = $00

button_sprite: .byte $66, $05, $00, $4E


; Includes
.include "bitmasks.s"
.include "input.s"
.include "zap.s"
.include "random.s"
.include "game.s"
.include "menus.s"
.include "palettes.s"
.include "sprite_utils.s"
.include "math.s"
.include "interaction.s"
.include "collision.s"
.include "enemies.s"
.include "ammo_count.s"
.include "background.s"
.include "high_score.s"

; Binary Includes
bg:
    .incbin "lvlMap_Checked.nam"

; Character memory
.segment "CHARS"
	.incbin "spriteRom.chr"
