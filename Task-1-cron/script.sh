#!/bin/bash

# set -x
set -e

TIMEOUT=${TIMEOUT:-4}
URL=${URL:-https://primarybid.com}
DOWN_STATE_FILE=${DOWN_STATE_FILE:-.primarybid_state}
LOG_FILE="/var/log/status.log"

trap "exit 1" TERM

for i in "$@"; do
  case $i in
    -t=*|--timeout=*)
      TIMEOUT="${i#*=}"
      shift
      ;;
    -e=*|--email=*)
      EMAIL="${i#*=}"
      shift
      ;;
    *)
      >&2 echo "Unknown option: $i" # stderr
      exit 1
      ;;
    *)
      ;;
  esac
done

if test -z "$EMAIL"; then
    echo "Error: Please provide a comma-separated list of emails as an argument."
    # >&2 echo "Missing required URL" # stderr
    exit 1;
fi


if [ -n "$TIMEOUT" ] && [ "$TIMEOUT" -eq "$TIMEOUT" ] 2>/dev/null; then
  # nothing TODO
  :
else 
  echo $TIMEOUT is not number. Provide proper timeout value.
  exit 1;
fi

function send_alert() {
  subject="Website Down Alert: PrimaryBid.com"
  message="The website $URL has been down for 3 consecutive checks."

  # send alert to each individual email address in the array
  for recipient in "${email_array[@]}"; do
    echo "echo \"Subject: $subject\n\n$message\" | mail -s \"$subject\" $recipient"
  done
}

# Split the comma-separated list into an array
readarray -t email_array < <(awk -F',' '{ for( i=1; i<=NF; i++ ) print $i }' <<<"$EMAIL")
# Loop through each email in the array
for email in "${email_array[@]}"; do
  # Basic validation (checks for @ and .)
  if [[ ! "$email" =~ .*@.* ]]; then
    echo "Warning: '$email' doesn't seem like a valid email address."
    exit 1;
  fi
done


# Check if a "down" state file exists
down_state_file=".primarybid_down"
if [[ ! -f "$down_state_file" ]]; then
  consecutive_failures=0
else 
  consecutive_failures=$(head -n 1 $down_state_file)
fi

# Check website availability
timestamp=$(date +%F:%T)
status_code=$(curl -sL -o /dev/null -w "%{http_code}" -m "$TIMEOUT" $URL)
# echo $TIMEOUT $status_code $consecutive_failures

# Analyze response and update state
if [[ $status_code -ne 200 ]]; then
  ((consecutive_failures++))
  echo "$consecutive_failures" > $DOWN_STATE_FILE

  if [[ $consecutive_failures -eq 3 ]]; then
    send_alert "$emails"
  fi
else
  # Site is back up, reset state
  consecutive_failures=0
  echo "$consecutive_failures" > $DOWN_STATE_FILE
  # echo $consecutive_failures |& tee $DOWN_STATE_FILE
  # rm -f "$down_state_file"
fi

# Informative message
if [[ $status_code -eq 200 ]]; then
  echo "$timestamp Website $URL is UP"
else
  echo "$timestamp Website $URL is DOWN (consecutive failures: $consecutive_failures)"
fi
