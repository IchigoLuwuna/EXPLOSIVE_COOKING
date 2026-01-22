; ---------------------------------------------
; Interaction macros

; material: scrap
MAT_SCRAP_INDEX     = %00000011
MAT_SCRAP_POSX      = $6E
MAT_SCRAP_POSY      = $3E

; material: powder
MAT_POWDER_INDEX    = %00000101
MAT_POWDER_POSX     = $4E
MAT_POWDER_POSY     = $36

; material: plastic
MAT_PLASTIC_INDEX   = %00000111
MAT_PLASTIC_POSX    = $4E
MAT_PLASTIC_POSY    = $56

; station: cooking pot
STTN_POT_INDEX      = %00000010
STTN_POT_POSX       = $8E
STTN_POT_POSY       = $6E

; station: forge
STTN_FORGE_INDEX    = %00000100
STTN_FORGE_POSX     = $9E
STTN_FORGE_POSY     = $8E

; station: drop
STTN_DROP_INDEX     = %00000110
STTN_DROP_POSX      = $4E
STTN_DROP_POSY      = $9E

; player
PLR_POSX_ADDR       = $0203
PLR_POSY_ADDR       = $0200

INTERACT_SIZE       = $10
PLAYER_SIZE         = $10
; ---------------------------------------------



; ---------------------------------------------
; Initialize data for func_handle_interactions
func_initialize_cook:
    lda #$00
    sta material_inventory  ; materialInventory = 0;
    sta cooking_status      ; cookingStatus = 0;

    jsr func_random_to_acc  ; requiredMaterials = random(0,255);
    and #MATERIALS
    sta required_materials

    jsr func_random_to_acc  ; inputSquence = random(0,255);
    sta input_sequence

func_initialize_func_cook_end:
    rts
; ---------------------------------------------



; ---------------------------------------------
; Perform game logic for interactions between player1 and the kitchen
func_handle_interactions:
; for(station in cooking_stations)
;   if(player colliding with station.hitbox)
;       station_index = station.index
;       at_station = true
;   else
;       at_station = false
;       return
;
; if(station_index.isMaterial())
;   HandleMaterial();
; else
;   Cook()

    ; -----------------------
    ; get current cooking station index
    ; -----------------------

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

    ; check material powder
    lda #MAT_POWDER_POSX
    sta reg_b
    lda #MAT_POWDER_POSY
    sta reg_c
    lda #MAT_POWDER_INDEX
    sta reg_d

    jsr func_check_station_collision
    cmp #$00
    beq :+
        jmp input_handling
    :

    ; check material plastic
    lda #MAT_PLASTIC_POSX
    sta reg_b
    lda #MAT_PLASTIC_POSY
    sta reg_c
    lda #MAT_PLASTIC_INDEX
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

    ; check station forge
    lda #STTN_FORGE_POSX
    sta reg_b
    lda #STTN_FORGE_POSY
    sta reg_c
    lda #STTN_FORGE_INDEX
    sta reg_d

    jsr func_check_station_collision
    cmp #$00
    beq :+
        jmp input_handling
    :

    ; check station drop
    lda #STTN_DROP_POSX
    sta reg_b
    lda #STTN_DROP_POSY
    sta reg_c
    lda #STTN_DROP_INDEX
    sta reg_d

    jsr func_check_station_collision
    cmp #$00
    beq :+
        jmp input_handling
    :

    ; if not in range of any stations
    lda #INV_AT_STATION     ; set at_station flag to false
    and game_flags
    sta game_flags
    jmp func_handle_interactions_end     ; skip input handling

    ; -----------------------
    ; Handle input and game logic
    ; -----------------------
input_handling:
    lda station_index
    and #%00000001
    cmp #%00000001
    bne :+  ; if first bit is 1: handle material
        jsr func_handle_material
        jmp func_handle_interactions_end
    :       ; else: cook (handle station)
    jsr func_cook

