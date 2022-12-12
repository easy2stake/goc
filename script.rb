#!/usr/bin/ruby

require_relative './ruby-framework.rb'

$in_file='./all-chains-block-metas/provider_uniq.log'
$in_file2='./all-chains-block-metas/apollo_uniq.log'

uniq_out_file="./strange_uniq.log"
unordered_out_file="./unordered-provider-strange.log"
unmatching_out_file="./unmatching-provider-strange.log"

blocks=json_file_to_hash($in_file)
blocks2=json_file_to_hash($in_file2)


# Parse blocks metadatas and keep only the ones that contains unique validators_hash, as they were received in order.
def find_uniq_valsets(blocks)
  uniq = []
  last_block = ""
  blocks.each do |block|

    if block["validators_hash"] == last_block["validators_hash"]
      # The current validators_hash is the same as the previous one
      next
    else
      # There is a new validators_hash detected
      uniq << block
    end

    last_block = block
  end
  return uniq
end

# Find customer validators_hash that never existed on provider
def find_unmatching_valsets(provider, customer)
  unmatching = []
  customer.each do |customer_block|
      # Reset the match variable for each customer block
      match = false
      provider.each do |prov_block|
          if customer_block["validators_hash"] == prov_block["validators_hash"]
            match = true
            break
          end
      end
      if ! match
        unmatching << customer_block
      end
  end
  return unmatching
end

# Find customer validators_hash that were received BEFORE provider
def find_unordered_valsets(provider, customer)
  unordered = []

  customer.each do |customer_block|
      # Reset the match variable for each customer block
      is_ordered = true
      provider.each do |prov_block|
          if customer_block["validators_hash"] == prov_block["validators_hash"]
            c_block_time = customer_block["block_time"]
            p_block_time = prov_block["block_time"]
            diff = time_diff_seconds(c_block_time, p_block_time)

            # If the difference is positive, consider it is unordered
            # Provider should be the first one to get the new set, meaning time_provider - time_customer => Must always be negative
            if diff > 0
              is_ordered = false
              break
            end

            # The hash was found, break out of the inner loop
            break
          end
      end

      # If no match was found, add the customer block to the list of unmatching blocks
      if ! is_ordered
        unordered << customer_block
      end
  end

  return unordered
end

# Find customer validators_hash that were received "LATE".
# We can configure what "LATE" means in the `late_seconds` variable inside the function.
def find_late_sync_valsets(provider, customer)
  late_sync_blocks = []
  late_seconds = -180

  customer.each do |customer_block|
      # Reset the match variable for each customer block
      is_late_sync = false
      provider.each do |prov_block|
          if customer_block["validators_hash"] == prov_block["validators_hash"]
            c_block_time = customer_block["block_time"]
            p_block_time = prov_block["block_time"]
            diff = time_diff_seconds(c_block_time, p_block_time)

            # If the difference is positive, consider it is late_sync_blocks
            # Provider should be the first one to get the new set, meaning time_provider - time_customer => Must always be negative
            if diff <  late_seconds
              is_late_sync = true
              break
            end

            # The hash was found, break out of the inner loop
            break
          end
      end

      # If no match was found, add the customer block to the list of unmatching blocks
      if is_late_sync
        late_sync_blocks << customer_block
      end
  end

  return late_sync_blocks
end


# write_to_file(find_uniq_valsets(blocks).to_json, uniq_out_file)
# write_to_file(find_unordered_valsets(blocks, blocks2).to_json, unordered_out_file)
# write_to_file(find_unmatching_valsets(blocks, blocks2).to_json, unmatching_out_file)

puts find_late_sync_valsets(blocks, blocks2).to_json
