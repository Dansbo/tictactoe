!zone main{
*=$0801										;Assembled code should start at $0801
													; (where BASIC programs start)
													; The real program starts at $0810 = 2064
	!byte 	$0C,$08					; $080C - pointer to next line of BASIC code
	!byte 	$0A,$00					; 2-byte line number ($000A = 10)
	!byte 	$9E							; SYS BASIC token
	!byte 	$20							; [space]
	!byte 	$32,$30,$36,$34	; $32="2",$30="0",$36="6",$34="4"
													; (ASCII encoded nums for dec starting addr)
	!byte 	$00							; End of Line
	!byte 	$00,$00					; This is address $080C containing
													; 2-byte pointer to next line of BASIC code
													; ($0000 = end of program)
*=$0810										; Here starts the real program

;Define constants

PLOT=$FFF0
CHROUT=$FFD2
CHRIN=$FFCF
GETIN=$FFE4
SWITCH=$FF5F
COLPORT=$0376
COLUMNS=$0386
TMP0=$00
TMP1=$01
TMP2=$02
TMP3=$03
TMP4=$04
TMP5=$05
TMP6=$06
TMP7=$07
TMP8=$08
TMP9=$09

;PETDraw Chars
Space=" "
GHLine=96
GVLine=125
MidInter=123
LefInter=171
BotInter=177
RigInter=179
TopInter=178
TLcorner=176
TRcorner=174
BLcorner=173
BRcorner=189
Xses=88
Oses=79

	jsr initscr
	jsr gboard
	jsr resetcounter
	jsr gameloop
	rts											;End of program

gameloop:

;******************************************************************************
;*I want to check if anyone has won Here																			*
;******************************************************************************
	lda .wincnt						;Load A with .wincnt
	cmp #3								;Is .wincnt 3?
	bne .chkcnt						;If not check if counter has run out
	jmp .winsplash				;Go show winsplash

;******************************************************************************
;*Check if .count has reached 0 if so the game is a drawsplash								*
;******************************************************************************
.chkcnt:
	lda .count						;Check if count is 0
	bne .doloop						;If .count not 0 go doloop
 	jmp .drawsplash				;If .count is 0 go show drawsplash

;******************************************************************************
;*Do the actual loop from Here																								*
;******************************************************************************
.doloop:
	jsr GETIN
	cmp #'Q'							;Press Q for quit
	bne .is1							;If not Q then check 1
	jmp .endgl						;If Q then endgl

.is1:
	cmp #49								;Has 1 been pressed?
	bne .is2							;If not check for 2
	lda .Occ_place				;Check if tile is occupied
	bne .is2							;if it is check for next number
	lda #0
	sta TMP0							;Store byte number in zeropage 0
	lda #10
	sta TMP1							;Store X coordiante in zeropage 1
	lda #15
	sta TMP2							;Store Y coordinate in zeropage 2
	jsr .tile							;Go place relevant piece at tile

.is2:
	cmp #50
	bne .is3
	lda .Occ_place+1			;check if tile is occupied
	bne .is3							;If it is check for next number
	lda #1
	sta TMP0							;Store byte number in zeropage 0
	lda #10
	sta TMP1							;Store X coordiante in zeropage 1
	lda #19
	sta TMP2							;Store Y coordinate in zeropage 2
	jsr .tile							;Go place relevant piece at tile

.is3:
	cmp #51
	bne .is4
	lda .Occ_place+2
	bne .is4
	lda #2
	sta TMP0							;Store byte number in zeropage 0
	lda #10
	sta TMP1							;Store X coordiante in zeropage 1
	lda #23
	sta TMP2							;Store Y coordinate in zeropage 2
	jsr .tile							;Go place relevant piece at tile

.is4:
	cmp #52
	bne .is5
	lda .Occ_place+3
	bne .is5
	lda #3
	sta TMP0							;Store byte number in zeropage 0
	lda #14
	sta TMP1							;Store X coordiante in zeropage 1
	lda #15
	sta TMP2							;Store Y coordinate in zeropage 2
	jsr .tile							;Go place relevant piece at tile

.is5:
	cmp #53
	bne .is6
	lda .Occ_place+4
	bne .is6
	lda #4
	sta TMP0							;Store byte number in zeropage 0
	lda #14
	sta TMP1							;Store X coordiante in zeropage 1
	lda #19
	sta TMP2							;Store Y coordinate in zeropage 2
	jsr .tile							;Go place relevant piece at tile

.is6:
	cmp #54
	bne .is7
	lda .Occ_place+5
	bne .is7
	lda #5
	sta TMP0							;Store byte number in zeropage 0
	lda #14
	sta TMP1							;Store X coordiante in zeropage 1
	lda #23
	sta TMP2							;Store Y coordinate in zeropage 2
	jsr .tile							;Go place relevant piece at tile

.is7:
	cmp #55
	bne .is8
	lda .Occ_place+6
	bne .is8
	lda #6
	sta TMP0							;Store byte number in zeropage 0
	lda #18
	sta TMP1							;Store X coordiante in zeropage 1
	lda #15
	sta TMP2							;Store Y coordinate in zeropage 2
	jsr .tile							;Go place relevant piece at tile

.is8:
	cmp #56
	bne .is9
	lda .Occ_place+7
	bne .is9
	lda #7
	sta TMP0							;Store byte number in zeropage 0
	lda #18
	sta TMP1							;Store X coordiante in zeropage 1
	lda #19
	sta TMP2							;Store Y coordinate in zeropage 2
	jsr .tile							;Go place relevant piece at tile

.is9:
	cmp #57
	beq .do9							;If 9 is pressed go to do9
 	jmp gameloop					;If not redo gameloop

.do9:
	lda .Occ_place+8
	bne +
	lda #8
	sta TMP0							;Store byte number in zeropage 0
	lda #18
	sta TMP1							;Store X coordiante in zeropage 1
	lda #23
	sta TMP2							;Store Y coordinate in zeropage 2
	jsr .tile							;Go place relevant piece at tile
+	jmp gameloop					;placeholder for to check for winner

.tile
	ldx TMP1							;Load X coordinate for tile
	ldy TMP2							;Load Y coordinate for tile
	jsr GoXY							;Place cursor at coordinates
	ldy TMP0							;Load placeholder into y
	lda .count						;Check count
	and #1								;Is .count odd or even number
	bne .plaX							;If odd number place X
	jsr PlaceO						;PlaceO (A has been loaded with #1 + dec .count)
	sta .O_place,y				;Remember where O is placed
	sta .Occ_place,y			;Remember this tile is not empty
	rts										;Jump back into gameloop
.plaX:
	jsr PlaceX						;PlaceX (A has been loaded with #1+ dec .count)
	sta .X_place,y				;Remember where X is placed
	sta .Occ_place,y			;Remember this tile is not empty
	rts										;Jump back into gameloop

.endgl:
	rts

;******************************************************************************
;*Routine placeholders for splashscreens																			*
;******************************************************************************
.winsplash:
		rts

.drawsplash:
		rts
;******************************************************************************
;*Initialize gamescreen																												*
;******************************************************************************

initscr:
	lda COLUMNS
	cmp	#80
	beq	.Switch
	jmp	.NoSet

.Switch
	lda #$00
	sec
	jsr	SWITCH

.NoSet
	lda #$01								;Make BG black
	sta COLPORT

	lda #147								;clrscr
	jsr CHROUT

	lda #$10								;White BG, txt black
	sta	COLPORT

	ldx #1
	ldy #1
	jsr	GoXY								;Place cursor top left

	lda #Space
	ldx	#38
	jsr	HLine								;Make top white bar

	ldx #28
	ldy #1
	jsr	GoXY								;Row 28 Col 1

	lda #Space
	ldx #38
	jsr	HLine								;make bottom white bar

	ldx	#1
	ldy	#15
	jsr	GoXY								;Place cursor for title

	ldx	#<.title
	ldy	#>.title
	jsr	PrintStr						;Place title

	ldx	#2
	ldy	#1
	jsr	GoXY								;Prepare left vertical

	lda	#Space
	ldx	#26
	jsr	VLine								;Draw vertical

	ldx	#2
	ldy	#38
	jsr	GoXY								;Prepare right vertical

	lda	#Space
	ldx	#26
	jsr	VLine								;Draw vertical
	rts

;******************************************************************************
;*Draw the gameloop																														*
;******************************************************************************

gboard:
	lda	#$01
	sta	COLPORT						;Change color to black background

	ldx	#8
	ldy	#13
	jsr	GoXY							;Place cursor top left corner
	ldx	#<.maze1					;Print top line of game board
	ldy	#>.maze1
	jsr	PrintStr

	ldx	#9								;Print the next 3 lines of gameboard
	ldy	#13								; |   |   |   |
	jsr	GoXY
	ldx	#<.maze2
	ldy	#>.maze2
	jsr	PrintStr
	ldx	#10
	ldy	#13
	jsr	GoXY
	ldx	#<.maze2
	ldy	#>.maze2
	jsr	PrintStr
	ldx	#11
	ldy	#13
	jsr	GoXY
	ldx	#<.maze2
	ldy	#>.maze2
	jsr	PrintStr

	ldx	#12								;Print 1st middle intersection
	ldy	#13
	jsr	GoXY
	ldx	#<.maze3
	ldy	#>.maze3
	jsr	PrintStr

	ldx	#13								;Print the next 3 lines of gameboard
	ldy	#13								; |   |   |   |
	jsr	GoXY
	ldx	#<.maze2
	ldy	#>.maze2
	jsr	PrintStr
	ldx	#14
	ldy	#13
	jsr	GoXY
	ldx	#<.maze2
	ldy	#>.maze2
	jsr	PrintStr
	ldx	#15
	ldy	#13
	jsr	GoXY
	ldx	#<.maze2
	ldy	#>.maze2
	jsr	PrintStr

	ldx	#16								;Print 2nd middle intersection
	ldy	#13
	jsr	GoXY
	ldx	#<.maze3
	ldy	#>.maze3
	jsr	PrintStr

	ldx	#17								;Print the next 3 lines of gameboard
	ldy	#13								; |   |   |   |
	jsr	GoXY
	ldx	#<.maze2
	ldy	#>.maze2
	jsr	PrintStr
	ldx	#18
	ldy	#13
	jsr	GoXY
	ldx	#<.maze2
	ldy	#>.maze2
	jsr	PrintStr
	ldx	#19
	ldy	#13
	jsr	GoXY
	ldx	#<.maze2
	ldy	#>.maze2
	jsr	PrintStr

	ldx	#20									;Print bottom line of gameboard
	ldy	#13
	jsr	GoXY
	ldx	#<.maze4
	ldy	#>.maze4
	jsr	PrintStr
	rts

;******************************************************************************
;*Reset various counters so program can run nicely when run again							*
;******************************************************************************

resetcounter:
	lda #9									;reset .count to 9
	sta .count
	tay 										;load number 9 into y
	lda #0									;load accumulator with 0
	sta TMP0
clrmem:
	dey											;Decrement y
	sta .X_place,y					;Store 0 in X_place location y
	sta .O_place,y					;Store 0 in O_place location y
	sta .Occ_place,y				;Store 0 in Occ_place location y
	bne clrmem							;if y not 0 go to clrmem
	rts

;******************************************************************************
;*Various functions																														*
;******************************************************************************

PlaceX:
	lda #Xses
	jsr CHROUT
	dec .count
	lda #1
	rts

PlaceO:
	lda #Oses
	jsr CHROUT
	dec .count
	lda #1
	rts
														;Make cursor placement sub
GoXY:
	clc
	jsr	PLOT
	rts

														;Make Horisontal Line sub
HLine:
	jsr	CHROUT
	dex
	bne	HLine
	rts

														;Make Vertical Line sub
VLine:
	stx	TMP0
	sec
	jsr	PLOT
	stx	TMP1

.loopVL
	jsr	CHROUT
	inc	TMP1
	sta	TMP2
	ldx	TMP1
	jsr	GoXY
	lda	TMP2
	dec	TMP0
	bne	.loopVL
	rts

															;Print string sub
PrintStr:
	stx	TMP0
	sty	TMP1
	ldy	#0

.doprint
	lda	(TMP0), Y
	beq	.printdone
	jsr	CHROUT
	iny
	jmp	.doprint

.printdone
	rts

;******************************************************************************
; List of predefined constants used for text, maze and win scenarios
;******************************************************************************

.title !pet "tictactoe",0
.X_win !pet "x wins!",0
.O_win !pet "o wins!",0
.Draw	 !pet "it is a draw",0

; Top line of the game board

.maze1	!pet	176,96,96,96,178,96,96,96,178,96,96,96,174,0

; A line on gameboard with vertical lines and spaces    |   |   |   |

.maze2	!pet	125,"   ",125,"   ",125,"   ",125,0

; A line in gameboard with horizontal lines and crosses |---|---|---|

.maze3	!pet	171,96,96,96,123,96,96,96,123,96,96,96,179,0

; Bottom line of the game board

.maze4	!pet	173,96,96,96,177,96,96,96,177,96,96,96,189,0

;Nine possible moves
.count !byte 9

;Where are X pieces placed?
.X_place !byte 0,0,0,0,0,0,0,0,0

;Where are Y pieces placed?
.O_place !byte 0,0,0,0,0,0,0,0,0

;Occupied placeholders?
.Occ_place !byte 0,0,0,0,0,0,0,0,0

;Possible states of win
.Win1 !byte 1,1,1
			!byte 0,0,0
			!byte 0,0,0

.Win2	!byte 0,0,0
			!byte 1,1,1
			!byte 0,0,0

.Win3	!byte 0,0,0
			!byte 0,0,0
			!byte 1,1,1

.Win4	!byte 1,0,0
			!byte 1,0,0
			!byte 1,0,0

.Win5	!byte 0,1,0
			!byte 0,1,0
			!byte 0,1,0

.Win6	!byte 0,0,1
			!byte 0,0,1
			!byte 0,0,1

.Win7	!byte 1,0,0
			!byte 0,1,0
			!byte 0,0,1

.Win8	!byte 0,0,1
			!byte 0,1,0
			!byte 1,0,0
;counter for matching winbits and bitcounter
.wincnt !byte 0
}
