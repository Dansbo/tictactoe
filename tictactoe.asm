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
	jsr Gameloop

	rts												;End of program


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
	tay 										;load number 9 into y
	lda #0									;load accumulator with 0
clrmem:
	dey											;Decrement y
	sta .X_place,y					;Store 0 in X_place location y
	sta .O_place,y					;Store 0 in O_place location y
	sta .Occ_place,y				;Store 0 in Occ_place location y
	bne clrmem							;if y not 0 go to clrmem
	rts

win_loop:
win1:
	ldy #9									;load 9 into Y for count
	lda #0
	sta .wincnt							;Reset .wincnt
win1lp:
	dey											;Decrement Y
	bmi win2								;if negative 1 go to win2
	lda .count							;Load .count to accumulator
	and #1									;who just placed the piece?
	beq +										;If even then branch
	lda .Win1,y							;load X_place
	beq win1lp							;ignore 0 in win scenario
	cmp .X_place,y					;Has X won?
	bne win1lp							;If no redo loop
	inc .wincnt							;If yes increment .wincnt
	lda .wincnt							;Load wincnt into accumulator
	cmp #3									;If wincnt 9 then win
	bne win1lp							;If not redo loop
	jmp winsplash						;if .wincnt 9 then celebratory screen
+	lda .Win1,y							;load O_place
	beq win1lp
	cmp .O_place,y						;Has O won?
	bne win1lp							;If no redo loop
	inc .wincnt							;If yes increment .wincnt
	lda .wincnt							;Load wincnt into accumulator
	cmp #3									;If wincnt 9 then win
	bne win1lp							;If not redo loop
	jmp winsplash						;if .wincnt 9 then celebratory screen

win2:
	ldy #9									;load 9 into Y for count
	lda #0
	sta .wincnt							;Reset .wincnt
win2lp:
	dey											;Decrement Y
	bmi win3								;if negative 1 go to win2
	lda .count							;Load .count to accumulator
	and #1									;who just placed the piece?
	beq +										;If even then branch
	lda .Win2,y							;load X_place
	beq	win2lp							;Inore 0 in win2
	cmp .X_place,y					;Has X won=
	bne win2lp							;If no redo loop
	inc .wincnt							;If yes increment .wincnt
	lda .wincnt							;Load wincnt into accumulator
	cmp #3									;If wincnt 3 then win
	bne win2lp							;If not redo loop
	jmp winsplash						;if .wincnt 9 then celebratory screen
+	lda .Win2,y							;load O_place
	beq win2lp
	cmp .O_place,y					;Has O won?
	bne win2lp							;If no redo loop
	inc .wincnt							;If yes increment .wincnt
	lda .wincnt							;Load wincnt into accumulator
	cmp #3									;If wincnt 3 then win
	bne win2lp							;If not redo loop
	jmp winsplash						;if .wincnt 9 then celebratory screen

win3:
	ldy #9									;load 9 into Y for count
	lda #0
	sta .wincnt							;Reset .wincnt
win3lp:
	dey											;Decrement Y
	bmi win4								;if negative 1 go to win2
	lda .count							;Load .count to accumulator
	and #1									;who just placed the piece?
	beq +										;If even then branch
	lda .Win3,y							;load X_place
	beq win3lp							;Ignore 0 in scenario
	cmp .X_place,y					;Has X won?
	bne win3lp							;If no redo loop
	inc .wincnt							;If yes increment .wincnt
	lda .wincnt							;Load wincnt into accumulator
	cmp #3									;If wincnt 9 then win
	bne win3lp							;If not redo loop
	jmp winsplash						;if .wincnt 9 then celebratory screen
+	lda .Win3,y							;load O_place
	beq win3lp
	cmp .O_place,y					;Has O won=
	bne win3lp							;If no redo loop
	inc .wincnt							;If yes increment .wincnt
	lda .wincnt							;Load wincnt into accumulator
	cmp #3									;If wincnt 9 then win
	bne win3lp							;If not redo loop
	jmp winsplash						;if .wincnt 9 then celebratory screen

win4:
	ldy #9									;load 9 into Y for count
	lda #0
	sta .wincnt							;Reset .wincnt
