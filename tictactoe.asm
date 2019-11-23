*=$0801								; Assembled code should start at $0801
											; (where BASIC programs start)
											; The real program starts at $0810 = 2064
	!byte 	$0C,$08			; $080C - pointer to next line of BASIC code
	!byte 	$0A,$00			; 2-byte line number ($000A = 10)
	!byte 	$9E					; SYS BASIC token
	!byte 	$20					; [space]
	!byte 	$32,$30,$36,$34	; $32="2",$30="0",$36="6",$34="4"
											; (ASCII encoded nums for dec starting addr)
	!byte 	$00					; End of Line
	!byte 	$00,$00			; This is address $080C containing
											; 2-byte pointer to next line of BASIC code
											; ($0000 = end of program)
*=$0810								; Here starts the real program

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

;Initialise screen
	lda $02AE
	cmp	#80
	beq	.Switch
	jmp	.NoSet

.Switch
	lda #$00
	sec
	jsr	SWITCH

.NoSet
	lda #$01					;Make BG black
	sta COLPORT

	lda #147					;clrscr
	jsr CHROUT

	lda #$10					;White BG, txt black
	sta	COLPORT

	ldx #1
	ldy #1
	jsr	GoXY					;Place cursor top left

	lda #Space
	ldx	#38
	jsr	HLine					;Make top white bar

	ldx #28
	ldy #1
	jsr	GoXY					;Row 28 Col 1

	lda #Space
	ldx #38
	jsr	HLine					;make bottom white bar

	ldx	#1
	ldy	#15
	jsr	GoXY					;Place cursor for title

	ldx	#<.title
	ldy	#>.title
	jsr	PrintStr				;Place title

	ldx	#2
	ldy	#1
	jsr	GoXY					;Prepare left vertical

	lda	#Space
	ldx	#26
	jsr	VLine					;Draw vertical

	ldx	#2
	ldy	#38
	jsr	GoXY					;Prepare right vertical

	lda	#Space
	ldx	#26
	jsr	VLine					;Draw vertical

;Initialise gameboard

	lda	#$01
	sta	COLPORT					;Change color to black background

	ldx	#8
	ldy	#13
	jsr	GoXY					;Place cursor top left corner

	lda	#TLcorner				;Call PETSCII char
	jsr	CHROUT					;Print

	lda	#GHLine
	ldx	#3
	jsr	HLine

	lda	#TopInter
	jsr	CHROUT

	lda	#GHLine
	ldx	#3
	jsr	HLine

	lda	#TopInter
	jsr	CHROUT

	lda	#GHLine
	ldx	#3
	jsr	HLine

	lda	#TRcorner
	jsr	CHROUT					;Done make top line of Gameboard

	ldx	#9
	ldy	#13
	jsr	GoXY					;Next line for first vertical line snippet

	lda	#GVLine
	ldx	#3
	jsr	VLine

	lda	#LefInter
	jsr	CHROUT

	ldx	#13
	ldy	#13
	jsr	GoXY

	lda	#GVLine
	ldx	#3
	jsr	VLine

	lda	#LefInter
	jsr	CHROUT

	ldx	#17
	ldy	#13
	jsr	GoXY

	lda	#GVLine
	ldx	#3
	jsr	VLine

	lda	#BLcorner
	jsr	CHROUT

	ldx	#9
	ldy	#17
	jsr	GoXY					;Next line for first vertical line snippet

	lda	#GVLine
	ldx	#3
	jsr	VLine

	lda	#MidInter
	jsr	CHROUT

	ldx	#13
	ldy	#17
	jsr	GoXY

	lda	#GVLine
	ldx	#3
	jsr	VLine

	lda	#MidInter
	jsr	CHROUT

	ldx	#17
	ldy	#17
	jsr	GoXY

	lda	#GVLine
	ldx	#3
	jsr	VLine

	lda	#BotInter
	jsr	CHROUT

	ldx	#9
	ldy	#21
	jsr	GoXY					;Next line for first vertical line snippet

	lda	#GVLine
	ldx	#3
	jsr	VLine

	lda	#MidInter
	jsr	CHROUT

	ldx	#13
	ldy	#21
	jsr	GoXY

	lda	#GVLine
	ldx	#3
	jsr	VLine

	lda	#MidInter
	jsr	CHROUT

	ldx	#17
	ldy	#21
	jsr	GoXY

	lda	#GVLine
	ldx	#3
	jsr	VLine

	lda	#BotInter
	jsr	CHROUT

	ldx	#9
	ldy	#25
	jsr	GoXY					;Next line for first vertical line snippet

	lda	#GVLine
	ldx	#3
	jsr	VLine

	lda	#RigInter
	jsr	CHROUT

	ldx	#13
	ldy	#25
	jsr	GoXY

	lda	#GVLine
	ldx	#3
	jsr	VLine

	lda	#RigInter
	jsr	CHROUT

	ldx	#17
	ldy	#25
	jsr	GoXY

	lda	#GVLine
	ldx	#3
	jsr	VLine

	lda	#BRcorner
	jsr	CHROUT

	ldx	#12
	ldy	#14
	jsr	GoXY					;make ready for 2nd horizontal line

	lda	#GHLine
	ldx	#3
	jsr	HLine

	lda	#29
	jsr	CHROUT					;move cursor right

	lda	#GHLine
	ldx	#3
	jsr	HLine

	lda	#29
	jsr	CHROUT					;move cursor right

	lda	#GHLine
	ldx	#3
	jsr	HLine

	ldx	#16
	ldy	#14
	jsr	GoXY					;make ready for 3rd horizontal line

	lda	#GHLine
	ldx	#3
	jsr	HLine

	lda	#29
	jsr	CHROUT					;move cursor right

	lda	#GHLine
	ldx	#3
	jsr	HLine

	lda	#29
	jsr	CHROUT					;move cursor right

	lda	#GHLine
	ldx	#3
	jsr	HLine

	ldx	#20
	ldy	#14
	jsr	GoXY						;make ready for bottom horizontal line

	lda	#GHLine
	ldx	#3
	jsr	HLine

	lda	#29
	jsr	CHROUT					;move cursor right

	lda	#GHLine
	ldx	#3
	jsr	HLine

	lda	#29
	jsr	CHROUT					;move cursor right

	lda	#GHLine
	ldx	#3
	jsr	HLine

	rts									;Main program should always return nicely to BASIC with rts

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
