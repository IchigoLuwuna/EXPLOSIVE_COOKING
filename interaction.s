; material: scrap
MAT_SCRAP_INDEX =   %00000011
MAT_SCRAP_POSX =    $4E
MAT_SCRAP_POSY =    $66

; station: cooking pot
STTN_POT_INDEX =    %00000010
STTN_POT_POSX =     $6E
STTN_POT_POSY =     $66

; station: forge
STTN_FORGE_INDEX =  %00000100

; station: ammo
STTN_AMMO_INDEX =  %00000110

; player
PLR_POSX_ADDR = $0203
PLR_POSY_ADDR = $0200

INTERACT_HEIGHT = $10

;------------------------------
; requiredMaterials = random(0,255);
; inputSquence = random(0,255);
; cookingStatus = 0;
;------------------------------
func_initialize_cook:
    jsr func_random_to_acc
    sta required_materials

    jsr func_random_to_acc
    sta input_sequence

    lda #$00
    sta cooking_status

    rts


;------------------------------
; for(station in cooking_stations)
;   if(player.position within 8 pixels)
;       station_index = station.index
;       at_station = true
;       jmp input handling
; else
;   at_station = false
;
; if(station_index.isMaterial())
;   HandleMaterial();
; else
;   Cook()
;------------------------------
func_handle_interactions:
    ; get current cooking station index

    ; check material scrap
    lda #MAT_SCRAP_POSX
    sta reg_b
    lda #MAT_SCRAP_POSY
    sta reg_c
    lda #MAT_SCRAP_INDEX
    sta reg_d

    jsr func_check_station_collision
    cmp #$00
    beq :+
        jmp input_handling
    :

    ; check station pot
    lda #STTN_POT_POSX
    sta reg_b
    lda #STTN_POT_POSY
    sta reg_c
    lda #STTN_POT_INDEX
    sta reg_d
    
    jsr func_check_station_collision
    cmp #$00
    beq :+
        jmp input_handling
    :
    
    ; if x and y of every station are outside 8 pixel range
    lda #INV_AT_STATION     ; set at_station flag to false
    and game_flags
    sta game_flags
    jmp interaction_end     ; skip input handling
    
input_handling:
    ; if first bit is 1: handle material
    lda station_index
    and #%00000001
    cmp #%00000001
    bne :+
        jsr func_handle_material
        jmp interaction_end
    :
    ; else: cook
    jsr func_cook

interaction_end:
    rts