win4lp:
	dey											;Decrement Y
	bmi win5								;if negative 1 go to win2
	lda .count							;Load .count to accumulator
	and #1									;who just placed the piece?
	beq +										;If even then branch
	lda .Win4,y							;load X_place
	beq win4lp
	cmp .X_place,y					;Has X won=
	bne win4lp							;If no redo loop
	inc .wincnt							;If yes increment .wincnt
	lda .wincnt							;Load wincnt into accumulator
	cmp #3									;If wincnt 9 then win
	bne win4lp							;If not redo loop
	jmp winsplash						;if .wincnt 9 then celebratory screen
+	lda .Win4,y							;load O_place
	beq win4lp
	cmp .O_place,y					;Has O won=
	bne win4lp							;If no redo loop
	inc .wincnt							;If yes increment .wincnt
	lda .wincnt							;Load wincnt into accumulator
	cmp #3									;If wincnt 9 then win
	bne win4lp							;If not redo loop
	jmp winsplash						;if .wincnt 9 then celebratory screen

win5:
	ldy #9									;load 9 into Y for count
	lda #0
	sta .wincnt							;Reset .wincnt
win5lp:
	dey											;Decrement Y
	bmi win6								;if negative 1 go to win2
	lda .count							;Load .count to accumulator
	and #1									;who just placed the piece?
	beq +										;If even then branch
	lda .Win5,y							;load X_place
	beq win5lp
	cmp .X_place,y							;Has X won=
	bne win5lp							;If no redo loop
	inc .wincnt							;If yes increment .wincnt
	lda .wincnt							;Load wincnt into accumulator
	cmp #3									;If wincnt 9 then win
	bne win5lp							;If not redo loop
	jmp winsplash						;if .wincnt 9 then celebratory screen
+	lda .Win5,y						;load O_place
	beq	win5lp
	cmp .O_place,y							;Has O won=
	bne win5lp							;If no redo loop
	inc .wincnt							;If yes increment .wincnt
	lda .wincnt							;Load wincnt into accumulator
	cmp #3									;If wincnt 9 then win
	bne win5lp							;If not redo loop
	jmp winsplash						;if .wincnt 9 then celebratory screen

win6:
	ldy #9									;load 9 into Y for count
	lda #0
	sta .wincnt							;Reset .wincnt
win6lp:
	dey											;Decrement Y
	bmi win7								;if negative 1 go to win2
	lda .count							;Load .count to accumulator
	and #1									;who just placed the piece?
	beq +										;If even then branch
	lda .Win6,y						;load X_place
	beq win6lp
	cmp .X_place,y							;Has X won=
	bne win6lp							;If no redo loop
	inc .wincnt							;If yes increment .wincnt
	lda .wincnt							;Load wincnt into accumulator
	cmp #3									;If wincnt 9 then win
	bne win6lp							;If not redo loop
	jmp winsplash						;if .wincnt 9 then celebratory screen
+	lda .Win6,y						;load O_place
	beq win6lp
	cmp .O_place,y							;Has O won=
	bne win6lp							;If no redo loop
	inc .wincnt							;If yes increment .wincnt
	lda .wincnt							;Load wincnt into accumulator
	cmp #3									;If wincnt 9 then win
	bne win6lp							;If not redo loop
	jmp winsplash						;if .wincnt 9 then celebratory screen

win7:
	ldy #9									;load 9 into Y for count
	lda #0
	sta .wincnt							;Reset .wincnt
win7lp:
	dey											;Decrement Y
	bmi win8								;if negative 1 go to win2
	lda .count							;Load .count to accumulator
	and #1									;who just placed the piece?
	beq +										;If even then branch
	lda .Win7,y							;load X_place
	beq win7lp
	cmp .X_place,y					;Has X won=
	bne win7lp							;If no redo loop
	inc .wincnt							;If yes increment .wincnt
	lda .wincnt							;Load wincnt into accumulator
	cmp #3									;If wincnt 9 then win
	bne win7lp							;If not redo loop
	jmp winsplash						;if .wincnt 9 then celebratory screen
