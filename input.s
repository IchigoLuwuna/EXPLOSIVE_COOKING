cport1 = $4016  ; hardware address of controller port 1
cport2 = $4017  ; hardware address of controller port 1

func_get_input:
    ; not pushing register because function is called at start of loop

    ; function start
    lda joypad  ; save previous joypad state
    sta joypad_previous

    ; get joypad input
    ; poll controller 1 input
    lda #$01
    sta cport1  ; write 1 to controller port 1 to start polling input data
    lda #$00
    sta cport1  ; write 0 to controller port 1 to end polling input data/lip

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

    ; get zapper input
    ; poll controller 1 input
    lda #$01
    sta cport2  ; write 1 to controller port 1 to start polling input data
    lda #$00
    sta cport2  ; write 0 to controller port 1 to end polling input data/lip

    lda cport2
	sta zapper ; shifts carry left into joypad
	; bit order is [ /, /, /, Trigger, Light, /, /, Serial data]
	; 			   [ 7, 6, 5,       4,     3, 2, 1,           0]
    ; Trigger: 0 is released or pulled, 1 is half pulled
    ; Light: 0 is detected, 1 not detected

    ; function end

    rts ; return from subroutine