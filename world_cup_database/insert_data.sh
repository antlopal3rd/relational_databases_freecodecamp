#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE games,teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT W_GOALS O_GOALS
do
  if [[ $YEAR != "year" && $ROUND != "round" ]]
  then
    TEAMS1=$($PSQL "select name from teams where name = '$WINNER'")
    if [[ -z $TEAMS1 ]]
    then
      INSERT_TEAMS1=$($PSQL "insert into teams(name) values('$WINNER')")
      if [[ INSERT_TEAMS1 = "INSERT 0 1" ]]
      then
        echo Inserted into teams: $WINNER
      fi 
    fi

    TEAMS2=$($PSQL "select name from teams where name = '$OPPONENT'")
    if [[ -z $TEAMS2 ]]
    then
      INSERT_TEAMS2=$($PSQL "insert into teams(name) values('$OPPONENT')")
      if [[ INSERT_TEAMS2 = "INSERT 0 1" ]]
      then
        echo Inserted into teams: $OPPONENT
      fi 
    fi

    WINNER_ID=$($PSQL "select team_id from teams where name='$WINNER'")
    OPPONENT_ID=$($PSQL "select team_id from teams where name='$OPPONENT'")

    INSERT=$($PSQL "insert into games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) values($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $W_GOALS, $O_GOALS)")
    if [[ INSERT = "INSERT 0 1" ]]
      then
        echo Inserted into games: $YEAR
      fi 

  fi
done
