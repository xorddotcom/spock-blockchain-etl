#!/usr/bin/env bash

# https://gist.github.com/vncsna/64825d5609c146e80de8b1fd623011ca
set -euo pipefail

# start_block -> 12395780 -> 8 may 2021 (bull market)
# end_block -> start_block + 10,000 (12405780)

# START_BLOCK=15923348 # 15914348 (10,000) & 15923348 (1000)
# END_BLOCK=15924348

# Define the input vars
START_BLOCK=${1?Error: Please pass start block number}
END_BLOCK=${2?Error: Please pass end block number}
# BATCH_SIZE=${3?Error: Please pass batch size}

echo "START_BLOCK: $START_BLOCK"
echo "END_BLOCK: $END_BLOCK"
# echo "BATCH_SIZE: $BATCH_SIZE"
echo "TOTAL BLOCKS: $((END_BLOCK - START_BLOCK))"

PROVIDER_URI="https://rpc.ankr.com/eth"
OUTPUT_DIR="./data"

### export_blocks_and_transactions
echo "export_blocks_and_transactions"
python3 ethereumetl.py export_blocks_and_transactions \
  --provider-uri ${PROVIDER_URI} \
  --start-block ${START_BLOCK} \
  --end-block ${END_BLOCK} \
  --blocks-output ${OUTPUT_DIR}/blocks.csv \
  --transactions-output ${OUTPUT_DIR}/transactions.csv
  # --batch-size ${BATCH_SIZE}

### export_receipts_and_logs
echo "export_receipts_and_logs"
python3 ethereumetl.py extract_csv_column \
  --input ${OUTPUT_DIR}/transactions.csv \
  --column hash \
  --output ${OUTPUT_DIR}/transaction_hashes.txt

python3 ethereumetl.py export_receipts_and_logs \
  --provider-uri ${PROVIDER_URI} \
  --transaction-hashes ${OUTPUT_DIR}/transaction_hashes.txt \
  --receipts-output ${OUTPUT_DIR}/receipts.csv \
  --logs-output ${OUTPUT_DIR}/logs.csv
  # --batch-size ${BATCH_SIZE}

### extract_token_transfers
echo "extract_token_transfers"
python3 ethereumetl.py extract_token_transfers \
  --logs ${OUTPUT_DIR}/logs.csv \
  --output ${OUTPUT_DIR}/token_transfers.csv
  # --batch-size ${BATCH_SIZE}

### export_contracts
echo "export_contracts"
python3 ethereumetl.py extract_csv_column \
  --input ${OUTPUT_DIR}/receipts.csv \
  --column contract_address \
  --output ${OUTPUT_DIR}/contract_addresses.txt

python3 ethereumetl.py export_contracts \
  --provider-uri ${PROVIDER_URI} \
  --contract-addresses ${OUTPUT_DIR}/contract_addresses.txt \
  --output ${OUTPUT_DIR}/contracts.csv
  # --batch-size ${BATCH_SIZE}

### export_tokens
echo "export_tokens"
python3 ethereumetl.py filter_items -i ${OUTPUT_DIR}/contracts.csv -p "item['is_erc20'] or item['is_erc721']" | \
python3 ethereumetl.py extract_field -f address -o ${OUTPUT_DIR}/token_addresses.txt

python3 ethereumetl.py export_tokens \
  --provider-uri ${PROVIDER_URI} \
  --token-addresses ${OUTPUT_DIR}/token_addresses.txt \
  --output ${OUTPUT_DIR}/tokens.csv
