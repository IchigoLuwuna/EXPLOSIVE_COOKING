; input memory is mapped in zero-page
; starting at $00

; func_template:
;    ; push registers
;    php     ; push processor
;    pha     ; push a
;    txa     ; push x
;    pha
;    tya     ; push y
;    pha
;
;    ; function
;
;
;    ; pull registers
;    pla     ; pull y
;    tay
;    pla     ; pull x
;    tax
;    pla     ; pull a
;
;   rts ; return from subroutine

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
    lda cport1  ; read controller port 1 (first bit of button data) and write to a
    asl         ; shift register a to the left
    ora cport1  ; read second bit and write to a
    asl         ; shift
    ora cport1  ; third bit
    asl
    ora cport1  ; fourth bit
    asl
    ora cport1  ; fifth bit
    asl
    ora cport1  ; sixth bit
    asl
    ora cport1  ; seventh bit
    asl
    ora cport1  ; eigth bit, don't shift after this one
                ; A is now [123465678] where 1 is first bit read and 8 last bit read
    
    sta joypad  ; store button data in joypad location ($00)

    ; function end

    ; pull registers
    pla     ; pull y
    tay
    pla     ; pull x
    tax
    pla     ; pull a

    rts ; return from subroutine