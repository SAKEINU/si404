.PHONY: run-script self-exemption-list set-base-uri set-erc721-transfer-exempt

# Check for the '--broadcast' argument and set the broadcast flag accordingly
ifeq (,$(findstring broadcast,$(MAKECMDGOALS)))
BROADCAST=""
else
BROADCAST="--broadcast"
endif

run-script:
	@echo "Running SI404.s.sol script..."
	@export PRIVATE_KEY=$${ETH_PRIVATE_KEY}; \
	forge script --rpc-url $${ETH_RPC_URL} --private-key $${PRIVATE_KEY} ./script/SI404.s.sol -vvvv $(BROADCAST) --sig "run(address,address)" -- $${OWNER_ADDRESS} $${INITIAL_MINTER}

self-exemption-list:
	@echo "Running selfExemptionList function..."
	@export PRIVATE_KEY=$${ETH_PRIVATE_KEY}; \
	forge script --rpc-url $${ETH_RPC_URL} --private-key $${PRIVATE_KEY} ./script/SI404.s.sol -vvvv $(BROADCAST) --sig "selfExemptionList(address)" -- $${SAKEINU_ADDRESS}

set-base-uri:
	@echo "Running setBaseURI function..."
	@export PRIVATE_KEY=$${ETH_PRIVATE_KEY}; \
	forge script --rpc-url $${ETH_RPC_URL} --private-key $${PRIVATE_KEY} ./script/SI404.s.sol -vvvv $(BROADCAST) --sig "setBaseURI(address,string)" -- $${SAKEINU_ADDRESS} $${BASE_URI}

set-erc721-transfer-exempt:
	@echo "Running setERC721TransferExempt function..."
	@export PRIVATE_KEY=$${ETH_PRIVATE_KEY}; \
	forge script --rpc-url $${ETH_RPC_URL} --private-key $${PRIVATE_KEY} ./script/SI404.s.sol -vvvv $(BROADCAST) --sig "setERC721TransferExempt(address,address,bool)" -- $${SAKEINU_ADDRESS} $${ACCOUNT} $${VALUE}