func_handle_interactions_end:
    jsr func_update_button_prompt
    rts
; ---------------------------------------------



; ---------------------------------------------
; Handle input and interactions with stations
func_cook:
; switch(cooking_status)
; {
;   case start:
;       if station_index == pot.index
;           if a is held
;               if current_material == required_material
;                   cooking_status.type = forging;
;               else
;                   reset material inventory
;       return;
;
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
;                   return;
;               ...
;           }
;
;       return;
;
;   case ready:
;       if station_index == drop.index
;           if a is held
;               FinishCook();
;       return;
; }

    ; -------------------------
    ; switch(cooking_status)
    ; -------------------------
    lda cooking_status
    and #COOKING_STATUS_TYPE
    ; -------------------------
    ; case start:
    ; -------------------------
case_start:
    cmp #%00000000
    bne case_forging
        ; if station is pot: check input
        lda station_index
        cmp #STTN_POT_INDEX
        bne :++
            ; if A is held: check required materials
            lda joypad
            and #PAD_A
            cmp #$00
            beq :++
                ; if current materials == required materials: all checks succeeded -> set status to forging
                lda required_materials
                cmp material_inventory
                bne :+
                    ; set status to forging
                    lda cooking_status
                    and #%11001111
                    ora #%00010000
                    sta cooking_status
                    jmp func_cook_end    ; return
                :
                ; if current materials != required materials: wrong input -> reset material inventory
                lda #$00
                sta material_inventory
        :
        jmp func_cook_end    ; return
    ; -------------------------
    ; case forging:
    ; -------------------------
case_forging:
    cmp #%00010000
    bne case_ready
        ; if station is forge: check required input
        lda station_index
        cmp #STTN_FORGE_INDEX
        bne @switch2_end
            ; -------------------------
            ; switch(next_input)
            ; -------------------------
            jsr func_get_cooking_input
            ; -------------------------
            ; case UP:
            ; -------------------------
            cmp #$00
            bne :++
                ; if pressing up and no other directional input: increment cooking status
                lda joypad
                and #%11110000
                cmp #PAD_UP
                bne :+
                    jmp cook_forge
                :
                jmp func_cook_end    ; return
            :
            ; -------------------------
            ; case RIGHT:
            ; -------------------------
            cmp #$01
            bne :++
                ; if pressing right and no other directional input: increment cooking status
                lda joypad
                and #%11110000
                cmp #PAD_RIGHT
                bne :+
                    jmp cook_forge
                :
                jmp func_cook_end    ; return
            :
            ; -------------------------
            ; case DOWN:
            ; -------------------------
            cmp #$02
            bne :++
                ; if pressing down and no other directional input: increment cooking status
                lda joypad
                and #%11110000
                cmp #PAD_DOWN
                bne :+
                    jmp cook_forge
                :
                jmp func_cook_end    ; return
            :
            ; -------------------------
            ; case LEFT:
            ; -------------------------
            cmp #$03
            bne :++ 
                ; if pressing left and no other directional input: increment cooking status
                lda joypad
                and #%11110000
                cmp #PAD_LEFT
                bne :+
                    jmp cook_forge
                :
                jmp func_cook_end    ; return
            :
    @switch2_end:
        jmp func_cook_end    ; return
    ; -------------------------
    ; case ready:
    ; -------------------------
case_ready:
    cmp #%00100000
    bne @switch1_end
        ; if station is ammo drop off zone: check required input
        lda station_index
        cmp #STTN_DROP_INDEX
        bne :+
            lda joypad
            and #PAD_A
            cmp #PAD_A
            bne :+
                jsr func_finish_cook
                lda #$00
                sta cooking_status
        :
        jmp func_cook_end    ; return
    ; -------------------------
    ; end of switch
    ; -------------------------
@switch1_end:
    jmp func_cook_end    ; return
    
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
    :

func_cook_end:
    rts
