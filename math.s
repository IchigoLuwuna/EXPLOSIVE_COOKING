; General math utilities
; Input variables are listed at the end of labels
;           Here
;           |
;           V
; func_mult_ax
; Output is usually in A

; Opposite of A
func_opposite_a:
	eor #%11111111 ; flip all the bits
	clc
	adc #$01 ; add 1
	clc ; clear carry
rts
