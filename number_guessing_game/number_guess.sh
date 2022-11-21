#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=namnum -t --no-align -c"

echo "Enter your username:"
read NAME

NAME_SEL=$($PSQL "SELECT name, games_played, best_game FROM users WHERE name='$NAME'")
if [[ -z $NAME_SEL ]]
then 
  USERNAME=$($PSQL "INSERT INTO users(name) VALUES ('$NAME')")
  echo "Welcome, $NAME! It looks like this is your first time here."
else
  echo "$NAME_SEL" | while IFS="$|" read USERNAME GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

control=0
COND=1
RANDNUM=$(($RANDOM % 1000 +1))
echo "Guess the secret number between 1 and 1000:"
while [ $COND -eq 1 ]
do
  read GUESS
  if ! [[ "$GUESS" =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
  else
    control=$(( control + 1 ))
    x=$(( $GUESS - $RANDNUM ))
    if [ $x -eq 0 ]; then
      echo "You guessed it in $control tries. The secret number was $RANDNUM. Nice job!"
      COND=0
    elif [ $x -lt 0 ]; then 
      echo "It's higher than that, guess again:"
    elif [ $x -gt 0 ]; then
      echo "It's lower than that, guess again:"
    fi
  fi
done

# add to the database
NAME_SEL=$($PSQL "SELECT name, games_played, best_game FROM users WHERE name='$NAME'")
echo "$NAME_SEL" | while IFS="$|" read USERNAME GAMES_PLAYED BEST_GAME
do
  UPDATE_PLAYED_RESULT=$($PSQL "UPDATE users SET games_played=$(( GAMES_PLAYED + 1)) WHERE name='$NAME'")
  if [ $control -lt $BEST_GAME ]; then

    UPDATE_BEST_RESULT=$($PSQL "UPDATE users SET best_game=$control WHERE name='$NAME'")
  fi
  
done