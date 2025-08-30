; 32 bit frame counter that keeps incrementing as soon as the game starts.
; by Abdu
; Credit: SMW Practice ROM

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


; 4 byte freeram.
; Empty. Cleared on reset and titlescreen load. 
; $7E:0DC3 is also cleared when selecting how many players to use, 
; but this can be disabled with no known side effects by setting $00:9E48 to [80 01 EA].
!backup_counter = $0DC3|!addr

!counter_sixty_hz = $0F42
!previous_sixty_hz = $0F43|!addr
!real_frames = $0DDB|!addr

org $008176
	jsr NMIStart_hijack

; Overwrite some debug code for boss cutscene select.
org $009510
NMIStart_hijack:
	inc !counter_sixty_hz
	lda.w $4210
rts


org $008072
	jsr game_loop_hijack

; Overwrite some unused code to make a running Yoshi at the left edge of the screen.
; Previous hijack was at $009510, changed since there aren't enough bytes.
org $00FC23
game_loop_hijack:
	; Run Gamemode code
	jsr $9322
	
	; This part taken from SMW Practice ROM.
	lda !counter_sixty_hz
	sec : sbc !previous_sixty_hz : sta !real_frames
	lda !counter_sixty_hz : sta !previous_sixty_hz

	; Make sure code only run in the correct gamemodes.
	lda $0100|!addr : cmp #$0B : bcc .ret
	jsr increment_frame_counter

	lda $0100|!addr : cmp #$0F : bcs .ret
	rep #$20
	lda !frame_counter : sta !backup_counter
	lda !frame_counter+2 : sta !backup_counter+2
	sep #$20

	.ret:
rts


; Overwrite some debug code for freeroam.
org $00CC86
increment_frame_counter:
		; Now this is #peakcoding.
		rep #$20
		lda !frame_counter : clc : adc !real_frames
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
