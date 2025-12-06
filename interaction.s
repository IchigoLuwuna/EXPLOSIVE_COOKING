; station   :: in ROM
;   1bt index
;       even = station, odd is material
;   2bt position

; material: scrap
MAT_SCRAP_INDEX = %00000011
MAT_SCRAP_POSX = $10
MAT_SCRAP_POSY = $10

; station: cooking pot
STTN_POT_INDEX = %00000010
STTN_POT_POSX = $30
STTN_POT_POSY = $10

; player
;   bool at_station     :: game flags bit 3
;   1bt station_index   :: zpg $20
;   1bt cooking_status  :: zpg $21
;       int counter for times pressed
;   1bt material_inventory  :: zpg $23
;       bit 0, 1: scrap (0-3)
;       bit 2, 3: ... (0-3)
;   1bt bullets         :: zpg $22
;       type and amount

; player
PLR_POSX_ADDR = $0203
PLR_POSY_ADDR = $0200

INTERACT_OFFSET_PLS = $08
INTERACT_OFFSET_MNS = %11111000 ; -$08


func_handle_interactions:
    ; get current cooking station index

    ; for(station in cooking_stations)
    ;   if(player.position within 8 pixels)
    ;       station_index = station.index
    ;       at_station = true
    ;       jmp input handling
    ; at_station = false

    ; check x
    lda #MAT_SCRAP_POSX
    sbc PLR_POSX_ADDR
    clc
    cmp #INTERACT_OFFSET_PLS
    bpl :+  ; if x is outside range, skip other checks
        cmp #INTERACT_OFFSET_MNS
        bmi :+  ; if x is outside range, skip other checks
            ; check y
            lda #MAT_SCRAP_POSY
            sbc PLR_POSY_ADDR
            clc
            cmp #INTERACT_OFFSET_PLS
            bpl :+  ; if y is outside range, skip other checks
                cmp #INTERACT_OFFSET_MNS
                bmi :+
                    ; runs if x and y are within 8 pixels
                    lda #MAT_SCRAP_INDEX    ; set station index to the one collided with
                    sta station_index
                    lda #AT_STATION         ; set at_station flag to true
                    ora game_flags
                    sta game_flags
                    jmp input_handling
    :

    ; check x
    lda #STTN_POT_POSX
    sbc PLR_POSX_ADDR
    clc
    cmp #INTERACT_OFFSET_PLS
    bpl :+  ; if x is outside range, skip other checks
        cmp #INTERACT_OFFSET_MNS
        bmi :+  ; if x is outside range, skip other checks
            ; check y
            lda #STTN_POT_POSY
            sbc PLR_POSY_ADDR
            clc
            cmp #INTERACT_OFFSET_PLS
            bpl :+  ; if y is outside range, skip other checks
                cmp #INTERACT_OFFSET_MNS
                bmi :+
                    ; runs if x and y are within 8 pixels
                    lda #STTN_POT_INDEX    ; set station index to the one collided with
                    sta station_index
                    lda #AT_STATION         ; set at_station flag to true
                    ora game_flags
                    sta game_flags
                    jmp input_handling
    :
    
    ; if x and y of every station are outside 8 pixel range
    lda #INV_AT_STATION     ; set at_station flag to false
    and game_flags
    sta game_flags
    lda #$00                ; reset cooking_status
    sta cooking_status
    jmp interaction_end     ; skip input handling
    
input_handling:
    ; switch(station_index)
    lda station_index
    cmp #MAT_SCRAP_INDEX    ; case material_scrap:
    bne :++
        lda joypad                      ; if A is pressed
	    and #PAD_A
	    cmp #PAD_A
	    bne :+
            lda joypad_previous         ; if A was not pressed last frame
	        and #PAD_A
	        cmp #PAD_A
	        beq :+
                ldy material_inventory  ; get 1 scrap
                iny
                sty material_inventory
        :
        jmp interaction_end ; break
    :
    cmp #STTN_POT_INDEX     ; case station_pot:
    bne :+++
        lda joypad                      ; if Up is pressed
	    and #PAD_UP
	    cmp #PAD_UP
	    bne :++
            lda joypad_previous         ; if Up was not pressed last frame
	        and #PAD_UP
	        cmp #PAD_UP
	        beq :++
                lda cooking_status      ; increment cooking_status
                adc #$01
                clc
                cmp #$04                ; if pressed 4 or more times
                bne :+
                    jsr func_finish_cook    ; cooking successful
                    lda #$00                ; reset cooking_status
                :
                sta cooking_status
        :
        jmp interaction_end ; break
    :

interaction_end:
    rts



; not propery implemented yet
func_finish_cook:
    ; add bullets or something?
    lda bullets
    adc #$04
    clc
    sta bullets

    rts