; ---------------------------------------------



; ---------------------------------------------
; Handle input and interactions with materials
func_handle_material:
    ; -------------------------
    ; switch(station_index)
    ; -------------------------
    lda station_index
    ; -------------------------
    ; case scrap:
    ; -------------------------
    cmp #MAT_SCRAP_INDEX
    bne :++
        lda joypad                      ; if A is pressed
	    and #PAD_A
	    cmp #PAD_A
	    bne :+
            lda joypad_previous         ; if A was not pressed last frame
	        and #PAD_A
	        cmp #PAD_A
	        beq :+
                lda material_inventory  ; get 1 scrap
                ora #MATERIALS_SCRAP
                sta material_inventory
        :
        jmp func_handle_material_end    ; return
    :
    ; -------------------------
    ; case powder:
    ; -------------------------
    cmp #MAT_POWDER_INDEX
    bne :++
        lda joypad                      ; if A is pressed
	    and #PAD_A
	    cmp #PAD_A
	    bne :+
            lda joypad_previous         ; if A was not pressed last frame
	        and #PAD_A
	        cmp #PAD_A
	        beq :+
                lda material_inventory  ; get 1 powder
                ora #MATERIALS_POWDER
                sta material_inventory
        :
        jmp func_handle_material_end    ; return
    :
    ; -------------------------
    ; case plastic:
    ; -------------------------
    cmp #MAT_PLASTIC_INDEX
    bne :++
        lda joypad                      ; if A is pressed
	    and #PAD_A
	    cmp #PAD_A
	    bne :+
            lda joypad_previous         ; if A was not pressed last frame
	        and #PAD_A
	        cmp #PAD_A
	        beq :+
                lda material_inventory  ; get 1 plastic
                ora #MATERIALS_PLASTIC
                sta material_inventory
        :
        jmp func_handle_material_end    ; return
    :

func_handle_material_end:
    rts
; ---------------------------------------------



; ---------------------------------------------
; Gives rewards for finishing cooking successfuly and initializes next cook
func_finish_cook:
    ; add 3 bullets
    lda #$03
    jsr add_ammo

    jsr func_initialize_cook

func_finish_cook_end:
    rts
; ---------------------------------------------



; ---------------------------------------------
; Get the next input in the input sequence
; return: next input -> register A
func_get_cooking_input:
    lda input_sequence  ; reg_b = input_sequence
    sta reg_b
    lda cooking_status  ; reg_c = cooking_status.counter
    and #COOKING_STATUS_COUNTER
    sta reg_c

    ; for(index = reg_c; index != 0; --index)
@loop:
    lda reg_c
    cmp #$00
    beq :+
        sec         ; decrement counter
        sbc #$01
        clc
        sta reg_c

        lda reg_b   ; shift input sequence
        lsr
        lsr
        sta reg_b
        jmp @loop
    :

    lda reg_b
    and #%00000011

func_get_cooking_input_end:
    rts
; ---------------------------------------------



; ---------------------------------------------
; Check if colliding with station interaction hitbox
; param: hitbox.x -> register B
; param: hitbox.y -> register C
; param: station.index -> register D
; return: #$01 if collided, else #$00 -> regiser A
func_check_station_collision:
    ; check x
    lda reg_b ; if(hitbox.x - player.width - player.x < 0)
    sec
    sbc #PLAYER_SIZE
    clc
    cmp PLR_POSX_ADDR
    bpl :+  ; if x is outside range, skip other checks
        lda reg_b ; if(hitbox.x + station.width - player.x > 0)
        adc #INTERACT_SIZE
        clc
        cmp PLR_POSX_ADDR
        bmi :+  ; if x is outside range, skip other checks
            ; check y
            lda reg_c ; if(hitbox.y - player.height - player.y < 0)
            sec
            sbc #PLAYER_SIZE
            clc
            cmp PLR_POSY_ADDR
            bpl :+  ; if y is outside range, skip other checks
                lda reg_c ; if(hitbox.y + station.height - player.y > 0)
                adc #INTERACT_SIZE
                clc
                cmp PLR_POSY_ADDR
                bmi :+  ; if y is outside range, skip other checks
                    lda reg_d    ; set station index to the one collided with
                    sta station_index
                    lda #AT_STATION         ; set at_station flag to true
                    ora game_flags
                    sta game_flags
                    lda #$01
                    jmp func_check_station_collision_end
    :
    lda #$00

