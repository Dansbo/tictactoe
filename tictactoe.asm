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
COLPORT=$0286
TMP0=$00
TMP1=$01
TMP2=$02
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
Xses=118
Oses=119

		jsr initscr
		jsr gboard
		jsr resetcounter
		jsr Gameloop

		rts												;End of program


initscr:
	lda $02AE
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

resetcounter:
	lda #9									;reset .count to 9
	sta .count
	rts

turn:
	lda .count
	and #1
	bne

Gameloop:

		jsr GETIN 							;Wait for user to press key

		cmp #'Q'								;Q for quit
		bne .is5								;If Q is not pressed check 5
		jmp .endgl

.is5:
		cmp #53									;Is number 5 pressed
		bne .is1								;if not check for 1
		jsr tile5								;place cursor
		lda #Xses
		jsr CHROUT							;Place piece
		dec .count							;decrease number of possible turns
		bne .is1								;if not 0 then check for 1
		jmp .endgl

.is1:
		cmp #49									;Is number 1 pressed?
		bne .is3								;If not check for 3
		jsr tile1								;place cursor
		lda #Xses
		jsr CHROUT							;place piece
		dec .count							;decrease number of possible turns
		bne .is3
		jmp .endgl

.is3:
		cmp #51
		bne .is9
		jsr tile3
		lda #Xses
		jsr CHROUT
		dec .count
		bne .is9
		jmp .endgl

.is9:
		cmp #57
		bne .is7
		jsr tile9
		lda #Xses
		jsr CHROUT
		dec .count
		bne .is7
		jmp .endgl

.is7:
		cmp #55
		bne .is4
		jsr tile7
		lda #Xses
		jsr CHROUT
		dec .count
		bne .is4
		jmp .endgl

.is4:
		cmp #52
		bne .is2
		jsr tile4
		lda #Xses
		jsr CHROUT
		dec .count
		bne .is2
		jmp .endgl

.is2:
		cmp #50
		bne .is6
		jsr tile2
		lda #Xses
		jsr CHROUT
		dec .count
		bne .is6
		jmp .endgl

.is6:
		cmp #54
		bne .is8
		jsr tile6
		lda #Xses
		jsr CHROUT
		dec .count
		bne .is8
		jmp .endgl

.is8:
		cmp #56
		beq +
		jmp Gameloop						;if not 8 goto gameloop
+		jsr tile8
		lda #Xses
		jsr CHROUT
		dec .count
		bne +										;if number of possible turns is 0
		jmp .endgl							;end game
+		jmp Gameloop						;else re do loop


.endgl:
		rts


tile1:
		ldx #10
		ldy #15
		jsr GoXY
		rts

tile2:
		ldx #10
		ldy #19
		jsr GoXY
		rts

tile3:
		ldx #10
		ldy #23
		jsr	GoXY
		rts

tile4:
		ldx #14
		ldy #15
		jsr GoXY
		rts

tile5:
		ldx #14
		ldy #19
		jsr GoXY
		rts

tile6:
		ldx #14
		ldy #23
		jsr GoXY
		rts

tile7:
		ldx #18
		ldy #15
		jsr GoXY
		rts

tile8:
		ldx #18
		ldy #19
		jsr GoXY
		rts

tile9:
		ldx #18
		ldy #23
		jsr GoXY
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


.title !pet "tictactoe",0

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
.X_places !byte 0.0.0.0.0.0.0.0.0

;Where are Y pieces placed?
.Y_places !byte 0,0,0,0,0,0,0,0,0

;Empty placeholders?
.Empty_places !byte 0,0,0,0,0,0,0,0,0
}
