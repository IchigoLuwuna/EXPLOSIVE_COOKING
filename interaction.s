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
STTN_POT_POSX = $10
STTN_POT_POSY = $10


; player
;   bool at_station     :: game flags bit 3
;   1bt station_index   :: zpg $20
;   1bt cooking_status  :: zpg $21
;       3 bools for materials, 5 bits for int count or buttons pressed
;   1bt bullets         :: zpg $22
;       type and amount

; player
PLR_POSX_ADDR = $0203
PLR_POSY_ADDR = $0200

INTERACT_OFFSET_PLS = $08
INTERACT_OFFSET_MNS = %11111000 ; -$08


handle_interactions:
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
    bmi :+  ; if y is outside range, skip other checks
    ; if x and y are within 8 pixels
    lda #MAT_SCRAP_INDEX    ; set station index to the one collided with
    sta station_index
    lda #AT_STATION         ; set at_station flag to true
    ora game_flags
    sta game_flags
    jmp input_handling
    :
    
    ; if x and y of every station are outside 8 pixel range
    jmp interaction_end
    
input_handling:
    ; input handling

    ; if at_station
    ;   switch(station_index)
    ;   case material:
    ;       if input grab
    ;           switch(material)
    ;               bool material = true
    ;       break
    ;   case station:
    ;       if input == required_input
    ;           ++cooking_status
    ;           required_input = new input
    ;       break
    ; else
    ;   reset cooking progress

interaction_end:
    rts
