#!/bin/bash

PSQL="psql -U freecodecamp --dbname number_guess --no-align --tuples-only -c"

echo "Enter your username (up to 22 characters):"
read -r -n 22 USERNAME

# Truncate the username if it exceeds 22 characters
USERNAME="${USERNAME:0:22}"

# Check if the user exists in the database
USERNAME_AVAIL=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")

if [[ -z $USERNAME_AVAIL ]]; then
  # If the user doesn't exist, insert the new user into the database
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  echo "Welcome back, $USERNAME! You have played <games_played> games, and your best game took <best_game> guesses."
fi

# Generate a random number for the game
RANDOM_NUM=$((1 + $RANDOM % 1000))
GUESS=1
echo "Guess the secret number between 1 and 1000:"

while read -r NUM; do
  if ! [[ $NUM =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
  else
    if [[ $NUM -eq $RANDOM_NUM ]]; then
      break;
    else
      if [[ $NUM -gt $RANDOM_NUM ]]; then
        echo -n "It's lower than that, guess again:"
      elif [[ $NUM -lt $RANDOM_NUM ]]; then
        echo -n "It's higher than that, guess again:"
      fi
    fi
  fi
  GUESS=$((GUESS + 1))
done

# Insert the game details into the database
INSERT_GAME=$($PSQL "INSERT INTO games (number_guesses, user_id) VALUES ($GUESS, (SELECT id FROM users WHERE username='$USERNAME'))")

if [[ $GUESS -eq 1 ]]; then
  echo "You guessed it in $GUESS try. The secret number was $RANDOM_NUM. Nice job!"
else
  echo "You guessed it in $GUESS tries. The secret number was $RANDOM_NUM. Nice job!"
fi