func_check_station_collision_end:
    rts
; ---------------------------------------------



; ---------------------------------------------
; Sprite macros
    BUTTON_OAM_ADDR         = $0290
    RECIPE_OAM_ADDR         = $0294
    INVENTORY_OAM_ADDR      = $02A4
    CRATE_LABELS_OAM_ADDR   = $02B4

    BUTTON_A_INDEX          = $05
    BUTTON_B_INDEX          = $06
    BUTTON_DOWN_INDEX       = $45
    BUTTON_RIGHT_INDEX      = $3E

    FLIP_HORIZONTALLY       = %01000000
    FLIP_VERTICALLY         = %10000000
; ---------------------------------------------



; ---------------------------------------------
; Initialize button prompt data in OAM
func_init_button_prompts:
    ; load defined bytes into OAM

    ; Button sprites
    ldy #$00
    :
        lda button_sprite, y
		sta BUTTON_OAM_ADDR, y
		iny
		cpy #$04
    bmi :-

	; Recipe sprites
    ldy #$00
    :
        lda recipe_sprites, y
		sta RECIPE_OAM_ADDR, y
		iny
		cpy #$0C
    bmi :-

	; Inventory sprites
	ldy #$00
	:
	lda inventory_sprites, y
	sta INVENTORY_OAM_ADDR, y
	iny
	cpy #$0C
	bmi :-

	; Crate labels sprites
    ldy #$00
    :
        lda label_sprites, y
		sta CRATE_LABELS_OAM_ADDR, y
		iny
		cpy #$0C
    bmi :-

func_init_button_prompts_end:
    rts
; ---------------------------------------------



