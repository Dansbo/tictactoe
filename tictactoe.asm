!to "tictactoe.prg", cbm
!zone main{
*=$0801				;Assembled code should start at $0801
				; (where BASIC programs start)
				; The real program starts at $0810 = 2064
	!byte 	$0C,$08		; $080C - pointer to next line of BASIC code
	!byte 	$0A,$00		; 2-byte line number ($000A = 10)
	!byte 	$9E		; SYS BASIC token
	!byte 	$20		; [space]
	!byte 	$32,$30,$36,$34	; $32="2",$30="0",$36="6",$34="4"
				; (ASCII encoded nums for dec starting addr)
	!byte 	$00		; End of Line
	!byte 	$00,$00		; This is address $080C containing
				; 2-byte pointer to next line of BASIC code
				; ($0000 = end of program)
*=$0810				; Here starts the real program

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
QUIT=$0A
PLYR=$0B
TURN=$0C

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

startagain:
	jsr initscr
	jsr resetcounter
	jsr welcome
	lda QUIT
	bne .endgame
	lda PLYR
	beq +
	jsr initscr
	jsr Welcome_2
	lda QUIT
	bne .endgame
+	jsr gboard
	jsr gameloop
	lda QUIT
	bne .endgame
	jsr endloop
	lda QUIT
	bne .endgame

.endgame
	rts			;End of program

;************************************************************************
;Make Welcome screen 2, where user can choose to play as X or O
;************************************************************************
Welcome_2:
	lda #$01
	sta COLPORT

	ldx #3
	stx TMP8
	ldy #2
	sty TMP9
	jsr GoXY

	ldx #<.ttt1
	ldy #>.ttt1
	jsr PrintStr
	jsr .nxtline

	ldx #<.ttt2
	ldy #>.ttt2
	jsr PrintStr
	jsr .nxtline

	ldx #<.ttt3
	ldy #>.ttt3
	jsr PrintStr
	jsr .nxtline

	ldx #<.ttt4
	ldy #>.ttt4
	jsr PrintStr
	jsr .nxtline

	ldx #<.ttt5
	ldy #>.ttt5
	jsr PrintStr
	inc TMP9
	jsr .nxtline
	jsr .nxtline

	ldx #<.grt10
	ldy #>.grt10
	jsr PrintStr
	jsr .nxtline
	jsr .nxtline

	ldx #<.grt11
	ldy #>.grt11
	jsr PrintStr
	jsr .nxtline

	jsr X_or_O
	jsr initscr
	rts

;************************************************************************
;Find out if user wants to play as X or O
;************************************************************************
X_or_O
	inc .rndnum
	jsr GETIN
	cmp #'Q'
	bne @x
	lda #1
	sta QUIT
	jmp @end_x_or_o

@x	cmp #'1'
	bne @o
	jmp @end_x_or_o

@o	cmp#'2'
	bne X_or_O
	lda #1
	sta TURN
	inc PLYR

@end_x_or_o
	rts

;************************************************************************
;*Make A.I. functions							*
;************************************************************************
;INPUT: PLYR and .count
;************************************************************************
;OUTPUT: A loaded with "keypress"
;************************************************************************
ai_move:
	tax			;Transfer A (GETIN) to X
	lda PLYR		;We need to check if AI may move
	cmp #1
	bcs +			;If PLYR>0 AI may move
	jmp Ai_no_move
+	lda TURN		;If TURN is 0 then we wait for human
	bne +
	jmp Ai_no_move
+	lda PLYR
	cmp #1			;If PLYR=1 AI is O else AI is X
	beq @cnt8		;If PLYR=2 then no need to check .count = 9
	lda .count
	cmp #9			;If count is 9 then take center tile
	bne @cnt8

@cntr_tl
	lda .keypress +4	;Load keypress number into A
	jmp End_ai

;************************************************************************
;If AI moves second then its first objective is to get center tile
;if it is not available then just choose a random tile
;************************************************************************
;INPUT: .Occ_place, .count and A
;************************************************************************
;OUTPUT: A loaded with keypress
;************************************************************************
@cnt8
	lda .count
	cmp #8			;Is .count 8
	bne @remaining_moves	;If not then continue on
	lda .Occ_place +4	;Load state of center tile
	beq +			;If not available choose random tile
	jmp Rnd_tl
+	jmp @cntr_tl		;If available then choose it

;************************************************************************
;Function that defines how AI should move, if not one of the first two moves
;************************************************************************
;INPLUT: .rndnum and A
;************************************************************************
;OUTPUT: A loaded with relevant keypress
;************************************************************************
@remaining_moves
	lda .rndnum		;If rndnum is over 13
	and #$0F		;Then choose random tile
	cmp #13			;Otherwise AI always wins
	bcc @chk_nw_1		;AI chooses random approx. 12% of the moves
	jmp Rnd_tl

@chk_nw_1
	jsr Reset_scores
	ldx #1
	jsr Load_near_wins
	jsr Check_nw
	lda Ai_score
	cmp #2
	bne @chk_nw_2
	lda .Occ_place +6
	bne @chk_nw_2
	lda .keypress +6
	jmp End_ai

@chk_nw_2
	jsr Reset_scores
	ldx #2
	jsr Load_near_wins
	jsr Check_nw
	lda Ai_score
	cmp #2
	bne @chk_nw_3
	lda .Occ_place +8
	bne @chk_nw_3
	lda .keypress +8
	jmp End_ai

@chk_nw_3
	jsr Reset_scores
	ldx #3
	jsr Load_near_wins
	jsr Check_nw
	lda Ai_score
	cmp #2
	bne @chk_nw_4
	lda .Occ_place +2
	bne @chk_nw_4
	lda .keypress +2
	jmp End_ai

@chk_nw_4
	jsr Reset_scores
	ldx #4
	jsr Load_near_wins
	jsr Check_nw
	lda Ai_score
	cmp #2
	bne @chk_nw_5
	lda .Occ_place +0
	bne @chk_nw_5
	lda .keypress +0
	jmp End_ai

@chk_nw_5
	jsr Reset_scores
	ldx #5
	jsr Load_near_wins
	jsr Check_nw
	lda Ai_score
	cmp #2
	bne @chk_nw_6
	lda .Occ_place +6
	bne @chk_nw_6
	lda .keypress +6
	jmp End_ai

@chk_nw_6
	jsr Reset_scores
	ldx #6
	jsr Load_near_wins
	jsr Check_nw
	lda Ai_score
	cmp #2
	bne @chk_nw_7
	lda .Occ_place +7
	bne @chk_nw_7
	lda .keypress +7
	jmp End_ai

@chk_nw_7
	jsr Reset_scores
	ldx #7
	jsr Load_near_wins
	jsr Check_nw
	lda Ai_score
	cmp #2
	bne @chk_nw_8
	lda .Occ_place +8
	bne @chk_nw_8
	lda .keypress +8
	jmp End_ai

@chk_nw_8
	jsr Reset_scores
	ldx #8
	jsr Load_near_wins
	jsr Check_nw
	lda Ai_score
	cmp #2
	bne @chk_nw_9
	lda .Occ_place +2
	bne @chk_nw_9
	lda .keypress +2
	jmp End_ai

@chk_nw_9
	jsr Reset_scores
	ldx #9
	jsr Load_near_wins
	jsr Check_nw
	lda Ai_score
	cmp #2
	bne @chk_nw_10
	lda .Occ_place +5
	bne @chk_nw_10
	lda .keypress +5
	jmp End_ai

@chk_nw_10
	jsr Reset_scores
	ldx #10
	jsr Load_near_wins
	jsr Check_nw
	lda Ai_score
	cmp #2
	bne @chk_nw_12
	lda .Occ_place +8
	bne @chk_nw_11
	lda .keypress +8
	jmp End_ai

@chk_nw_11
	jsr Reset_scores
	ldx #11
	jsr Load_near_wins
	jsr Check_nw
	lda Ai_score
	cmp #2
	bne @chk_nw_12
	lda .Occ_place +0
	bne @chk_nw_12
	lda .keypress +0
	jmp End_ai

@chk_nw_12
	jsr Reset_scores
	ldx #12
	jsr Load_near_wins
	jsr Check_nw
	lda Ai_score
	cmp #2
	bne @chk_nw_13
	lda .Occ_place +3
	bne @chk_nw_13
	lda .keypress +3
	jmp End_ai

@chk_nw_13
	jsr Reset_scores
	ldx #13
	jsr Load_near_wins
	jsr Check_nw
	lda Ai_score
	cmp #2
	bne @chk_nw_14
	lda .Occ_place +6
	bne @chk_nw_14
	lda .keypress +6
	jmp End_ai

@chk_nw_14
	jsr Reset_scores
	ldx #14
	jsr Load_near_wins
	jsr Check_nw
	lda Ai_score
	cmp #2
	bne @chk_nw_15
	lda .Occ_place +0
	bne @chk_nw_15
	lda .keypress +0
	jmp End_ai

@chk_nw_15
	jsr Reset_scores
	ldx #15
	jsr Load_near_wins
	jsr Check_nw
	lda Ai_score
	cmp #2
	bne @chk_nw_16
	lda .Occ_place +1
	bne @chk_nw_16
	lda .keypress +1
	jmp End_ai

@chk_nw_16
	jsr Reset_scores
	ldx #16
	jsr Load_near_wins
	jsr Check_nw
	lda Ai_score
	cmp #2
	bne @chk_nw_17
	lda .Occ_place +2
	bne @chk_nw_17
	lda .keypress +2
	jmp End_ai

@chk_nw_17
	jsr Reset_scores
	ldx #17
	jsr Load_near_wins
	jsr Check_nw
	lda Ai_score
	cmp #2
	bne @chk_nw_18
	lda .Occ_place +3
	bne @chk_nw_18
	lda .keypress +3
	jmp End_ai

@chk_nw_18
	jsr Reset_scores
	ldx #18
	jsr Load_near_wins
	jsr Check_nw
	lda Ai_score
	cmp #2
	bne @chk_nw_19
	lda .Occ_place +1
	bne @chk_nw_19
	lda .keypress +1
	jmp End_ai

@chk_nw_19
	jsr Reset_scores
	ldx #19
	jsr Load_near_wins
	jsr Check_nw
	lda Ai_score
	cmp #2
	bne @chk_nw_20
	lda .Occ_place +5
	bne @chk_nw_20
	lda .keypress +5
	jmp End_ai

@chk_nw_20
	jsr Reset_scores
	ldx #20
	jsr Load_near_wins
	jsr Check_nw
	lda Ai_score
	cmp #2
	bne @chk_nw_21
	lda .Occ_place +7
	bne @chk_nw_21
	lda .keypress +7
	jmp End_ai

@chk_nw_21
	jsr Reset_scores
	ldx #21
	jsr Load_near_wins
	jsr Check_nw
	lda Ai_score
	cmp #2
	bne @chk_nw_22
	lda .Occ_place +4
	bne @chk_nw_22
	lda .keypress +4
	jmp End_ai

@chk_nw_22
	jsr Reset_scores
	ldx #22
	jsr Load_near_wins
	jsr Check_nw
	lda Ai_score
	cmp #2
	bne @chk_human_1
	lda .Occ_place +3
	bne @chk_human_1
	lda .keypress +3
	jmp End_ai

@chk_human_1
	jsr Reset_scores
	ldx #1
	jsr Load_near_wins
	jsr Check_nw
	lda Human_score
	cmp #2
	bne @chk_human_2
	lda .Occ_place +6
	bne @chk_human_2
	lda .keypress +6
	jmp End_ai

@chk_human_2
	jsr Reset_scores
	ldx #2
	jsr Load_near_wins
	jsr Check_nw
	lda Human_score
	cmp #2
	bne @chk_human_3
	lda .Occ_place	+8
	bne @chk_human_3
	lda .keypress +8
	jmp End_ai

@chk_human_3
	jsr Reset_scores
	ldx #3
	jsr Load_near_wins
	jsr Check_nw
	lda Human_score
	cmp #2
	bne @chk_human_4
	lda .Occ_place +2
	bne @chk_human_4
	lda .keypress +2
	jmp End_ai

@chk_human_4
	jsr Reset_scores
	ldx #4
	jsr Load_near_wins
	jsr Check_nw
	lda Human_score
	cmp #2
	bne @chk_human_5
	lda .Occ_place +0
	bne @chk_human_5
	lda .keypress +0
	jmp End_ai

@chk_human_5
	jsr Reset_scores
	ldx #5
	jsr Load_near_wins
	jsr Check_nw
	lda Human_score
	cmp #2
	bne @chk_human_6
	lda .Occ_place +6
	bne @chk_human_6
	lda .keypress +6
	jmp End_ai

@chk_human_6
	jsr Reset_scores
	ldx #6
	jsr Load_near_wins
	jsr Check_nw
	lda Human_score
	cmp #2
	bne @chk_human_7
	lda .Occ_place +7
	bne @chk_human_7
	lda .keypress +7
	jmp End_ai

@chk_human_7
	jsr Reset_scores
	ldx #7
	jsr Load_near_wins
	jsr Check_nw
	lda Human_score
	cmp #2
	bne @chk_human_8
	lda .Occ_place +8
	bne @chk_human_8
	lda .keypress +8
	jmp End_ai

@chk_human_8
	jsr Reset_scores
	ldx #8
	jsr Load_near_wins
	jsr Check_nw
	lda Human_score
	cmp #2
	bne @chk_human_9
	lda .Occ_place +2
	bne @chk_human_9
	lda .keypress +2
	jmp End_ai

@chk_human_9
	jsr Reset_scores
	ldx #9
	jsr Load_near_wins
	jsr Check_nw
	lda Human_score
	cmp #2
	bne @chk_human_10
	lda .Occ_place +5
	bne @chk_human_10
	lda .keypress +5
	jmp End_ai

@chk_human_10
	jsr Reset_scores
	ldx #10
	jsr Load_near_wins
	jsr Check_nw
	lda Human_score
	cmp #2
	bne @chk_human_11
	lda .Occ_place +8
	bne @chk_human_11
	lda .keypress +8
	jmp End_ai

@chk_human_11
	jsr Reset_scores
	ldx #11
	jsr Load_near_wins
	jsr Check_nw
	lda Human_score
	cmp #2
	bne @chk_human_12
	lda .Occ_place +0
	bne @chk_human_12
	lda .keypress +0
	jmp End_ai

@chk_human_12
	jsr Reset_scores
	ldx #12
	jsr Load_near_wins
	jsr Check_nw
	lda Human_score
	cmp #2
	bne @chk_human_13
	lda .Occ_place +3
	bne @chk_human_13
	lda .keypress +3
	jmp End_ai

@chk_human_13
	jsr Reset_scores
	ldx #13
	jsr Load_near_wins
	jsr Check_nw
	lda Human_score
	cmp #2
	bne @chk_human_14
	lda .Occ_place +6
	bne @chk_human_14
	lda .keypress +6
	jmp End_ai

@chk_human_14
	jsr Reset_scores
	ldx #14
	jsr Load_near_wins
	jsr Check_nw
	lda Human_score
	cmp #2
	bne @chk_human_15
	lda .Occ_place +0
	bne @chk_human_15
	lda .keypress +0
	jmp End_ai

@chk_human_15
	jsr Reset_scores
	ldx #15
	jsr Load_near_wins
	jsr Check_nw
	lda Human_score
	cmp #2
	bne @chk_human_16
	lda .Occ_place +1
	bne @chk_human_16
	lda .keypress +1
	jmp End_ai

@chk_human_16
	jsr Reset_scores
	ldx #16
	jsr Load_near_wins
	jsr Check_nw
	lda Human_score
	cmp #2
	bne @chk_human_17
	lda .Occ_place +2
	bne @chk_human_17
	lda .keypress +2
	jmp End_ai

@chk_human_17
	jsr Reset_scores
	ldx #17
	jsr Load_near_wins
	jsr Check_nw
	lda Human_score
	cmp #2
	bne @chk_human_18
	lda .Occ_place +3
	bne @chk_human_18
	lda .keypress +3
	jmp End_ai

@chk_human_18
	jsr Reset_scores
	ldx #18
	jsr Load_near_wins
	jsr Check_nw
	lda Human_score
	cmp #2
	bne @chk_human_19
	lda .Occ_place +1
	bne @chk_human_19
	lda .keypress +1
	jmp End_ai

@chk_human_19
	jsr Reset_scores
	ldx #19
	jsr Load_near_wins
	jsr Check_nw
	lda Human_score
	cmp #2
	bne @chk_human_20
	lda .Occ_place +5
	bne @chk_human_20
	lda .keypress +5
	jmp End_ai

@chk_human_20
	jsr Reset_scores
	ldx #20
	jsr Load_near_wins
	jsr Check_nw
	lda Human_score
	cmp #2
	bne @chk_human_21
	lda .Occ_place	+7
	bne @chk_human_21
	lda .keypress +7
	jmp End_ai

@chk_human_21
	jsr Reset_scores
	ldx #21
	jsr Load_near_wins
	jsr Check_nw
	lda Human_score
	cmp #2
	bne @chk_human_22
	lda .Occ_place +4
	bne @chk_human_22
	lda .keypress +4
	jmp End_ai

@chk_human_22
	jsr Reset_scores
	ldx #22
	jsr Load_near_wins
	jsr Check_nw
	lda Human_score
	cmp #2
	beq +
-	jmp Rnd_tl
+	lda .Occ_place +3
	bne -
	lda .keypress +3
	jmp End_ai

;************************************************************************
;Load near win scenarios into TMP0 og TMP1
;************************************************************************
Load_near_wins
	cpx #1
	bne @nw2
	lda #<.nw1
	sta TMP0
	lda #>.nw1
	sta TMP1
	jmp @end_load_nw

@nw2	cpx #2
	bne @nw3
	lda #<.nw2
	sta TMP0
	lda #>.nw2
	sta TMP1
	jmp @end_load_nw

@nw3	cpx #3
	bne @nw4
	lda #<.nw3
	sta TMP0
	lda #>.nw3
	sta TMP1
	jmp @end_load_nw

@nw4	cpx #4
	bne @nw5
	lda #<.nw4
	sta TMP0
	lda #>.nw4
	sta TMP1
	jmp @end_load_nw

@nw5	cpx #5
	bne @nw6
	lda #<.nw5
	sta TMP0
	lda #>.nw5
	sta TMP1
	jmp @end_load_nw

@nw6	cpx #6
	bne @nw7
	lda #<.nw6
	sta TMP0
	lda #>.nw6
	sta TMP1
	jmp @end_load_nw

@nw7	cpx #7
	bne @nw8
	lda #<.nw7
	sta TMP0
	lda #>.nw7
	sta TMP1
	jmp @end_load_nw

@nw8	cpx #8
	bne @nw9
	lda #<.nw8
	sta TMP0
	lda #>.nw8
	sta TMP1
	jmp @end_load_nw

@nw9	cpx #9
	bne @nw10
	lda #<.nw9
	sta TMP0
	lda #>.nw9
	sta TMP1
	jmp @end_load_nw

@nw10	cpx #10
	bne @nw11
	lda #<.nw10
	sta TMP0
	lda #>.nw10
	sta TMP1
	jmp @end_load_nw

@nw11	cpx #11
	bne @nw12
	lda #<.nw11
	sta TMP0
	lda #>.nw11
	sta TMP1
	jmp @end_load_nw

@nw12	cpx #12
	bne @nw13
	lda #<.nw12
	sta TMP0
	lda #>.nw12
	sta TMP1
	jmp @end_load_nw

@nw13	cpx #13
	bne @nw14
	lda #<.nw13
	sta TMP0
	lda #>.nw13
	sta TMP1
	jmp @end_load_nw

@nw14	cpx #14
	bne @nw15
	lda #<.nw14
	sta TMP0
	lda #>.nw14
	sta TMP1
	jmp @end_load_nw

@nw15	cpx #15
	bne @nw16
	lda #<.nw15
	sta TMP0
	lda #>.nw15
	sta TMP1
	jmp @end_load_nw

@nw16	cpx #16
	bne @nw17
	lda #<.nw16
	sta TMP0
	lda #>.nw16
	sta TMP1
	jmp @end_load_nw

@nw17	cpx #17
	bne @nw18
	lda #<.nw17
	sta TMP0
	lda #>.nw17
	sta TMP1
	jmp @end_load_nw

@nw18	cpx #18
	bne @nw19
	lda #<.nw18
	sta TMP0
	lda #>.nw18
	sta TMP1
	jmp @end_load_nw

@nw19	cpx #19
	bne @nw20
	lda #<.nw19
	sta TMP0
	lda #>.nw19
	sta TMP1
	jmp @end_load_nw

@nw20	cpx #20
	bne @nw21
	lda #<.nw20
	sta TMP0
	lda #>.nw20
	sta TMP1
	jmp @end_load_nw

@nw21	cpx #21
	bne @nw22
	lda #<.nw21
	sta TMP0
	lda #>.nw21
	sta TMP1
	jmp @end_load_nw

@nw22	lda #<.nw22
	sta TMP0
	lda #>.nw22
	sta TMP1

@end_load_nw
	rts
;************************************************************************
;Reset Human_score and Ai_score
;************************************************************************
Reset_scores
	ldy #9			;We need Y as byte counter
	lda #0
	sta Human_score
	sta Ai_score
	rts

;************************************************************************
;Ending AI routine
;************************************************************************
End_ai				;Return to gameloop with AI move
	rts
Ai_no_move			;Return to gameloop with no change to A
	txa			;Transfer X back to A (GETIN)
	rts

;************************************************************************
;This function checks if AI is close to winning if so, then do
;If not then check if human is winning if so, then block
;************************************************************************
;INPUT: TMP0 with near win scenarios and Y
;************************************************************************
;OUTPUT: Human_score and Ai_score
;************************************************************************
Check_nw
	dey			;Decrement byte counter (Y)
	bmi @end_check_nw
	lda (TMP0),y
	beq Check_nw		;If nw is 0 then next byte
	jsr Load_plays		;load placements into HUMAN and AI
	cmp (TMP2),y		;check if AI has a match
	bne @check_human	;If not then check human
	jsr Ai_match		;Go keep track of near win
	bne Check_nw		;If ai_score not 2 check next byte
	jmp @end_check_nw


@check_human
	cmp (TMP4),y		;Check if human has a match
	bne Check_nw		;If not check next byte
	jsr Human_match		;Go keep track of near win
	bne Check_nw		;If human_score not 2 check next byte
	jmp @end_check_nw

@end_check_nw
	rts

;************************************************************************
;Load .X_place and .O_place intor TMP2, and TMP4
;************************************************************************
Load_plays
	lda .count
	and #1
	beq @ai_is_o
	jmp @ai_is_x

@ai_is_x
	lda #<.X_place
	sta TMP2
	lda #>.X_place
	sta TMP3
	lda #<.O_place
	sta TMP4
	lda #>.O_place
	sta TMP5
	jmp @end_load_plays

@ai_is_o
	lda #<.O_place
	sta TMP2
	lda #>.O_place
	sta TMP3
	lda #<.X_place
	sta TMP4
	lda #>.X_place
	sta TMP5

@end_load_plays
	lda (TMP0),y
	rts

;************************************************************************
;AI has a match. Increment Ai_score and compare with 2
;************************************************************************
;MODIFIES: Ai_score
;************************************************************************
;OUTPUT: A compared with 2
;************************************************************************
Ai_match
	inc Ai_score
	lda Ai_score
	cmp #2
	rts

;************************************************************************
;human has a match. Increment Human_score and compare with 2
;************************************************************************
;MODIFIES: Human_score
;************************************************************************
;OUTPUT: A compared with 2
;************************************************************************
Human_match
	inc Human_score
	lda Human_score
	cmp #2
	rts

;************************************************************************
; This function chooses an available tile randmly
;************************************************************************
;INPUTS: .rndnum and .Occ_place
;************************************************************************
;MODIFIES: .rndnum, A and Y
;************************************************************************
;OUTPUT: A loaded with relevant keypress
;************************************************************************
Rnd_tl
	inc .rndnum		;Increment .rndnum
	lda .rndnum		;Load random number into A
	and #$0F		;Make the rndnum between 0-15
	cmp #9			;Compare .rndnum with 9
	bcs Rnd_tl		;Choose new rndnum if rndnum>=0
	tay			;Transfer A into Y to keep with previous std
	lda .Occ_place,y	;Load Occ_place into A
	bne Rnd_tl		;If not available (1) then choose another
	lda .keypress,y		;Load A with relevant keypress number
	jmp End_ai

;************************************************************************
;Make welcome screen							*
;************************************************************************
welcome:
	lda #$01
	sta COLPORT

	ldx #3
	stx TMP8
	ldy #2
	sty TMP9
	jsr GoXY

	ldx #<.ttt1
	ldy #>.ttt1
	jsr PrintStr
	jsr .nxtline

	ldx #<.ttt2
	ldy #>.ttt2
	jsr PrintStr
	jsr .nxtline

	ldx #<.ttt3
	ldy #>.ttt3
	jsr PrintStr
	jsr .nxtline

	ldx #<.ttt4
	ldy #>.ttt4
	jsr PrintStr
	jsr .nxtline

	ldx #<.ttt5
	ldy #>.ttt5
	jsr PrintStr
	inc TMP9
	jsr .nxtline
	jsr .nxtline

	ldx #<.grt1
	ldy #>.grt1
	jsr PrintStr
	jsr .nxtline

	ldx #<.grt2
	ldy #>.grt2
	jsr PrintStr
	jsr .nxtline

	ldx #<.grt3
	ldy #>.grt3
	jsr PrintStr
	jsr .nxtline

	ldx #<.grt4
	ldy #>.grt4
	jsr PrintStr
	jsr .nxtline
	jsr .nxtline
	jsr .nxtline

	ldx #<.grt5
	ldy #>.grt5
	jsr PrintStr
	jsr .nxtline

	ldx #<.grt6
	ldy #>.grt6
	jsr PrintStr
	jsr .nxtline

	jsr .nxtline
	jsr .nxtline
	jsr .nxtline

	ldx #<.grt7
	ldy #>.grt7
	jsr PrintStr
	jsr .nxtline
	jsr .nxtline

	ldx #<.grt8
	ldy #>.grt8
	jsr PrintStr
	jsr .nxtline

	jsr .nxtline
	jsr .nxtline

	ldx #<.grt9
	ldy #>.grt9
	jsr PrintStr
	jsr .nxtline
	jsr .players

	jsr initscr

	rts
;************************************************************************
;Get input from user on how many players there are
;************************************************************************
;INPUT: GETIN
;************************************************************************
;OUTPUT: PLYR
;************************************************************************
.players
	inc .rndnum		;Increment .rndnum in loop
	jsr GETIN
	cmp #'Q'
	bne .one
	lda #1
	sta QUIT
	jmp .endplay

.one
	cmp #'1'
	bne .two
	lda #1
	sta PLYR
	jmp .endplay

.two
	cmp #'2'
	bne .players
	lda #0
	sta PLYR

.endplay
	rts
;************************************************************************
;Find out if user wants to quit og start new gameloop			*
;************************************************************************

endloop
	jsr GETIN
	cmp #'Q'
	bne .isspace
	lda #1
	sta QUIT
	jmp .endloop

.isspace
	cmp #' '
	bne endloop
	jmp startagain

.endloop
	rts

gameloop:

;************************************************************************
;*I want to check if anyone has won Here				*
;************************************************************************

	lda .wincnt		;Load A with .wincnt
	cmp #3			;Is .wincnt 3?
	bne .chkcnt		;If not check if counter has run out
	jsr .winsplash		;Go show winsplash
	jmp .endgl

;************************************************************************
;*Check if .count has reached 0 if so the game is a drawsplash		*
;************************************************************************

.chkcnt:
	lda .count		;Check if count is 0
	bne .doloop		;If .count not 0 go doloop
 	jsr .drawsplash		;If .count is 0 go show drawsplash
	jmp .endgl

;************************************************************************
;*Do the actual loop from Here						*
;************************************************************************

.doloop:
	inc .rndnum		;Increment .rndnum in loop
	jsr GETIN
	jsr ai_move
	cmp #'Q'		;Press Q for quit
	bne .is1		;If not Q then check 1
	lda #1
	sta QUIT
	jmp .endgl		;If Q then endgl

.is1:
	cmp #49			;Has 1 been pressed?
	bne .is2		;If not check for 2
	lda .Occ_place		;Check if tile is occupied
	bne .is2		;if it is check for next number
	lda #0
	sta TMP0		;Store byte number in zeropage 0
	lda #10
	sta TMP1		;Store X coordiante in zeropage 1
	lda #15
	sta TMP2		;Store Y coordinate in zeropage 2
	jsr .tile		;Go place relevant piece at tile

.is2:
	cmp #50
	bne .is3
	lda .Occ_place+1	;check if tile is occupied
	bne .is3		;If it is check for next number
	lda #1
	sta TMP0		;Store byte number in zeropage 0
	lda #10
	sta TMP1		;Store X coordiante in zeropage 1
	lda #19
	sta TMP2		;Store Y coordinate in zeropage 2
	jsr .tile		;Go place relevant piece at tile

.is3:
	cmp #51
	bne .is4
	lda .Occ_place+2
	bne .is4
	lda #2
	sta TMP0		;Store byte number in zeropage 0
	lda #10
	sta TMP1		;Store X coordiante in zeropage 1
	lda #23
	sta TMP2		;Store Y coordinate in zeropage 2
	jsr .tile		;Go place relevant piece at tile

.is4:
	cmp #52
	bne .is5
	lda .Occ_place+3
	bne .is5
	lda #3
	sta TMP0		;Store byte number in zeropage 0
	lda #14
	sta TMP1		;Store X coordiante in zeropage 1
	lda #15
	sta TMP2		;Store Y coordinate in zeropage 2
	jsr .tile		;Go place relevant piece at tile

.is5:
	cmp #53
	bne .is6
	lda .Occ_place+4
	bne .is6
	lda #4
	sta TMP0		;Store byte number in zeropage 0
	lda #14
	sta TMP1		;Store X coordiante in zeropage 1
	lda #19
	sta TMP2		;Store Y coordinate in zeropage 2
	jsr .tile		;Go place relevant piece at tile

.is6:
	cmp #54
	bne .is7
	lda .Occ_place+5
	bne .is7
	lda #5
	sta TMP0		;Store byte number in zeropage 0
	lda #14
	sta TMP1		;Store X coordiante in zeropage 1
	lda #23
	sta TMP2		;Store Y coordinate in zeropage 2
	jsr .tile		;Go place relevant piece at tile

.is7:
	cmp #55
	bne .is8
	lda .Occ_place+6
	bne .is8
	lda #6
	sta TMP0		;Store byte number in zeropage 0
	lda #18
	sta TMP1		;Store X coordiante in zeropage 1
	lda #15
	sta TMP2		;Store Y coordinate in zeropage 2
	jsr .tile		;Go place relevant piece at tile

.is8:
	cmp #56
	bne .is9
	lda .Occ_place+7
	bne .is9
	lda #7
	sta TMP0		;Store byte number in zeropage 0
	lda #18
	sta TMP1		;Store X coordiante in zeropage 1
	lda #19
	sta TMP2		;Store Y coordinate in zeropage 2
	jsr .tile		;Go place relevant piece at tile

.is9:
	cmp #57
	beq .do9		;If 9 is pressed go to do9
 	jmp gameloop		;If not redo gameloop

.do9:
	lda .Occ_place+8
	bne +
	lda #8
	sta TMP0		;Store byte number in zeropage 0
	lda #18
	sta TMP1		;Store X coordiante in zeropage 1
	lda #23
	sta TMP2		;Store Y coordinate in zeropage 2
	jsr .tile		;Go place relevant piece at tile
+	jmp gameloop		;placeholder for to check for winner

.endgl:
	rts
;************************************************************************
;*Tile function to place gamepieces					*
;************************************************************************

.tile
	ldx TMP1		;Load X coordinate for tile
	ldy TMP2		;Load Y coordinate for tile
	jsr GoXY		;Place cursor at coordinates
	ldy TMP0		;Load placeholder into y
	lda .count		;Check count
	and #1			;Is .count odd or even number
	bne .plaX		;If odd number place X
	jsr PlaceO		;PlaceO (A has been loaded with #1 + dec .count)
	sta .O_place,y		;Remember where O is placed
	sta .Occ_place,y	;Remember this tile is not empty
	jsr chkwin
	lda TURN
	eor #1
	sta TURN
	rts			;Jump back into gameloop
.plaX:
	jsr PlaceX		;PlaceX (A has been loaded with #1+ dec .count)
	sta .X_place,y		;Remember where X is placed
	sta .Occ_place,y	;Remember this tile is not empty
	jsr chkwin
	lda TURN
	eor #1
	sta TURN
	rts			;Jump back into gameloop

;************************************************************************
;*chkwin function to find 3 matching places in possible win scenarios	*
;************************************************************************

chkwin:
	ldy #9			;Prepare Y as byte counter
	lda #0
	sta .wincnt
	lda #<.Win1		;load Win1 into ZP
	sta TMP0
	lda #>.Win1
	sta TMP1
	jsr .chkplaces		;Go see if we can get .wincnt =3
	cmp #3			;Did we really find a winner?
	bne .iswin2		;Not 3 matches check next .Win
	jmp .endchk		;Winner Winner Chicken Dinner

.iswin2
	lda #0			;We need to reset .wincnt before next byte
	sta .wincnt
	lda #<.Win2		;Load .Win2 into ZP
	sta TMP0
	lda #>.Win2
	sta TMP1
	jsr .chkplaces		;Go see if we can get .wincnt=3
	cmp #3			;Did we find 3 matches?
	bne .iswin3		;Not 3 matches check .Win3
	jmp .endchk		;endchk when 3 matches were found

.iswin3
	lda #0
	sta .wincnt
	lda #<.Win3
	sta TMP0
	lda #>.Win3
	sta TMP1
	jsr .chkplaces
	cmp #3
	bne .iswin4
	jmp .endchk

.iswin4
	lda #0
	sta .wincnt
	lda #<.Win4
	sta TMP0
	lda #>.Win4
	sta TMP1
	jsr .chkplaces
	cmp #3
	bne .iswin5
	jmp .endchk

.iswin5
	lda #0
	sta .wincnt
	lda #<.Win5
	sta TMP0
	lda #>.Win5
	sta TMP1
	jsr .chkplaces
	cmp #3
	bne .iswin6
	jmp .endchk

.iswin6
	lda #0
	sta .wincnt
	lda #<.Win6
	sta TMP0
	lda #>.Win6
	sta TMP1
	jsr .chkplaces
	cmp #3
	bne .iswin7
	jmp .endchk

.iswin7
	lda #0
	sta .wincnt
	lda #<.Win7
	sta TMP0
	lda #>.Win7
	sta TMP1
	jsr .chkplaces
	cmp #3
	bne .iswin8
	jmp .endchk

.iswin8
	lda #0
	sta .wincnt
	lda #<.Win8
	sta TMP0
	lda #>.Win8
	sta TMP1
	jsr .chkplaces
	jmp .endchk		;No need to check for 3 matches gameloop does that

.endchk:
	rts

;************************************************************************
;*Load placeholders into ZP						*
;************************************************************************

.chkplaces:
	lda .count		;What is the .count
	and #1			;Is it even
	bne .loado
	lda #<.X_place		;Load .X_place into ZP
	sta TMP2
	lda #>.X_place
	sta TMP3
	jsr .chks
	jmp .endchkpl

.loado:
	lda #<.O_place		;Load .O_place into ZP
	sta TMP2
	lda #>.O_place
	sta TMP3
	jsr .chks
	jmp .endchkpl

.endchkpl:
	ldy #9			;Reset Y register for next .Win
	rts

;************************************************************************
;*Do the actual matching						*
;************************************************************************

.chks:
	dey
	bmi +
	lda (TMP0),y
	beq .chks
	cmp (TMP2),y
	bne .chks
	jsr .matching
	bne .chks
+	rts

;************************************************************************
;*Increase .wincnt when matches found					*
;************************************************************************

.matching:
	inc .wincnt		;Increase .wincnt
	lda .wincnt
	cmp #3			;If .wincnt=3 we have a winner!
	rts

;************************************************************************
;*Routine placeholders for splashscreens				*
;************************************************************************

.winsplash:
	ldx #22
	ldy #11
	jsr GoXY
	ldx #<.win_1
	ldy #>.win_1
	jsr PrintStr

	ldx #23
	ldy #14
	jsr GoXY
	ldx #<.win_2
	ldy #>.win_2
	jsr PrintStr

	jsr .nxtline
	jsr GETIN
	cmp #' '
	bne .winsplash

	jsr .ttlchg		;Go remove board and such
	ldx #3
	stx TMP8
	ldy #15
	sty TMP9
	jsr GoXY

	lda .count
	and #1
	beq +			;If .count is even the O won
	jmp .drawo
+	ldx #<.xw1
	ldy #>.xw1
	jsr PrintStr
	jsr .nxtline

	ldx #<.xw2
	ldy #>.xw2
	jsr PrintStr
	jsr .nxtline

	ldx #<.xw3
	ldy #>.xw3
	jsr PrintStr
	jsr .nxtline

	ldx #<.xw4
	ldy #>.xw4
	jsr PrintStr
	jsr .nxtline

	ldx #<.xw5
	ldy #>.xw5
	jsr PrintStr
	jsr .nxtline

	ldx #<.xw6
	ldy #>.xw6
	jsr PrintStr
	jsr .nxtline

	ldx #<.xw7
	ldy #>.xw7
	jsr PrintStr
	jsr .nxtline

	ldx #<.xw8
	ldy #>.xw8
	jsr PrintStr
	jsr .nxtline

	ldx #<.xw9
	ldy #>.xw9
	jsr PrintStr
	jsr .nxtline

	ldx #<.xw10
	ldy #>.xw10
	jsr PrintStr
	jsr .nxtline

	ldx #<.xw11
	ldy #>.xw11
	jsr PrintStr
	jsr .nxtline

	ldx #<.xw12
	ldy #>.xw12
	jsr PrintStr
	jsr .nxtline
	jmp .drawwins

.drawo
	ldx #<.ow1
	ldy #>.ow1
	jsr PrintStr
	jsr .nxtline

	ldx #<.ow2
	ldy #>.ow2
	jsr PrintStr
	jsr .nxtline

	ldx #<.ow3
	ldy #>.ow3
	jsr PrintStr
	jsr .nxtline

	ldx #<.ow4
	ldy #>.ow4
	jsr PrintStr
	jsr .nxtline

	ldx #<.ow5
	ldy #>.ow5
	jsr PrintStr
	jsr .nxtline

	ldx #<.ow6
	ldy #>.ow6
	jsr PrintStr
	jsr .nxtline

	ldx #<.ow7
	ldy #>.ow7
	jsr PrintStr
	jsr .nxtline

	ldx #<.ow8
	ldy #>.ow8
	jsr PrintStr
	jsr .nxtline

	ldx #<.ow9
	ldy #>.ow9
	jsr PrintStr
	jsr .nxtline

	ldx #<.ow10
	ldy #>.ow10
	jsr PrintStr
	jsr .nxtline

	ldx #<.ow11
	ldy #>.ow11
	jsr PrintStr
	jsr .nxtline

	ldx #<.ow12
	ldy #>.ow12
	jsr PrintStr
	jsr .nxtline
	jmp .drawwins

.drawwins
	ldx #16
	stx TMP8
	ldy #3
	sty TMP9
	jsr GoXY

	ldx #<.wdr1
	ldy #>.wdr1
	jsr PrintStr
	jsr .nxtline

	ldx #<.wdr2
	ldy #>.wdr2
	jsr PrintStr
	jsr .nxtline

	ldx #<.wdr3
	ldy #>.wdr3
	jsr PrintStr
	jsr .nxtline

	ldx #<.wdr4
	ldy #>.wdr4
	jsr PrintStr
	jsr .nxtline

	ldx #<.wdr5
	ldy #>.wdr5
	jsr PrintStr
	jsr .nxtline

	ldx #<.wdr6
	ldy #>.wdr6
	jsr PrintStr
	jsr .nxtline

	ldx #<.wdr7
	ldy #>.wdr7
	jsr PrintStr
	jsr .nxtline

	ldx #<.wdr8
	ldy #>.wdr8
	jsr PrintStr
	jsr .nxtline

	ldx #<.wdr9
	ldy #>.wdr9
	jsr PrintStr
	jsr .nxtline

	ldx #<.wdr10
	ldy #>.wdr10
	jsr PrintStr
	jsr .nxtline

	ldx #<.wdr11
	ldy #>.wdr11
	jsr PrintStr
	jsr .nxtline

	rts

.drawsplash:
	jsr .ttlchg		;Go remove board and such

	ldx #3
	stx TMP8
	ldy #3
	sty TMP9
	jsr GoXY

	ldx #<.dr1
	ldy #>.dr1
	jsr PrintStr

	jsr .nxtline
	ldx #<.dr2
	ldy #>.dr2
	jsr PrintStr

	jsr .nxtline
	ldx #4
	ldy #3
	ldx #<.dr3
	ldy #>.dr3
	jsr PrintStr

	jsr .nxtline
	ldx #<.dr4
	ldy #>.dr4
	jsr PrintStr

	jsr .nxtline
	ldx #<.dr5
	ldy #>.dr5
	jsr PrintStr

	jsr .nxtline
	ldx #<.dr6
	ldy #>.dr6
	jsr PrintStr

	jsr .nxtline
	ldx #<.dr7
	ldy #>.dr7
	jsr PrintStr

	jsr .nxtline
	ldx #<.dr8
	ldy #>.dr8
	jsr PrintStr

	jsr .nxtline
	ldx #<.dr9
	ldy #>.dr9
	jsr PrintStr

	jsr .nxtline
	ldx #<.dr10
	ldy #>.dr10
	jsr PrintStr

	jsr .nxtline
	ldx #<.dr11
	ldy #>.dr11
	jsr PrintStr

	jsr .nxtline
	ldx #<.dr12
	ldy #>.dr12
	jsr PrintStr

	jsr .nxtline
	ldx #<.dr13
	ldy #>.dr13
	jsr PrintStr

	jsr .nxtline
	ldx #<.dr14
	ldy #>.dr14
	jsr PrintStr

	jsr .nxtline
	ldx #<.dr15
	ldy #>.dr15
	jsr PrintStr

	jsr .nxtline
	ldx #<.dr16
	ldy #>.dr16
	jsr PrintStr

	jsr .nxtline
	ldx #<.dr17
	ldy #>.dr17
	jsr PrintStr

	jsr .nxtline
	ldx #<.dr18
	ldy #>.dr18
	jsr PrintStr

	jsr .nxtline
	ldx #<.dr19
	ldy #>.dr19
	jsr PrintStr

	jsr .nxtline
	ldx #<.dr20
	ldy #>.dr20
	jsr PrintStr

	jsr .nxtline
	ldx #<.dr21
	ldy #>.dr21
	jsr PrintStr

	jsr .nxtline
	ldx #<.dr22
	ldy #>.dr22
	jsr PrintStr

	jsr .nxtline
	ldx #<.dr23
	ldy #>.dr23
	jsr PrintStr

	jsr .nxtline
	ldx #<.dr24
	ldy #>.dr24
	jsr PrintStr

	rts

;************************************************************************
;*Function that removes gameboard and changes title			*
;************************************************************************

.ttlchg
	jsr .NoSet		;Calling .Noset to remove gameboard
	lda #$10		;Black txt white background
	sta COLPORT

	ldx #1			;Change title on ending splashscrrens
	ldy #15
	jsr GoXY
	ldx #<.gameover
	ldy #>.gameover
	jsr PrintStr

	ldx #28			;Add help text on bottom of screen
	ldy #2
	jsr GoXY
	ldx #<.endhelp
	ldy #>.endhelp
	jsr PrintStr

	lda #$01		;White text on black background
	sta COLPORT
	rts

;************************************************************************
;*Routine to go to next line when drawing				*
;************************************************************************

.nxtline:
	inc TMP8
	ldx TMP8
	ldy TMP9
	jsr GoXY
	rts
;************************************************************************
;*Initialize gamescreen							*
;************************************************************************

initscr:
	lda COLUMNS
	cmp #80
	beq .Switch
	jmp .NoSet

.Switch
	lda #$00
	sec
	jsr SWITCH

.NoSet
	lda #$01		;Make BG black
	sta COLPORT

	lda #147		;clrscr
	jsr CHROUT

	lda #$10		;White BG, txt black
	sta COLPORT

	ldx #1
	ldy #1
	jsr GoXY		;Place cursor top left

	lda #Space
	ldx #38
	jsr HLine		;Make top white bar

	ldx #28
	ldy #1
	jsr GoXY		;Row 28 Col 1

	lda #Space
	ldx #38
	jsr HLine		;make bottom white bar

	ldx #1
	ldy #15
	jsr GoXY		;Place cursor for title

	ldx #<.title
	ldy #>.title
	jsr PrintStr		;Place title

	ldx #2
	ldy #1
	jsr GoXY		;Prepare left vertical

	lda #Space
	ldx #26
	jsr VLine		;Draw vertical

	ldx #2
	ldy #38
	jsr GoXY		;Prepare right vertical

	lda #Space
	ldx #26
	jsr VLine		;Draw vertical
	rts

;************************************************************************
;*Draw the gameloop							*
;************************************************************************

gboard:
	lda #$01
	sta COLPORT		;Change color to black background

	ldx #8
	ldy #13
	jsr GoXY		;Place cursor top left corner
	ldx #<.maze1		;Print top line of game board
	ldy #>.maze1
	jsr PrintStr

	ldx #9			;Print the next 3 lines of gameboard
	ldy #13			; |   |   |   |
	jsr GoXY
	ldx #<.maze2
	ldy #>.maze2
	jsr PrintStr
	ldx #10
	ldy #13
	jsr GoXY
	ldx #<.maze2
	ldy #>.maze2
	jsr PrintStr
	ldx #11
	ldy #13
	jsr GoXY
	ldx #<.maze2
	ldy #>.maze2
	jsr PrintStr

	ldx #12			;Print 1st middle intersection
	ldy #13
	jsr GoXY
	ldx #<.maze3
	ldy #>.maze3
	jsr PrintStr

	ldx #13			;Print the next 3 lines of gameboard
	ldy #13			; |   |   |   |
	jsr GoXY
	ldx #<.maze2
	ldy #>.maze2
	jsr PrintStr
	ldx #14
	ldy #13
	jsr GoXY
	ldx #<.maze2
	ldy #>.maze2
	jsr PrintStr
	ldx #15
	ldy #13
	jsr GoXY
	ldx #<.maze2
	ldy #>.maze2
	jsr PrintStr

	ldx #16			;Print 2nd middle intersection
	ldy #13
	jsr GoXY
	ldx #<.maze3
	ldy #>.maze3
	jsr PrintStr

	ldx #17			;Print the next 3 lines of gameboard
	ldy #13			; |   |   |   |
	jsr GoXY
	ldx #<.maze2
	ldy #>.maze2
	jsr PrintStr
	ldx #18
	ldy #13
	jsr GoXY
	ldx #<.maze2
	ldy #>.maze2
	jsr PrintStr
	ldx #19
	ldy #13
	jsr GoXY
	ldx #<.maze2
	ldy #>.maze2
	jsr PrintStr

	ldx #20			;Print bottom line of gameboard
	ldy #13
	jsr GoXY
	ldx #<.maze4
	ldy #>.maze4
	jsr PrintStr
	rts

;************************************************************************
;*Reset various counters so program can run nicely when run again	*
;************************************************************************

resetcounter:
	lda #9			;reset .count to 9
	sta .count
	tay 			;load number 9 into y
	lda #0			;load accumulator with 0
	sta TMP0
	sta QUIT
	sta PLYR
	sta TURN
	sta .wincnt
clrmem:
	dey			;Decrement y
	sta .X_place,y		;Store 0 in X_place location y
	sta .O_place,y		;Store 0 in O_place location y
	sta .Occ_place,y	;Store 0 in Occ_place location y
	bne clrmem		;if y not 0 go to clrmem
	rts

;************************************************************************
;*Various functions							*
;************************************************************************

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
	jsr PLOT
	rts

				;Make Horisontal Line sub
HLine:
	jsr CHROUT
	dex
	bne HLine
	rts

				;Make Vertical Line sub
VLine:
	stx TMP0
	sec
	jsr PLOT
	stx TMP1

.loopVL
	jsr CHROUT
	inc TMP1
	sta TMP2
	ldx TMP1
	jsr GoXY
	lda TMP2
	dec TMP0
	bne .loopVL
	rts

				;Print string sub
PrintStr:
	stx TMP0
	sty TMP1
	ldy #0

.doprint
	lda (TMP0), Y
	beq .printdone
	jsr CHROUT
	iny
	jmp .doprint

.printdone
	rts

;************************************************************************
;*List of predefined constants used for text, maze and win scenarios	*
;************************************************************************

.title !pet "tictactoe",0
.gameover !pet "game over",0
.endhelp !pet "press space to new game or q to quit",0
.win_1 !pet "we have a winner",0
.win_2 !pet "press space",0

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
.Win1 	!byte 1,1,1
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

;Big letters for splashscreens

.dr1 !pet	"***     *****       **    **    **",0
.dr2 !pet	"****    ******     ****   **    **",0
.dr3 !pet	"** **   **   **   **  **  **    **",0
.dr4 !pet	"**  **  **    ** **    ** **    **",0
.dr5 !pet	"**   ** **    ** **    ** **    **",0
.dr6 !pet	"**   ** **    ** **    ** **    **",0
.dr7 !pet	"**   ** **    ** **    ** **    **",0
.dr8 !pet	"**   ** **   **  **    ** **    **",0
.dr9 !pet	"**   ** **  **   **    ** **    **",0
.dr10 !pet	"**   ** ** **    **    ** **    **",0
.dr11 !pet	"**   ** ****     **    ** **    **",0
.dr12 !pet	"**   ** ****     ******** **    **",0
.dr13 !pet	"**   ** ****     ******** **    **",0
.dr14 !pet	"**   ** ** **    **    ** ** ** **",0
.dr15 !pet	"**   ** ** **    **    ** ** ** **",0
.dr16 !pet	"**   ** **  **   **    ** ** ** **",0
.dr17 !pet	"**   ** **  **   **    ** ** ** **",0
.dr18 !pet	"**   ** **   **  **    ** ** ** **",0
.dr19 !pet	"**   ** **   **  **    ** ** ** **",0
.dr20 !pet	"**   ** **    ** **    ** ** ** **",0
.dr21 !pet	"**  **  **    ** **    ** ********",0
.dr22 !pet	"** **   **    ** **    ** ********",0
.dr23 !pet	"****    **    ** **    ** ***  ***",0
.dr24 !pet	"***     **    ** **    ** **    **",0

.xw1 !pet	"**      **",0
.xw2 !pet	"**      **",0
.xw3 !pet	" **    ** ",0
.xw4 !pet	"  **  **  ",0
.xw5 !pet	"   ****   ",0
.xw6 !pet	"    **    ",0
.xw7 !pet	"    **    ",0
.xw8 !pet	"   ****   ",0
.xw9 !pet	"  **  **  ",0
.xw10 !pet	" **    ** ",0
.xw11 !pet	"**      **",0
.xw12 !pet	"**      **",0

.ow1 !pet	"   ****   ",0
.ow2 !pet	"  ******  ",0
.ow3 !pet	" **    ** ",0
.ow4 !pet	"**      **",0
.ow5 !pet	"**      **",0
.ow6 !pet	"**      **",0
.ow7 !pet	"**      **",0
.ow8 !pet	"**      **",0
.ow9 !pet	"**      **",0
.ow10 !pet	" **    ** ",0
.ow11 !pet	"  ******  ",0
.ow12 !pet	"   ****   ",0

.wdr1 !pet	"**    **   **   **    **   ****** ",0
.wdr2 !pet	"**    **   **   ***   **   ****** ",0
.wdr3 !pet	"**    **   **   ****  **  **      ",0
.wdr4 !pet	"**    **   **   ** ** **  **      ",0
.wdr5 !pet	"**    **   **   ** ** **   ****   ",0
.wdr6 !pet	"**    **   **   ** ** **     ***  ",0
.wdr7 !pet	"** ** **   **   ** ** **       ***",0
.wdr8 !pet	"** ** **   **   **  * **        **",0
.wdr9 !pet	"***  ***   **   **  ****       ** ",0
.wdr10 !pet	"***  ***   **   **   ***  ******  ",0
.wdr11 !pet	"**    **   **   **    **  *****   ",0

.ttt1 !pet	"*** *  ** ***  **   ** ***  **  ****",0
.ttt2 !pet	" *  * *    *  *  * *    *  *  * *   ",0
.ttt3 !pet	" *  * *    *  **** *    *  *  * **  ",0
.ttt4 !pet	" *  * *    *  *  * *    *  *  * *   ",0
.ttt5 !pet	" *  *  **  *  *  *  **  *   **  ****",0

.grt1 !pet "welcome to tictactoe",0
.grt2 !pet "to place a gamepiece press numbers",0
.grt3 !pet "1 to 9. 1 being top left tile and",0
.grt4 !pet "9 being bottom right tile.",0
.grt5 !pet "quit game at any time by pressing",0
.grt6 !pet "q.",0
.grt7 !pet "press 1 for one player game",0
.grt8 !pet "press 2 for two player game",0
.grt9 !pet "good luck!",0
.grt10 !pet "press 1 to play as x",0
.grt11 !pet "press 2 to play as o",0

.nw1 	!byte 0,0,1
	!byte 0,1,0
	!byte 0,0,0

.nw2	!byte 1,0,0
	!byte 0,1,0
	!byte 0,0,0

.nw3	!byte 0,0,0
	!byte 0,1,0
	!byte 1,0,0

.nw4	!byte 0,0,0
	!byte 0,1,0
	!byte 0,0,1

.nw5	!byte 1,0,0
	!byte 1,0,0
	!byte 0,0,0

.nw6	!byte 0,1,0
	!byte 0,1,0
	!byte 0,0,0

.nw7	!byte 0,0,1
	!byte 0,0,1
	!byte 0,0,0

.nw8	!byte 1,1,0
	!byte 0,0,0
	!byte 0,0,0

.nw9	!byte 0,0,0
	!byte 1,1,0
	!byte 0,0,0

.nw10	!byte 0,0,0
	!byte 0,0,0
	!byte 1,1,0

.nw11	!byte 0,1,1
	!byte 0,0,0
	!byte 0,0,0

.nw12	!byte 0,0,0
	!byte 0,1,1
	!byte 0,0,0

.nw13	!byte 0,0,0
	!byte 0,0,0
	!byte 0,1,1

.nw14	!byte 0,0,0
	!byte 1,0,0
	!byte 1,0,0

.nw15	!byte 0,0,0
	!byte 0,1,0
	!byte 0,1,0

.nw16	!byte 0,0,0
	!byte 0,0,1
	!byte 0,0,1

.nw17	!byte 1,0,0
	!byte 0,0,0
	!byte 1,0,0

.nw18	!byte 1,0,1
	!byte 0,0,0
	!byte 0,0,0

.nw19	!byte 0,0,1
	!byte 0,0,0
	!byte 0,0,1

.nw20	!byte 0,0,0
	!byte 0,0,0
	!byte 1,0,1

.nw21	!byte 0,0,0
	!byte 1,0,1
	!byte 0,0,0

.nw22	!byte 0,1,0
	!byte 0,0,0
	!byte 0,1,0

.rndnum !byte 0

.jmp_table !word .is1, .is2, .is3, .is4, .is5, .is6, .is7, .is8, .is9

.keypress !byte 49,50,51,52,53,54,55,56,57
Ai_score !byte 0
Human_score !byte 0

}
