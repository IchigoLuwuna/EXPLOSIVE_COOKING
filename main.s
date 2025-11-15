.segment "HEADER"

	; .byte "NES", $1A      ; iNES header identifier
	.byte $4E, $45, $53, $1A
	.byte 2               ; 2x 16KB PRG code
	.byte 1               ; 1x  8KB CHR data
	.byte $01, $00        ; mapper 0, vertical mirroring

.segment "ZEROPAGE_DATA"

	joypad = $00	; 1bt: joypad info saved in $00
	zapper = $01	; 1bt: zapper info saved in $01

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

.include "input.s"	; include inputs file

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
jsr subr_vblank_wait

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

jsr subr_vblank_wait

enable_rendering:
	lda #%10000000	; Enable NMI
	sta $2000
	lda #%00010000	; Enable Sprites
	sta $2001

initialize_oam:
	ldx dheegLittleGuy
	stx $0200
	ldy #$01
	ldx dheegLittleGuy, y
	stx $0201
	ldy #$02
	ldx dheegLittleGuy, y
	stx $0202
	ldy #$03
	ldx dheegLittleGuy, y
	stx $0203

forever:
	jsr func_get_input	; get controller input and store in joypad ($00)
	lda joypad
	cmp #$00
	beq :+

	ldx $0203 ; move dheeg to the right
	inx
	stx $0203
	:
	
	jsr subr_vblank_wait
	jmp forever

subr_vblank_wait:
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
	dheegLittleGuy: .byte $6c, $00, $00, $2e ; the man himself
	characterD: .byte $6c, $03, $00, $4e ; D

palettes:
	.include "palettes.s"

; Character memory
.segment "CHARS"
	.incbin "character_rom.chr"