; ---------------------------------------------
; Set button prompt type and location depending on current station
func_update_button_prompt:
    ; if(!at_station)
    ;       remove button;
    ;       return;
    lda game_flags
    and #AT_STATION
    cmp #AT_STATION
    beq :+
        lda #$FF    ; set y pos to top of screen so it's not visible
        sta BUTTON_OAM_ADDR
        jmp draw_required_materials_start
    :

    ; -------------------------
    ; switch(station_index)
    ; -------------------------
    lda station_index
    ; -------------------------
    ; case scrap:
    ; -------------------------
    cmp #MAT_SCRAP_INDEX
    bne :+
        lda #MAT_SCRAP_POSY - $0C
        sta BUTTON_OAM_ADDR + $00

        lda #BUTTON_A_INDEX
        sta BUTTON_OAM_ADDR + $01

        lda #$03
        sta BUTTON_OAM_ADDR + $02

        lda #MAT_SCRAP_POSX + $06
        sta BUTTON_OAM_ADDR + $03
        jmp draw_required_materials_start
    :
    ; -------------------------
    ; case powder:
    ; -------------------------
    cmp #MAT_POWDER_INDEX
    bne :+
        lda #MAT_POWDER_POSY - $04
        sta BUTTON_OAM_ADDR + $00

        lda #BUTTON_A_INDEX
        sta BUTTON_OAM_ADDR + $01

        lda #$03
        sta BUTTON_OAM_ADDR + $02

        lda #MAT_POWDER_POSX + $06
        sta BUTTON_OAM_ADDR + $03
        jmp draw_required_materials_start
    :
    ; -------------------------
    ; case plastic:
    ; -------------------------
    cmp #MAT_PLASTIC_INDEX
    bne :+
        lda #MAT_PLASTIC_POSY + $0C
        sta BUTTON_OAM_ADDR + $00

        lda #BUTTON_A_INDEX
        sta BUTTON_OAM_ADDR + $01

        lda #$03
        sta BUTTON_OAM_ADDR + $02

        lda #MAT_PLASTIC_POSX + $06
        sta BUTTON_OAM_ADDR + $03
        jmp draw_required_materials_start
    :
    ; -------------------------
    ; case pot:
    ; -------------------------
    cmp #STTN_POT_INDEX
    bne :+
        lda #STTN_POT_POSY + $04
        sta BUTTON_OAM_ADDR + $00

        lda #BUTTON_A_INDEX
        sta BUTTON_OAM_ADDR + $01

        lda #$03
        sta BUTTON_OAM_ADDR + $02

        lda #STTN_POT_POSX - $0A
        sta BUTTON_OAM_ADDR + $03
        jmp draw_required_materials_start
    :
    ; -------------------------
    ; case forge:
    ; -------------------------
    cmp #STTN_FORGE_INDEX
    bne :+++++
        lda #STTN_FORGE_POSY + $06
        sta BUTTON_OAM_ADDR + $00

        ; -------------------------
        ; switch(next_input)
        ; -------------------------
        jsr func_get_cooking_input
        ; -------------------------
        ; case UP:
        ; -------------------------
        cmp #%00000000
        bne :+
            lda #BUTTON_DOWN_INDEX      ; load down
            sta BUTTON_OAM_ADDR + $01

            lda #FLIP_VERTICALLY        ; flip
			ora #$03
            sta BUTTON_OAM_ADDR + $02

            jmp forge_button_switch_end ; return
        :
        ; -------------------------
        ; case RIGHT:
        ; -------------------------
        cmp #%00000001
        bne :+
            lda #BUTTON_RIGHT_INDEX     ; load right
            sta BUTTON_OAM_ADDR + $01

            lda #$03
            sta BUTTON_OAM_ADDR + $02

            jmp forge_button_switch_end ; return
        :
        ; -------------------------
        ; case DOWN:
        ; -------------------------
        cmp #%00000010
        bne :+
            lda #BUTTON_DOWN_INDEX      ; load down
            sta BUTTON_OAM_ADDR + $01

            lda #$03
            sta BUTTON_OAM_ADDR + $02

            jmp forge_button_switch_end ; return
        :
        ; -------------------------
        ; case LEFT:
        ; -------------------------
        cmp #%00000011
        bne :+
            lda #BUTTON_RIGHT_INDEX     ; load right
            sta BUTTON_OAM_ADDR + $01

            lda #FLIP_HORIZONTALLY      ; flip
			ora #$03
            sta BUTTON_OAM_ADDR + $02

            jmp forge_button_switch_end ; return
        :
        ; -------------------------
        ; end of switch
        ; -------------------------
    forge_button_switch_end:
        lda #STTN_FORGE_POSX + $16
        sta BUTTON_OAM_ADDR + $03
        jmp draw_required_materials_start
    :
    ; -------------------------
    ; case drop:
    ; -------------------------
    cmp #STTN_DROP_INDEX
    bne :+
        lda #STTN_DROP_POSY + $14
        sta BUTTON_OAM_ADDR + $00

        lda #BUTTON_A_INDEX
        sta BUTTON_OAM_ADDR + $01

        lda #$03
        sta BUTTON_OAM_ADDR + $02

        lda #STTN_DROP_POSX + $06
        sta BUTTON_OAM_ADDR + $03
        jmp draw_required_materials_start
    :
    ; -------------------------
    ; end of switch
    ; -------------------------
draw_required_materials_start:
	jsr func_update_recipe_prompt
	jsr func_update_inventory_display

func_update_button_prompt_end:
    rts
; ---------------------------------------------



