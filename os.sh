#!/bin/bash

OS=$(uname -s)

if [[ "$OS" == "Linux" ]]; then
  echo "This is a Linux system."
elif [[ "$OS" == "Darwin" ]]; then
  echo "This is a macOS system."
else
  echo "Unknown operating system: $OS"
fi


# VARIABLE_TO_UPDATE="API_KEY"
# NEW_VALUE="${DATABASE}://${POSTGRES_USER}:${POSTGRES_PASSWORD}@localhost:${POSTGRES_DB_PORT}/${POSTGRES_DB}"

# sed -i "s/^$VARIABLE_TO_UPDATE=.*$/$VARIABLE_TO_UPDATE=$NEW_VALUE/" .env

# if [ $? -eq 0 ]; then
#   echo "Successfully updated $VARIABLE_TO_UPDATE in .env"
# else
#   echo "Error updating .env file!"
# fi