+	lda .Win7,y						;load O_place
	beq win7lp
	cmp .O_place,y							;Has O won=
	bne win7lp							;If no redo loop
	inc .wincnt							;If yes increment .wincnt
	lda .wincnt							;Load wincnt into accumulator
	cmp #3									;If wincnt 9 then win
	bne win7lp							;If not redo loop
	jmp winsplash						;if .wincnt 9 then celebratory screen

win8:
	ldy #9									;load 9 into Y for count
	lda #0
	sta .wincnt							;Reset .wincnt
win8lp:
	dey											;Decrement Y
	cpy #0
	bmi endwl								;if negative 1 go to win2
	lda .count							;Load .count to accumulator
	and #1									;who just placed the piece?
	beq +										;If even then branch
	lda .Win8,y							;load X_place
	beq win8lp
	cmp .X_place,y					;Has X won=
	bne win8lp							;If no redo loop
	inc .wincnt							;If yes increment .wincnt
	lda .wincnt							;Load wincnt into accumulator
	cmp #3									;If wincnt 9 then win
	bne win8lp							;If not redo loop
	jmp winsplash						;if .wincnt 9 then celebratory screen
+	lda .Win8,y							;load O_place
	beq win8lp
	cmp .O_place,y							;Has O won=
	bne win8lp							;If no redo loop
	inc .wincnt							;If yes increment .wincnt
	lda .wincnt							;Load wincnt into accumulator
	cmp #3									;If wincnt 9 then win
	bne win8lp							;If not redo loop
	jmp winsplash						;if .wincnt 9 then celebratory screen

endwl:
	dec .count							;decrement .count for next turn
	lda .count							;Is count 0
	beq +										;End game if 0
	jmp Gameloop						;Redo Gameloop if not 0
+	jmp .endgl

winsplash:
	rts

Gameloop:

	jsr GETIN 							;Wait for user to press key

	cmp #'Q'								;Q for quit
	bne .is5								;If Q is not pressed check 5
	jmp .endgl

.is5:
	cmp #53									;Is number 5 pressed
	bne .is1								;if not check for 1
	lda .Occ_place +4				;Load state of tile 5
	cmp #1									;if 1 then occupied
	beq .is1								;continue loop
	jmp tile5								;place cursor
	bne .is1								;if .count not 0 then check for 1
	jmp .endgl

.is1:
	cmp #49									;Is number 1 pressed?
	bne .is3								;If not check for 3
	lda .Occ_place					;load state of tile 1
	cmp #1									;if 1 then occupied
	beq .is3								;continue loop
	jmp tile1								;place cursor
	bne .is3								;if .count not 0 then check for 3
	jmp .endgl

.is3:
	cmp #51
	bne .is9
	lda .Occ_place +2
	cmp #1
	beq .is9
	jmp tile3
	bne .is9
	jmp .endgl

.is9:
	cmp #57
	bne .is7
	lda .Occ_place +8
	cmp #1
	beq .is7
	jmp tile9
	bne .is7
	jmp .endgl

.is7:
	cmp #55
	bne .is4
	lda .Occ_place +6
	cmp #1
	beq .is4
	jmp tile7
	bne .is4
	jmp .endgl

.is4:
	cmp #52
	bne .is2
	lda .Occ_place +3
	cmp #1
	beq .is2
	jmp tile4
	bne .is2
	jmp .endgl

.is2:
	cmp #50
	bne .is6
	lda .Occ_place +1
	cmp #1
	beq .is6
	jmp tile2
	bne .is6
	jmp .endgl

.is6:
	cmp #54
	bne .is8
	lda .Occ_place +5
	cmp #1
	beq .is8
	jmp tile6
	bne .is8
	jmp .endgl

.is8:
	cmp #56
	beq +
	jmp Gameloop						;if not 8 goto gameloop
+	jmp tile8
	bne +										;if number of possible turns is 0
	jmp .endgl							;end game
+	jmp Gameloop						;else re do loop

.endgl:
	rts

tile1:
	ldx #10									;load tile coordinates
	ldy #15
	jsr GoXY								;go to tile
	lda .count							;load .count to acc
	and #1
	bne +										;If odd number
	jsr PlaceO							;Place O piece if even
	sta .O_place						;Store 1 at 1st place in variable
	sta .Occ_place
	jmp win_loop						;Go check if this placement gives a win
+	jsr PlaceX							;if odd place X
	sta .X_place						;Store 1 at 1st place in variable
	sta .Occ_place
	jmp win_loop						;Go check if this plascement gives a win

tile2:
	ldx #10
	ldy #19
	jsr GoXY
	lda .count							;load .count to acc
	and #1
	bne +										;If odd number
	jsr PlaceO							;Place O piece if even
	sta .O_place +1					;Store 1 at 9th place in variable
	sta .Occ_place +1
	jmp win_loop
+	jsr PlaceX							;if odd place X
	sta .X_place +1
	sta .Occ_place +1
	jmp win_loop

tile3:
	ldx #10
	ldy #23
	jsr	GoXY
	lda .count							;load .count to acc
	and #1
	bne +										;If odd number
	jsr PlaceO							;Place O piece if even
	sta .O_place +2					;Store 1 at 9th place in variable
	sta .Occ_place +2
	jmp win_loop
+	jsr PlaceX							;if odd place X
	sta .X_place +2
	sta .Occ_place +2
	jmp win_loop

tile4:
	ldx #14
	ldy #15
	jsr GoXY
	lda .count							;load .count to acc
	and #1
	bne +										;If odd number
	jsr PlaceO							;Place O piece if even
	sta .O_place +3					;Store 1 at 9th place in variable
	sta .Occ_place +3
	jmp win_loop
+	jsr PlaceX							;if odd place X
	sta .X_place +3
	sta .Occ_place +3
	jmp win_loop

tile5:
	ldx #14
	ldy #19
	jsr GoXY
	lda .count							;load .count to acc
	and #1
	bne +										;If odd number
	jsr PlaceO							;Place O piece if even
	sta .O_place +4					;Store 1 at 9th place in variable
	sta .Occ_place +4
	jmp win_loop
+	jsr PlaceX							;if odd place X
	sta .X_place +4
	sta .Occ_place +4
	jmp win_loop

tile6:
	ldx #14
	ldy #23
	jsr GoXY
	lda .count							;load .count to acc
	and #1
	bne +										;If odd number
	jsr PlaceO							;Place O piece if even
	sta .O_place +5					;Store 1 at 9th place in variable
	sta .Occ_place +5
	jmp win_loop
+	jsr PlaceX							;if odd place X
	sta .X_place +5
	sta .Occ_place +5
	jmp win_loop

tile7:
	ldx #18
	ldy #15
	jsr GoXY
	lda .count							;load .count to acc
	and #1
	bne +										;If odd number
	jsr PlaceO							;Place O piece if even
	sta .O_place +6					;Store 1 at 9th place in variable
	sta .Occ_place +6
	jmp win_loop
+	jsr PlaceX							;if odd place X
	sta .X_place +6
	sta .Occ_place +6
	jmp win_loop

tile8:
	lda .Occ_place +7				;load state of tile 8
	cmp #1									;is it 1?
	bne +										;if it is not place tile
	jmp Gameloop						;go back into loop
+	ldx #18
	ldy #19
	jsr GoXY
	lda .count							;load .count to acc
	and #1
	bne +										;If odd number
	jsr PlaceO							;Place O piece if even
	sta .O_place +7					;Store 1 at 9th place in variable
	sta .Occ_place +7
	jmp win_loop
+	jsr PlaceX							;if odd place X
	sta .X_place +7
	sta .Occ_place +7
	jmp win_loop

tile9:
	ldx #18
	ldy #23
	jsr GoXY
	lda .count							;load .count to acc
	and #1
	bne +										;If odd number
	jsr PlaceO							;Place O piece if even
	sta .O_place +8					;Store 1 at 9th place in variable
	sta .Occ_place +8
	jmp win_loop
+	jsr PlaceX							;if odd place X
	sta .X_place +8
	sta .Occ_place +8
	jmp win_loop

PlaceX:
	lda #Xses
	jsr CHROUT
	lda #1
	rts

PlaceO:
	lda #Oses
	jsr CHROUT
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
.bitcnt !byte 0
}
