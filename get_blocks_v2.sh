#!/bin/bash

function curl_with_retry {
  max_retries=5
  retries=0
  return_code=1

  while [ $return_code -ne 0 ] && [ $retries -lt $max_retries ]; do
    retries=$((retries+1))
    curl -s -k -m 3 $1
    return_code=$?

    # If the curl command failed, sleep for 5 seconds before trying again
    if [ $return_code -ne 0 ]; then
      sleep 1
    fi
  done

  # Return the final return code of the curl command
  return $return_code
}

function get_blocks {
  RPC=$1
  start_block=$2
  end_block=$3

  for i in $(seq $start_block $end_block)
  do
  echo "{"
    curl_with_retry $RPC/block?height=$i | jq '"\"block_height\": " +  "\"" + .result.block.header.height + "\",",
                                                "\"block_hash\": " +  "\"" + .result.block_id.hash + "\",",
                                                "\"block_time\": " +  "\"" + .result.block.header.time + "\",",
                                                "\"validators_hash\": " +  "\"" + .result.block.header.validators_hash + "\",",
                                                "\"next_validators_hash\": " +  "\"" +  .result.block.header.next_validators_hash + "\""' -r
  echo "},"
  done
}

get_blocks $1 $2 $3

