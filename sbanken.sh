#!/bin/bash

getToken() {
  source ~/repos/sbanken.sh/.env

  acceptHeader='Accept: application/json'
  contentTypeHeader='Content-Type: application/x-www-form-urlencoded; charset=utf-8'

  requestBody='grant_type=client_credentials'

  token=$(curl -q -u "$clientId:$secret" -H "$acceptHeader" -H "$contentTypeHeader" -d "$requestBody" 'https://auth.sbanken.no/IdentityServer/connect/token' 2>/dev/null| jq -r .access_token)
}

displayHelp() {
  echo "Sbanken TUI"
  echo 
  echo "USAGE:"
  echo "  sbanken"
  echo
  echo "ARGUMENTS:"
  echo "  -h, --help      Print Help (this message)"
  echo "  -a, --accounts  Returns all available accounts"
  echo "  -c, --cards     Returns all available cards"
  echo "  -e, --efaktura  Returns all available cards"
  echo
  echo "DESCRIPTION:"
  echo "  WIP"
  echo

  exit 0
}

getAccounts() {
  echo "Accounts"
  accounts=$(curl -q -H "Authorization: Bearer $token" "https://publicapi.sbanken.no/apibeta/api/v2/accounts"  2>/dev/null)
  accountMatches=$(echo $accounts|jq -r .availableItems)

  for i in $(seq 0 $(($accountMatches - 1)))
  do
    accountNumber=$(echo $accounts | jq -r ".items[$i].accountNumber")
    balance=$(echo $accounts | jq -r ".items[$i].available")
    name=$(echo $accounts | jq -r ".items[$i].name")
    printf "%-20s\t%-11s\t%8.2f 💰\n" "$name" "$accountNumber" "$balance"
  done
}

getCards() {
  echo "Cards"
  cards=$(curl -q -H "Authorization: Bearer $token" "https://publicapi.sbanken.no/apibeta/api/v2/cards"  2>/dev/null)
  cardMatches=$(echo $cards|jq -r .availableItems)

  for i in $(seq 0 $(($cardMatches - 1)))
  do
    cardNumber=$(echo $cards | jq -r ".items[$i].accountNumber")
    cardStatus=$(echo $cards | jq -r ".items[$i].status")
    accountOwner=$(echo $cards | jq -r ".items[$i].accountOwner")
    printf "%-20s\t%-11s\t%-20s\n" "$cardNumber" "$cardStatus" "$accountOwner"
  done
}

getEfaktura() {
  echo "Efaktura"
  efaktura=$(curl -q -H "Authorization: Bearer $token" "https://publicapi.sbanken.no/apibeta/api/v2/efaktura"  2>/dev/null)
  efakturaMatches=$(echo $cards|jq -r .availableItems)

  for i in $(seq 0 $(($cardMatches - 1)))
  do
    issuerName=$(echo $efaktura | jq -r ".items[$i].issuerName")
    efakturaStatus=$(echo $efaktura | jq -r ".items[$i].status")
    amount=$(echo $efaktura | jq -r ".items[$i].originalAmount")
    printf "%-20s\t%-11s\t%8.2f\n" "$issuerName" "$efakturaStatus" "$amount"
  done
}

if [ "$1" == "-h" ] || [ "$1" == "--help" ] || [ "$#" -lt 1 ]; then
    displayHelp
fi

getToken
for arg in "$@"
do
  if [ "$arg" == "-c" ] || [ "$arg" == "--cards" ]; then
    getCards
  elif [ "$arg" == "-a" ] || [ "$arg" == "--accounts" ]; then
    getAccounts
  elif [ "$arg" == "-e" ] || [ "$arg" == "--efaktura" ]; then
    getEfaktura
  fi
done

