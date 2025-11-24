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
	stx reg_swap
	adc reg_swap ; add with X
	sta $0203, y
	tya ; put Y back into A

	; pull Y
	sta reg_swap ; put A into swap
	pla ; pull Y from the stack
	tay
	lda reg_swap ; pull A from swap
	;

	; push X
	sta reg_swap ; put A into swap
	txa
	pha ; put X on the stack
	lda reg_swap ; pull A from swap
	;

	; Move by y
	tax ; put A into X so we can use to offset $0200
	lda $0200, x
	sty reg_swap
	adc reg_swap ; add with Y
	sta $0200, x
	txa ; put X back into A
	;

	; pull X
	sta reg_swap ; put A into swap
	pla ; pull X from the stack
	tax
	lda reg_swap ; pull A from swap
	;
rts
