#!/bin/bash

source $XDG_CONFIG_HOME/sbanken/config

getToken() {
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
  echo "  -A              Returns primary account"
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

  if [[ -n $verbose && $verbose == 'true' ]] ; then
    accountsOutputFormat="%-20s\t%-20s\t%-11s\t%8.2f 💰\n"
  else
    accountsOutputFormat="%-20s\t%-11s\t%8.2f 💰\n"
  fi

  for i in $(seq 0 $(($accountMatches - 1)))
  do
    accountNumber=$(echo $accounts | jq -r ".items[$i].accountNumber")
    if [[ -n $verbose && $verbose == 'true' ]] ; then
      accountId=$(echo $accounts | jq -r ".items[$i].accountId")
    fi
    balance=$(echo $accounts | jq -r ".items[$i].available")
    name=$(echo $accounts | jq -r ".items[$i].name")

    if [[ -n $verbose && $verbose == 'true' ]] ; then
      printf "$accountsOutputFormat" "$accountId" "$name" "$accountNumber" "$balance"
    else
      printf "$accountsOutputFormat" "$name" "$accountNumber" "$balance"
    fi
  done
}

getAccount() {
  echo "Account $enteredAccountId"
  account=$(curl -q -H "Authorization: Bearer $token" "https://publicapi.sbanken.no/apibeta/api/v2/accounts/$enteredAccountId"  2>/dev/null)

  if [[ -n $verbose && $verbose == 'true' ]] ; then
    accountNumber=$(echo $account | jq -r ".accountNumber")
    accountId=$(echo $account | jq -r ".accountId")
    accountsOutputFormat="%-20s\t%-20s\t%-11s\t%8.2f 💰\n"
  else
    accountsOutputFormat="%-20s\t%8.2f 💰\n"
  fi
  balance=$(echo $account | jq -r ".available")
  name=$(echo $account | jq -r ".name")

  if [[ -n $verbose && $verbose == 'true' ]] ; then
    printf "$accountsOutputFormat" "$accountId" "$name" "$accountNumber" "$balance"
  else
    printf "$accountsOutputFormat" "$name" "$balance"
  fi
}

getTransactions() {
  echo "Transactions for $enteredAccountId"
  transactions=$(curl -q -H "Authorization: Bearer $token" "https://publicapi.sbanken.no/apibeta/api/v2/transactions/$enteredAccountId"  2>/dev/null)
  transactionsMatches=$(echo $transactions|jq -r .availableItems)

  for i in $(seq 0 $(($transactionsMatches - 1)))
  do
    transactionDate=$(echo $transactions | jq -r ".items[$i].accountingDate")
    transactionAmount=$(echo $transactions | jq -r ".items[$i].amount")
    transactionText=$(echo $transactions | jq -r ".items[$i].text")
    if [[ $transactionAmount =~ "-" ]]; then
      transactionOutputFormat="%-20s\t%.20s\t\t\t%8.2f 🤑\n"
    else
      transactionOutputFormat="%-20s\t%.20s\t\t\t%8.2f 💸\n"
    fi

    if [[ -n $verbose && $verbose == 'true' ]] ; then
      printf "$transactionsOutputFormat" "$accountId" "$name" "$accountNumber" "$balance"
    else
      printf "$transactionOutputFormat" "$transactionDate" "$transactionText" "$transactionAmount"
    fi
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

verbose='false'

while getopts 'Aacetvh' flag; do
  case "${flag}" in
    a)  getToken 
        eval nextopt=\${$OPTIND}
        # existing and not starting with dash?
        if [[ -n $nextopt && $nextopt != -* ]] ; then
          OPTIND=$((OPTIND + 1))
          enteredAccountId=$nextopt
          getAccount
        else
          getAccounts
        fi ;;
    A)  if [[ -n $primaryAccount ]] ; then
          echo $primaryAccount
          enteredAccountId=$primaryAccount
          getToken
          getAccount
        else
          echo "Missing primaryAccount from config"
          displayHelp
        fi ;;
    c)  getToken
        getCards ;;
    e)  getToken
        getEfaktura ;;
    t)  getToken
        eval nextopt=\${$OPTIND}
        # existing and not starting with dash?
        if [[ -n $nextopt && $nextopt != -* ]] ; then
          OPTIND=$((OPTIND + 1))
          enteredAccountId=$nextopt
          getTransactions
        else
          echo "Missing accountId"
          displayHelp
        fi ;;
    v)  verbose='true' ;;
    h | *)  displayHelp
        exit 1 ;;
  esac
done