;------------------------------
; switch(cooking_status)
; {
;   case start:
;       if station_index == pot.index
;           if current_material == required_material
;               if a is held
;                   cooking_status.type = forging;
;       break;
;   case forging:
;       if station_index == forge.index
;           reg_a = GetForgeInput();
;
;           switch(reg_a)
;           {
;               case UP:
;                   if up is pressed and no other directional input
;                       ++cooking_status;
;                       if cooking_status == 3
;                           cooking_status.type = ready;
;                   break;
;               ...
;           }
;
;       break;
;   case ready:
;       if station_index == ammo.index
;           if a is held
;               FinishCook();
;       break;
; }
;------------------------------
func_cook:
    ; switch(cooking_status)
    lda cooking_status
    and #COOKING_STATUS_TYPE
    cmp #%00000000
    bne :++  ; case start:
        ; if station is pot: check required materials
        lda station_index
        cmp #STTN_POT_INDEX
        bne :+
            ; if current materials == required materials: check input
            lda required_materials
            cmp material_inventory
            bne :+
                ; if A is held: all checks succeeded -> set status to forging
                lda joypad
                and #PAD_A
                cmp #$00
                beq :+
                    ; set status to forging
                    lda cooking_status
                    and #%11001111
                    ora #%00010000
                    sta cooking_status
        :
        jmp cook_end    ; break
    :
    cmp #%00010000
    bne :++++++++++  ; case forging:
        ; if station is forge: check required input
        lda station_index
        cmp #STTN_FORGE_INDEX
        bne :+++++++++
            ; put next input into register A
            jsr func_get_cooking_input
            ; switch(reg_a)
            cmp #$00
            bne :++  ; case UP
                ; if pressing up and no other directional input: increment cooking status
                lda joypad
                and #%11110000
                cmp #PAD_UP
                bne :+
                    jmp cook_forge
                :
                jmp cook_end    ; break
            :
            cmp #$01
            bne :++  ; case RIGHT
                ; if pressing right and no other directional input: increment cooking status
                lda joypad
                and #%11110000
                cmp #PAD_RIGHT
                bne :+
                    jmp cook_forge
                :
                jmp cook_end    ; break
            :
            cmp #$02
            bne :++  ; case DOWN
                ; if pressing down and no other directional input: increment cooking status
                lda joypad
                and #%11110000
                cmp #PAD_DOWN
                bne :+
                    jmp cook_forge
                :
                jmp cook_end    ; break
            :
            cmp #$03
            bne :++  ; case LEFT
                ; if pressing left and no other directional input: increment cooking status
                lda joypad
                and #%11110000
                cmp #PAD_LEFT
                bne :+
                    jmp cook_forge
                :
                jmp cook_end    ; break
            :
        :
        jmp cook_end    ; break
    :
    cmp #%00100000
    bne :++  ; case ready:
        ; if station is ammo drop off zone: check required input
        lda station_index
        cmp #STTN_AMMO_INDEX
        bne :+
            lda joypad
            and #PAD_A
            cmp #PAD_A
            bne :+
                jsr func_finish_cook
                lda #$00
                sta cooking_status
        :
        jmp cook_end    ; break
    :
    jmp cook_end
cook_forge:
    lda cooking_status
    adc #$01
    clc
    sta cooking_status
    and #%00001111
    cmp #$03
    bne :+
        ; succeeded 4 inputs: set state to ready
        lda cooking_status
        and #%11001111
        ora #%00100000
        sta cooking_status
cook_end:
    rts

func_handle_material:
    lda station_index ; switch(station_index)
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
        rts ; break
    :

    rts


;------------------------------
;------------------------------
func_finish_cook:
    ; add bullets or something?
    rts


;------------------------------
; load the next input in the input sequence into register A
;------------------------------
func_get_cooking_input:
    lda input_sequence
    sta reg_b

@loop:
    lda cooking_status
    and #COOKING_STATUS_COUNTER
    cmp #$00
    beq :+
        sbc #$01
        clc
        lda reg_b
        lsr
        lsr
        sta reg_b
        jmp @loop
    :

    lda reg_b
    and #%00000011

    rts


;------------------------------
; reg_b: station x
; reg_c: station y
; reg_d: station index
; returns:
;       register A: #$00 if no collision, #$01 if collision
;------------------------------
func_check_station_collision:
    ; check x
    lda reg_b ; if(station x - player width - player x < 0)
    sec
    sbc #$10
    clc
    cmp PLR_POSX_ADDR
    bpl :+  ; if x is outside range, skip other checks
        lda reg_b ; if(station x + station width - player x > 0)
        adc #$10
        clc
        cmp PLR_POSX_ADDR
        bmi :+  ; if x is outside range, skip other checks
            ; check y
            lda reg_c ; if(station y - player height - player y < 0)
            sec
            sbc #$10
            clc
            cmp PLR_POSY_ADDR
            bpl :+  ; if y is outside range, skip other checks
                lda reg_c ; if(station y + station height - player y > 0)
                adc #$10
                clc
                cmp PLR_POSY_ADDR
                bmi :+
                    ; runs if x and y are within 8 pixels
                    lda reg_d    ; set station index to the one collided with
                    sta station_index
                    lda #AT_STATION         ; set at_station flag to true
                    ora game_flags
                    sta game_flags
                    lda #$01
                    rts
    :
    lda #$00
    rts