# tictactoe
TicTacToe for the commanderX16

Kudos to Jimmy Dansbo
I've got a lot of help from my brother Jimmy Dansbo. Who has been so nice as to
go through my code, when I couldn't figure out what was wrong.

This is my very first attempt of writing a game in assembler.
In order to keep it simple I have only used the PETSCII characters in the X16

My first order of busines was to make the playing 'field'
TicTacToe is a simple yet complicated game.
The thought is to implement a computer player that plays sort of the same way as a human.

I have been inspired by the YouTube video TicTacToe in brainfuck:
  https://www.youtube.com/watch?v=qK0vmuQib8Y

This video assisted me in chosing 3 arrays to keep track of where the gamepieces
have been placed. One for X one for O and one to mark occupied game tiles.

I was struggling to create a loop that will figure out, that someone has won the
game after the gamepiece has been placed.

As I figure there are only 8 different scenarios that give a win:

        111     000     000     100     010     001     100     001
        000     111     000     100     010     001     010     010
        000     000     111     100     010     001     001     100

Each of the scenarios should 'catch' when the play has achieved any one of them
regardless if other tiles are occupied or not.

After a lot of rewriting I have finally ended up with a working version.
My next goal is to write some form of computer opponent.

My initial thought was to set down some 'rules' for the AI:

        1: If first or second move 'capture' center tile if possible
        2: If not first move then chose or not available then chose edge tile randomly
        3: If third or above move then:
                a: Can AI win? if so do
                b: Can human win? if so block
                c: If none of the above choose random tile

Again I figure there is a set number of near wins:

        001     100     000     000     100     010     001     110
        010     010     010     010     100     010     001     000
        000     000     100     001     000     000     000     000

        000     000     011     000     000     000     000     000
        110     000     000     011     000     100     010     001
        000     110     000     000     011     100     010     001

        100     101     001     000     010     000
        000     000     000     000     000     101
        100     000     001     101     010     000

The observant reader would recognise that I have not included the near win scenarios diagonally. The reason for this, is that I programmed my AI to take the center tile, if the user has not done so. This means that I will never come in the situation where the top left corner and the bottom right corner has been taken without a win, or that the AI has blocked the user from winning.

So the AI has to be able to spot these scenarios both for itself and for the human player.

First time I wrote the AI routine I tried to incorporate the check for each near win scenario. But I realized that the routine chose the 1 routine that fit either AI or Human near win. And that is not what I wanted. I wanted the AI to jump to a win first and if no win is apparrent then block the human from winning.

I finally finished my very first game in assembler.
The game needs some testing, but I'm confident that the game is working as is.
I worked in for the "AI" to make a mistake once in a while, so the player is able to win.
