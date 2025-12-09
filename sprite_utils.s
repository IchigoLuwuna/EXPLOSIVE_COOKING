; Move an arbitrary 16x16 sprite by an arbitrary x and y value
; A->Low byte of sprite address
; X->Handled as signed int, movement on X axis
; Y->Handled as signed int, movement on Y axis
func_move_16x16:
	; push Y
	sta reg_swap ; put A into swap
	tya
	pha ; put Y on the stack
	lda reg_swap ; pull A from swap
	;

	; Move by x
	tay ; put A into Y so we can use to offset $0203
	lda $0203, y
	clc
	stx reg_swap
	adc reg_swap ; add with X
	clc
	sta $0203, y
	tya ; put Y back into A

	; pull Y
	sta reg_swap ; put A into swap
	pla ; pull Y from the stack
	tay
	lda reg_swap ; pull A from swap
	;

	; Move by y
	tax ; put A into X so we can use to offset $0200
	lda $0200, x
	sty reg_swap
	adc reg_swap ; add with Y
	clc
	sta $0200, x
	;

	; Allign other subsprites
	; X contains base sprite location
	; Top-Right
	lda $0200, x
	sta $0204, x
	lda $0203, x
	adc #$08
	clc
	sta $0207, x
	; Bottom-Left
	lda $0200, x
	adc #$08
	clc
	sta $0208, x
	lda $0203, x
	sta $020b, x
	; Bottom-Right
	lda $0200, x
	adc #$08
	clc
	sta $020C, x
	lda $0203, x
	adc #$08
	clc
	sta $020F, x
rts

func_clear_nametable:
	; Disable rendering
	lda #$00
	sta $2000 ; disable nmi
	sta $2001 ; disable sprite & bg

	lda #$20 ; high byte of nametable
	sta $2006 ; write to PPUADDR
	lda #$00 ; low byte of nametable
	sta $2006 ; PPUADDR is now $2000

	lda #$00 ; prepare 0 to be written
	ldy #$00 ; prepare y to be index
	:
		sta $2007
	iny
	bne :-
	ldy #$00 ; prepare y to be index
	:
		sta $2007
	iny
	bne :-
	ldy #$00 ; prepare y to be index
	:
		sta $2007
	iny
	bne :-
	ldy #$00 ; prepare y to be index
	:
		sta $2007
	iny
	bne :-

	; Enable rendering
	lda #%00011000
	sta $2001 ; enable sprite & bg
	lda #%10000000
	sta $2000 ; enable nmi
rts



reset_scroll:
	; back to 0,0 scroll
    lda #$00
    sta $2005
    lda #$00
    sta $2005
	rts