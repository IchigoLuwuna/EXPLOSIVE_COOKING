
enemies_init_timers:
    ldx #$00
init_loop:
    lda clock
    adc #$50              ; base delay
    clc
    adc enemyIntervals, x ; stagger start times
	clc
    sta enemyClock, x
    lda enemyIntervals, x
    sta enemyStep, x
    inx
    cpx #$08
    bne init_loop
    rts

enemies_to_oam:
    ldy #$00
@loop:
    lda evilDheegs, y
    sta $0210, y
    iny
    cpy #$80   ; 128 bytes for 8 enemies
    bne @loop
    rts




enemies_init:

	lda #$FF
	sta enemy_alive
    sta enemy_mask



	jsr func_random_to_acc      ; get random byte in A
	and #%01111111              ; limit to 0-127 (screen height)
	ldy #$00                     ; base sprite offset in OAM for enemy 0
	lda #$00
	jsr func_move_16x16          ; X=0, Y=A → only move vertically

	jsr func_random_to_acc
	and #%01111111
	ldy #$10                     ; base sprite offset in OAM for enemy 1 (next 16x16 block)
	lda #$00
	jsr func_move_16x16          ; X=0, Y=A
    rts
;--------------------------------------------------------




enemy_loop:
    lda #$00
    sta reg_d            ; enemy index

enemy_loop_start:
    lda reg_d
    cmp #$08
    beq enemy_done       ; all enemies done

    ldx reg_d
    lda enemy_alive
    and enemy_mask_table, x
    bne clock_check  ; skip if alive

    ldx reg_d
    lda enemy_mask_table, x  ; mask of this enemy
    ora enemy_alive           ; set its bit alive
    sta enemy_alive
    jsr enemy_respawn_random


clock_check:
    lda clock
    cmp enemyClock, x
    bcc skip_enemy   ; skip if clock < enemyClock if enemyClock > clock (not ready yet)
    ; --- Move enemy ---
    lda reg_d
    cmp #$04
    bcc move_right      ; enemies 0-3 → right

    ; enemies 4-7 → move left
move_left:
    lda reg_d
    asl
    asl
    asl
    asl
    adc #$10

    ; movement
    ldx #$FF
    ldy #$00

    jsr func_move_16x16
	jsr func_enemy_collision
    jmp enemy_continue
move_right:
    lda reg_d
    asl
    asl
    asl
    asl
    adc #$10
    clc
    ldx #$01
    ldy #$00
    jsr func_move_16x16
	jsr func_enemy_collision

enemy_continue:
    inc reg_d
    jmp enemy_loop_start

skip_enemy:
    inc reg_d
    jmp enemy_loop_start


enemy_done:
	jsr func_hide_dead_enemies
    rts


enemy_die: ; input -> B -> enemy mask
	; mark enemies as dead
	lda reg_b
	eor #$FF ; invert mask
	and enemy_alive ; AND masks together
    sta enemy_alive ; mark masked enemies dead
	
	; hide dead enemies
	jsr func_hide_dead_enemies

    rts

func_hide_dead_enemies:
	lda enemy_alive
	sta reg_b ; copy enemy_alive into B
	ldx #$08 ; amount of iterations
	ldy #$00 ; enemy offset

	func_hide_dead_enemies_loop:
		lda #$01
		and reg_b ; current enemy alive state is now in A. zero flag is also set if enemy is dead
		bne :+ ; skip if enemy is alive
			lda #$FF
			sta $0210, y
			sta $0214, y
			sta $0218, y
			sta $021C, y
		:
		lsr reg_b ; go to next enemy
		tya
		clc
		adc #$10 ; go to next enemy in OAM
		clc
		tay
		dex
		bne func_hide_dead_enemies_loop
    
	rts

enemy_respawn_random: ; needs reg_d to be index
	jsr func_random_to_acc
    and #%01111111   ; 0–127

    tay
    lda reg_d
    asl
    asl
    asl
    asl
    adc #$10
    clc

	ldy #$FF
    
	jsr func_move_16x16
    rts

func_enemy_collision:
	; /-----------------\
	; | Enemy collision |
	; \-----------------/
	lda reg_d
	asl
	asl
	asl
	asl ; convert index to offset (x16)
	sta reg_swap ; enemy offset is now in swap
	tax
	lda $0213, x
	tax
	lda reg_swap
	tay
	lda $0210, y
	tay

	lda reg_swap ; enemy offset needs to be stored for later
	pha
	lda reg_d ; enemy walls collision clobbers d so it has to be pushed
	pha

	jsr func_enemy_walls_collision
	sta reg_swap ; swap now contains returned variable

	pla
	sta reg_d ; restore d
	pla
	tay ; y now contains enemy offset
	lda reg_swap ; a now contains return code

	beq :+ ; if enemy hit wall
		dec kitchen_hp
		ldy reg_d ; get enemy index
		lda enemy_mask_table, y ; get current enemy mask
		sta reg_b ; put enemy mask into b
		jsr enemy_die
		;
	:
	; -------------------
rts

evilDheegs:

    amount_of_evilDheegs = $08 ; now 8 enemies

; Enemy 0 (left)
    .byte $80, $01, $01, $FF ; y tile attr x
    .byte $80, $02, $01, $FF
    .byte $88, $03, $01, $FF
    .byte $88, $03, $42, $FF

; Enemy 1 (left)
    .byte $90, $01, $01, $FF
    .byte $90, $02, $01, $FF
    .byte $98, $03, $01, $FF
    .byte $98, $03, $42, $FF

; Enemy 2 (left)
    .byte $A0, $01, $01, $FF
    .byte $A0, $02, $01, $FF
    .byte $A8, $03, $01, $FF
    .byte $A8, $03, $42, $FF

; Enemy 3 (left)
    .byte $B0, $01, $01, $FF
    .byte $B0, $02, $01, $FF
    .byte $B8, $03, $01, $FF
    .byte $B8, $03, $42, $FF

; Enemy 4 (right)
    .byte $80, $01, $01, $FF
    .byte $80, $02, $01, $FF
    .byte $88, $03, $01, $FF
    .byte $88, $03, $42, $FF

; Enemy 5 (right)
    .byte $90, $01, $01, $FF
    .byte $90, $02, $01, $FF
    .byte $98, $03, $01, $FF
    .byte $98, $03, $42, $FF

; Enemy 6 (right)
    .byte $A0, $01, $01, $FF
    .byte $A0, $02, $01, $FF
    .byte $A8, $03, $01, $FF
    .byte $A8, $03, $42, $FF

; Enemy 7 (right)
    .byte $B0, $01, $01, $FF
    .byte $B0, $02, $01, $FF
    .byte $B8, $03, $01, $FF
    .byte $B8, $03, $42, $FF


enemyIntervals:
    .byte $20, $40, $60, $80, $A0, $C0, $E0, $FF
enemyStep:
    .res 8   ; reserve 8 bytes for enemy intervals
enemy_mask_table:
    .byte %00000001
    .byte %00000010
    .byte %00000100
    .byte %00001000
    .byte %00010000
    .byte %00100000
    .byte %01000000
    .byte %10000000
