#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~~~~ COOL SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi
  
  SERVICES=$($PSQL "SELECT * FROM services")

  echo "$SERVICES" | while IFS='|' read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Selection must be a number, please try again:"
  else

    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    
    if [[ -z $SERVICE_NAME ]]
    then
      MAIN_MENU "Sorry, that service does not exist, please select a valid option:"
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "\nYou're not registered yet, what's your name?"
        read CUSTOMER_NAME

        CUSTOMER_INSERT_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi

      echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME

      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      
    fi
  fi
}

MAIN_MENU "Welcome to Cool Salon, please select one of our services:"