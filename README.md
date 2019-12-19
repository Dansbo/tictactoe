# tictactoe
TicTacToe for the commanderX16

Kudos to Jimmy Dansbo
I've got a lot of help from my brother Jimmy Dansbo. Who has been so nice as to
go through my code, when I couldn't figure out what was wrong.

This is my very first attempt of writing a game in assembler.
In order to keep it simple I have only used the PETSCII characters in the X16

My first order of busines was to make the playing 'field'
TicTacToe is a simple yet complicated game.
The thought is to implement a computer player that plays sort of the same way
as a human.

I have been inspired by the YouTube video TicTacToe in brainfuck:
  https://www.youtube.com/watch?v=qK0vmuQib8Y

This video assisted me in chosing 3 arrays to keep track of where the gamepieces
have been placed. One for X one for O and one to mark occupied game tiles.

I am struggling to create a loop that will figure out, that someone has won the
game after the gamepiece has been placed.

As I figure there are only 8 different scenarios that give a win:

  1 1 1     0 0 0     0 0 0     1 0 0     0 0 1     0 1 0     1 0 0     0 0 1
  0 0 0     1 1 1     0 0 0     0 1 0     0 1 0     0 1 0     1 0 0     0 0 1
  0 0 0     0 0 0     1 1 1     0 0 1     1 0 0     0 1 0     1 0 0     0 0 1

Each of the scenarios should 'catch' when the play has achieved any one of them
regardless if other tiles are occupied or not.