; Updates the recipe displayed above the cooking pot
func_update_recipe_prompt:
	; Scrap check -> bit 0
	lda required_materials ; load in recipe mask
	and #$01 ; sets zero flag if bit 0 is clear
	beq :+ ; if set -> show; else -> hide
		lda recipe_scrap_sprite + $00
		sta RECIPE_OAM_ADDR + $00
		jmp :++ ; skip else
	:
		lda #$FF
		sta RECIPE_OAM_ADDR + $00
	:

	; Powder check -> bit 1
	lda required_materials ; load in recipe mask
	and #$02 ; sets zero flag if bit 1 is clear
	beq :+ ; if set -> show; else -> hide
		lda recipe_powder_sprite + $00
		sta RECIPE_OAM_ADDR + $04
		jmp :++ ; skip else
	:
		lda #$FF
		sta RECIPE_OAM_ADDR + $04
	:

	; Scrap check -> bit 2
	lda required_materials ; load in recipe mask
	and #$04 ; sets zero flag if bit 2 is clear
	beq :+ ; if set -> show; else -> hide
		lda recipe_plastic_sprite + $00
		sta RECIPE_OAM_ADDR + $08
		jmp :++ ; skip else
	:
		lda #$FF
		sta RECIPE_OAM_ADDR + $08
	:

	lda cooking_status ; get cooking status
	and #$F0 ; get last 4 bits
	beq :+ ; zero flag clear if cooking status is past material collection -> hide sprites
		lda #$FF
		sta RECIPE_OAM_ADDR + $00
		sta RECIPE_OAM_ADDR + $04
		sta RECIPE_OAM_ADDR + $08
	:

rts

func_update_inventory_display:
	; Scrap check -> bit 0
	lda material_inventory; load in recipe mask
	and #$01 ; sets zero flag if bit 0 is clear
	beq :+ ; if set -> show; else -> hide
		; Y position
		lda PLR_POSY_ADDR
		sec
		sbc #$0C
		clc
		sta INVENTORY_OAM_ADDR + $00
		lda PLR_POSX_ADDR

		; X position
		sec
		sbc #$04
		clc
		sta INVENTORY_OAM_ADDR + $03

		jmp :++ ; skip else
	:
		lda #$FF
		sta INVENTORY_OAM_ADDR + $00
	:

	; Powder check -> bit 1
	lda material_inventory ; load in recipe mask
	and #$02 ; sets zero flag if bit 1 is clear
	beq :+ ; if set -> show; else -> hide
		; Y position
		lda PLR_POSY_ADDR
		sec
		sbc #$0C
		clc
		sta INVENTORY_OAM_ADDR + $04

		; X position
		lda PLR_POSX_ADDR
		adc #$04
		clc
		sta INVENTORY_OAM_ADDR + $07

		jmp :++ ; skip else
	:
		lda #$FF
		sta INVENTORY_OAM_ADDR + $04
	:

	; Scrap check -> bit 2
	lda material_inventory ; load in recipe mask
	and #$04 ; sets zero flag if bit 2 is clear
	beq :+ ; if set -> show; else -> hide
		; Y position
		lda PLR_POSY_ADDR
		sec
		sbc #$0C
		clc
		sta INVENTORY_OAM_ADDR + $08

		; X position
		lda PLR_POSX_ADDR
		adc #$0C
		clc
		sta INVENTORY_OAM_ADDR + $0B

		jmp :++ ; skip else
	:
		lda #$FF
		sta INVENTORY_OAM_ADDR + $08
	:

	lda cooking_status ; get cooking status
	and #$F0 ; get last 4 bits
	beq :+ ; zero flag clear if cooking status is past material collection -> hide sprites
		lda #$FF
		sta INVENTORY_OAM_ADDR + $00
		sta INVENTORY_OAM_ADDR + $04
		sta INVENTORY_OAM_ADDR + $08
	:
rts
