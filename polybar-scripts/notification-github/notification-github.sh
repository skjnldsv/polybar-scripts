#!/bin/sh

PAGE=1
PER_PAGE=50
NOTIFICATIONS=0

# Check if it's Monday or the weekend
if [[ $(date +%u) -lt 2 || $(date +%u) -gt 5 ]]
then
    echo ''
    exit 0
fi

# Loop all pages
until [[ $(( $NOTIFICATIONS % $PER_PAGE )) != 0 ]]
do
    response=$(curl --silent -H "Authorization: Bearer ${GITHUB_TOKEN}" "https://api.github.com/notifications?per_page=${PER_PAGE}&page=${PAGE}" | jq -c)
    has_message=$(echo $response | jq -r '.message?')

    # If github returns an error, display it.
    # e.g "Bad credentials"
    if [[ ! -z "$has_message" ]]; then
        echo $has_message
        exit 0
    fi

    # If the curl is empty, the network is most likely down.
    if [[ ! "$response" ]]; then
        echo "Github unreachable"
        exit 0
    fi

    # Count all notifications
    count=$(echo $response | jq '.[].unread' | grep -c true)
    NOTIFICATIONS=$(($count + $NOTIFICATIONS))
    PAGE=$(($PAGE + 1))

    # If no notifications on the first page, we stop here.
    if [[ "$NOTIFICATIONS" == 0 ]]; then
        echo "0"
        exit 0 
    fi
done

echo $NOTIFICATIONS
