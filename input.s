CPORT1_ADDR = $4016  ; hardware address of controller port 1
CPORT2_ADDR = $4017  ; hardware address of controller port 1

; ---------------------------------------------
; get input from controller and zapper
; return: joypad state -> joypad (zpg)
; return: zapper state -> zapper (zpg)
; ---------------------------------------------
func_get_input:
    lda joypad  ; save previous joypad state
    sta joypad_previous

    ; ----------------------
    ; get joypad input
    ; ----------------------

    ; poll controller 1 input
    lda #$01    ; write 1 to controller port 1 to start polling input data
    sta CPORT1_ADDR
    lda #$00    ; write 0 to controller port 1 to end polling input data/lip
    sta CPORT1_ADDR

    ; read controller 1 data
	ldx #$00 ; for(int i{}; i < 8; ++i)
	@loop:
		lda CPORT1_ADDR
		lsr         ; loads next bit into carry
		ror joypad  ; shifts carry left into joypad
		inx
		cpx #$08
		bmi @loop
	; bit order is now [Right, Left, Down, Up, Start, Select, B, A]
	; 				   [    7,    6,    5,  4,     3,      2, 1, 0]

    ; ----------------------
    ; get zapper input
    ; ----------------------

    ; poll zapper input
    lda #$01    ; write 1 to controller port 2 to start polling input data
    sta CPORT2_ADDR
    lda #$00    ; write 0 to controller port 2 to end polling input data/lip
    sta CPORT2_ADDR

    lda CPORT2_ADDR
	sta zapper
	; bit order is [ /, /, /, Trigger, Light, /, /, Serial data]
	; 			   [ 7, 6, 5,       4,     3, 2, 1,           0]
    ; Trigger: 0 is released or pulled, 1 is half pulled
    ; Light: 0 is detected, 1 not detected

func_get_input_end:
    rts