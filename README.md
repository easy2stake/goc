# Task 9
**Our methodology:**
1. Downloaded all blocks metadata, from all chains (see git) in the following format:
  ```sh
  {
    "block_height": "",
    "block_hash": "",
    "block_time": "",
    "validators_hash": "",
    "next_validators_hash": ""
  }```

2. After creating local *dbs* with each block metas like the one above, we used the function called `find_uniq_valsets` in our **script.rb** to generate a local copy containing only the first blocks that received a new **"validators_hash"**.
At this point, we have all the blocks, on all chains, that contains only the **validators_hash** changes.

3. We look inside the metas of each block from customer chain and croos-check with the ones from the provider:
- For each newly encountered **validators_hash** on the customer we validate that there is a matching **validators_hash** on the provider.
- if we find a match, we consider it "OK" and skip to the next block on the customer chain.
- if we don't find a match it means that *this customer validators_hash* never existed on the provider.
- we save all the findings to file

**Log data can be found in:**   [task9 folder](./task9): unmatching-provider-[chain-name].log



# Task 10

**Our methodology:**

1. Downloaded all blocks metadata, from all chains (see git) in the following format:
  ```sh
  {
    "block_height": "",
    "block_hash": "",
    "block_time": "",
    "validators_hash": "",
    "next_validators_hash": ""
  }
  ```

2. After creating local *dbs* with each block metas like the one above, we used the function called `find_uniq_valsets` in our **script.rb** to generate a local copy containing only the first blocks that received a new **"validators_hash"**.
At this point, we have all the blocks, on all chains, that contains only the **validators_hash** changes.

3. We use the function `find_unordered_valsets` that is looking at **block_time** and does the following comparation:
- Checks all the **validators_hash** inside a customer chain
- For each new **validators_hash** inside the customer chain, it's looking for its pair block inside the provider chain.
- after finding the block inside the provider chain, it is comparing the block_time.
- If the **block_time** of customer is "earlier" that the **block_time** of the provider we consider it an **UNORDERED_MATCH**.

We save all the **UNORDERED_MATCH** blocks of the customer chain and print them as a JSON Array.

**Results**: By using this methodology, we couldn't find any UNORDERED_MATCH event in the chains we looked into: apollo, duality, flash, gopher, hero, neutron, schwifty, sputnik, strange.

**Log data can be found in:**   [task10 folder](./task10)
