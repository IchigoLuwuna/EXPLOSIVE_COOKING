cport1 = $4016  ; hardware address of controller port 1
cport2 = $4017  ; hardware address of controller port 1

func_get_input:
    ; push registers
    php     ; push processor
    pha     ; push a
    txa     ; push x
    pha
    tya     ; push y
    pha

    ; function start

    ; poll controller 1 input
    lda #$01
    sta cport1  ; write 1 to controller port 1 to start polling input data
    lda #$00
    sta cport1  ; write 0 to controller port 1 to end polling input data

    ; read controller 1 data
	ldx #$00 ; for(int i{}; i < 8; ++i)
	@loop:
		lda cport1
		lsr ; loads bit 0 into carry
		ror joypad ; shifts carry left into joypad
		inx
		cpx #$08
		bmi @loop
	; bit order is now [Right, Left, Down, Up, Start, Select, B, A]
	; 				   [    7,    6,    5,  4,     3,      2, 1, 0]

    ; function end

    ; pull registers
    pla     ; pull y
    tay
    pla     ; pull x
    tax
    pla     ; pull a
	plp

    rts ; return from subroutine
