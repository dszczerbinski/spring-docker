#!/bin/bash

function main() {
    set -e
    set -u

    apiUrl="https://randomuser.me/api/"
    totalUsers=100
    batchSize=5
    pauseBetweenBatches=2

    createMultipleUsers
}

function createUserFromResponse() {    
    local response=$(curl -s "$apiUrl")

    local firstName=$(echo "$response" | grep -o '"first":"[^"]*"' | cut -d'"' -f4)
    local lastName=$(echo "$response" | grep -o '"last":"[^"]*"' | cut -d'"' -f4)
    local username=$(echo "$response" | grep -o '"username":"[^"]*"' | cut -d'"' -f4)

    echo "Creating user $username ($firstName $lastName)"
    sudo useradd -m -c "$firstName $lastName" "$username"
}

function createMultipleUsers() {
    local batchCount=$((totalUsers / batchSize))

    echo "Will process $totalUsers users in $batchCount batches of $batchSize users each"

    for ((batch=1; batch<=batchCount; batch++)); do
        echo "Processing batch $batch of $batchCount..."
        
        for ((i=1; i<=batchSize; i++)); do
            createUserFromResponse &
        done
        
        wait
        
        if [ $batch -lt $batchCount ]; then
            echo "Pausing for $pauseBetweenBatches seconds before next batch..."
            sleep $pauseBetweenBatches
        fi
    done
    
    echo "All user creation tasks completed."
}

main
