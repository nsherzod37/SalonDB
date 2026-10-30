#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # Вывод списка услуг
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # Запрос выбора услуги
  read SERVICE_ID_SELECTED

  # Проверяем, существует ли такая услуга
  SERVICE_EXIST=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_EXIST ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # Запрос номера телефона
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    # Проверяем, есть ли клиент в базе
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'" | sed 's/ //g')

    # Если клиента нет — запрашиваем имя и добавляем в базу
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    # Получаем customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'" | sed 's/ //g')

    # Получаем название услуги для финального сообщения
    SERVICE_NAME_FORMATTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED" | sed 's/ //g')

    # Запрос времени записи
    echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # Создаем запись в таблице appointments
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    # Финальное сообщение
    echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU