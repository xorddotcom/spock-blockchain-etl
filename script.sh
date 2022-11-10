# 1000 blocks

START_BLOCK=15924248
END_BLOCK=15924348 # 15914348 (10,000) & 15923348 (1000)

# export_blocks_and_transactions
python3 ethereumetl.py export_blocks_and_transactions \
  --provider-uri https://rpc.ankr.com/eth \
  --start-block $START_BLOCK \
  --end-block $END_BLOCK \
  --blocks-output blocks.json \
  --transactions-output transactions.json

# # export_receipts_and_logs
# python3 ethereumetl.py extract_csv_column \
#   --input transactions.csv \
#   --column hash \
#   --output transaction_hashes.txt

# python3 ethereumetl.py export_receipts_and_logs \
#   --provider-uri https://rpc.ankr.com/eth \
#   --transaction-hashes transaction_hashes.txt \
#   --receipts-output receipts.csv \
#   --logs-output logs.csv

# # extract_token_transfers
# python3 ethereumetl.py extract_token_transfers \
#   --logs logs.csv \
#   --output token_transfers.csv

# # export_contracts
# python3 ethereumetl.py extract_csv_column \
#   --input receipts.csv \
#   --column contract_address \
#   --output contract_addresses.txt

# python3 ethereumetl.py export_contracts \
#   --provider-uri https://rpc.ankr.com/eth \
#   --contract-addresses contract_addresses.txt \
#   --output contracts.csv

# # export_tokens
# python3 ethereumetl.py filter_items -i contracts.csv -p "item['is_erc20'] or item['is_erc721']" | \
# python3 ethereumetl.py extract_field -f address -o token_addresses.txt

# python3 ethereumetl.py export_tokens \
#   --provider-uri https://rpc.ankr.com/eth \
#   --token-addresses token_addresses.txt \
#   --output tokens.csv

# export_traces (internal transactions)
# python3 ethereumetl.py export_traces \
#   --provider-uri https://rpc.ankr.com/eth \
#   --start-block 15923348 \
#   --end-block 15924348 \
#   --batch-size 100 \
#   --output traces.csv

# export_geth_traces
