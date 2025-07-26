; 32 bit frame counter that keeps incrementing as soon as the game starts.
; by Abdu

if read1($00FFD5) == $23
	sa1rom
	!bank = $000000
	!addr = $6000
else
	lorom
	!bank = $800000
	!addr = $0000
endif

; 6 byte freeram, only 4 bytes are used. Cleared on reset and titlescreen load.
!freeram = $0F3A|!addr
!frame_counter = !freeram

org $008072
	jsr game_loop_hijack


; Overwrite some debug code for boss cutscene select.
org $009510
game_loop_hijack:
	; Run Gamemode code
	jsr $9322
	; Make sure code only run in the correct gamemodes.
	lda $0100|!addr : cmp #$0B : bcc .ret
	jsr increment_frame_counter
	.ret:
rts

; Overwrite some debug code for freeroam.
org $00CC86
increment_frame_counter:
		; Now this is #peakcoding.
		rep #$20
		lda !frame_counter : inc
	.check_low:
		cmp #$FFFF : bcs .carry_low
		sta !frame_counter
		lda !frame_counter+2
		bra .check_high
	.carry_low:
		sec : sbc #$FFFF
		inc !frame_counter+2
		bra .check_low
	.check_high:
		cmp #$FFFF : bcc .done
		lda #$FFFF : sta !frame_counter : sta !frame_counter+2
	.done:
		sep #$20
rts
