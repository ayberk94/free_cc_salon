#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"



MAIN_MENU () {
  echo -e $1
  echo -e "Pick a service-nr\n"
  echo "$($PSQL "SELECT * FROM services;" )" | while read SERVICE_ID BAR SERVICE_NAME
  do 
    echo $SERVICE_ID\) $SERVICE_NAME
  done
  read SERVICE_ID_SELECTED
  SERVICE_ID_CHOICE_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED;" 2> /dev/null)

  if [[ -z $SERVICE_ID_CHOICE_RESULT ]]
  then
    MAIN_MENU "not a valid choice\n"
  else
    echo -e "\nWhat is your phone-nr?"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
    if [[ -z $CUSTOMER_ID ]]
    then
      echo -e "\nYou're not customer yet. What is your name?"
      read CUSTOMER_NAME
      ADD_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
    else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID;" | sed 's/^ //')
    fi
    echo -e "\nPick your service time"
    read SERVICE_TIME
    CREATE_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;"| sed 's/^ //')
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}




MAIN_MENU

