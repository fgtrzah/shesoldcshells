#!/bin/bash

# Define the list of endpoints from the provided JSON data
endpoints=(
  "https://www.peeringdb.com/api/fac"
  "https://www.peeringdb.com/api/carrier"
  "https://www.peeringdb.com/api/carrierfac"
  "https://www.peeringdb.com/api/ix"
  "https://www.peeringdb.com/api/ixfac"
  "https://www.peeringdb.com/api/ixlan"
  "https://www.peeringdb.com/api/ixpfx"
  "https://www.peeringdb.com/api/net"
  "https://www.peeringdb.com/api/poc"
  "https://www.peeringdb.com/api/netfac"
  "https://www.peeringdb.com/api/netixlan"
  "https://www.peeringdb.com/api/org"
  "https://www.peeringdb.com/api/campus"
  "https://www.peeringdb.com/api/as_set"
)

# Define the maximum number of concurrent requests
MAX_CONCURRENT_REQUESTS=5
DELAY=2 # Delay to respect API throttling

# Function to fetch and print the response from an endpoint with syntax highlighting
fetch_endpoint() {
  local url="$1"
  echo "Fetching $url"
  response=$(curl -s "$url")
  if [ -n "$response" ]; then
    echo "Response from $url:"
    echo "$response" | jq '.' # Syntax highlight JSON output
    echo "---------------------------------"
  else
    echo "No response from $url"
    echo "---------------------------------"
  fi
}

# Track the number of background jobs
job_count=0

# Loop through each endpoint and fetch its response asynchronously
for url in "${endpoints[@]}"; do
  fetch_endpoint "$url" &
  ((job_count++))

  # Wait for background jobs to complete if we reach the maximum limit
  if [ "$job_count" -ge "$MAX_CONCURRENT_REQUESTS" ]; then
    wait           # Wait for all background jobs to finish
    job_count=0    # Reset job count
    sleep "$DELAY" # Respect API throttling
  fi
done

# Wait for any remaining background jobs to finish
wait
