-include .env

.PHONY: all test clean deploy deploy-sepolia deploy-local deploy-zk deploy-zk-sepolia \
        fund fund-local fund-sepolia withdraw withdraw-local withdraw-sepolia \
        help install snapshot format anvil zk-anvil

# ==================== 默认配置 ====================
DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
DEFAULT_ZKSYNC_LOCAL_KEY := 0x7726827caac94a7f9e1b160f7ea819f172f7b6f9d2a97f992c38edeab82d4110

# ==================== 环境检查函数 ====================
define check-env
	@if [ -z "$($(1))" ]; then \
		echo "❌ 错误: $(1) 未设置"; \
		echo "请在 .env 文件中设置: $(1)=值"; \
		exit 1; \
	fi
endef

check-rpc-url:
	$(call check-env,$(NETWORK)_RPC_URL)

check-private-key:
	$(call check-env,SEPOLIA_PRIVATE_KEY)

check-sepolia-env:
	$(call check-env,SEPOLIA_RPC_URL)
	$(call check-env,SEPOLIA_PRIVATE_KEY)

check-zksync-env:
	$(call check-env,ZKSYNC_SEPOLIA_RPC_URL)

# ==================== 基础命令 ====================
all: clean install update build

clean:
	@echo "🧹 清理构建文件..."
	forge clean

install:
	@echo "📦 安装依赖..."
	forge install cyfrin/foundry-devops@0.2.2
	forge install smartcontractkit/chainlink-brownie-contracts@1.1.1
	forge install foundry-rs/forge-std@v1.8.2
	# 如果需要 zkSync 依赖
	# forge install matter-labs/era-contracts

update:
	@echo "🔄 更新依赖..."
	forge update

build:
	@echo "🔨 编译合约..."
	forge build

zkbuild:
	@echo "🔨 编译合约 (zkSync)..."
	forge build --zksync

test:
	@echo "🧪 运行测试..."
	forge test

zktest:
	@echo "🧪 运行 zkSync 测试..."
	foundryup-zksync
	forge test --zksync
	foundryup

snapshot:
	@echo "📊 创建 gas 快照..."
	forge snapshot

format:
	@echo "💅 格式化代码..."
	forge fmt

# ==================== 节点启动 ====================
anvil:
	@echo "🏗️ 启动本地 Anvil 节点..."
	anvil -m 'test test test test test test test test test test test junk' \
		--steps-tracing \
		--block-time 1

zk-anvil:
	@echo "🏗️ 启动 zkSync 本地节点..."
	npx zksync-cli dev start

# ==================== 以太坊部署 ====================
# 本地部署
deploy-fundMe-local:
	@echo "🚀 部署到本地网络..."
	@echo "提示: 确保已运行 'make anvil'"
	forge script script/FundMeDeploy.s.sol:deployFundMe \
		--rpc-url http://localhost:8545 \
		--private-key $(DEFAULT_ANVIL_KEY) \
		--broadcast

deploy-raffle-local:
	@echo "🚀 部署到本地网络..."
	@echo "提示: 确保已运行 'make anvil'"
	forge script script/RaffleDeploy.s.sol:deployRaffle \
		--rpc-url http://localhost:8545 \
		--private-key $(DEFAULT_ANVIL_KEY) \
		--broadcast

deploy-xxcToken-local:
	@echo "🚀 部署到本地网络..."
	@echo "提示: 确保已运行 'make anvil'"
	forge script script/XxcTokenDeploy.s.sol \
		--rpc-url http://localhost:8545 \
		--private-key $(DEFAULT_ANVIL_KEY) \
		--broadcast			

# Sepolia 部署
deploy-fundMe-sepolia: check-sepolia-env
	@echo "🚀 部署到 Sepolia 测试网..."
	@if [ -z "$(ETHERSCAN_API_KEY)" ]; then \
		echo "⚠️  跳过合约验证 (ETHERSCAN_API_KEY 未设置)"; \
		forge script script/FundMeDeploy.s.sol \
			--rpc-url $(SEPOLIA_RPC_URL) \
			--private-key $(SEPOLIA_PRIVATE_KEY) \
			--broadcast \
			-vvvv; \
	else \
		echo "✅ 启用合约验证"; \
		forge script script/FundMeDeploy.s.sol \
			--rpc-url $(SEPOLIA_RPC_URL) \
			--private-key $(SEPOLIA_PRIVATE_KEY) \
			--broadcast \
			--verify \
			--etherscan-api-key $(ETHERSCAN_API_KEY) \
			-vvvv; \
	fi

deploy-raffle-sepolia: check-sepolia-env
	@echo "🚀 部署到 Sepolia 测试网..."
	@if [ -z "$(ETHERSCAN_API_KEY)" ]; then \
		echo "⚠️  跳过合约验证 (ETHERSCAN_API_KEY 未设置)"; \
		forge script script/RaffleDeploy.s.sol \
			--rpc-url $(SEPOLIA_RPC_URL) \
			--private-key $(SEPOLIA_PRIVATE_KEY) \
			--broadcast \
			-vvvv; \
	else \
		echo "✅ 启用合约验证"; \
		forge script script/RaffleDeploy.s.sol \
			--rpc-url $(SEPOLIA_RPC_URL) \
			--private-key $(SEPOLIA_PRIVATE_KEY) \
			--broadcast \
			--verify \
			--etherscan-api-key $(ETHERSCAN_API_KEY) \
			-vvvv; \
	fi	

deploy-myFamilyNft-sepolia: check-sepolia-env
	@echo "🚀 部署到 Sepolia 测试网..."
	@if [ -z "$(ETHERSCAN_API_KEY)" ]; then \
		echo "⚠️  跳过合约验证 (ETHERSCAN_API_KEY 未设置)"; \
		forge script script/MyFamilyNftDeploy.s.sol \
			--rpc-url $(SEPOLIA_RPC_URL) \
			--private-key $(SEPOLIA_PRIVATE_KEY) \
			--broadcast \
			-vvvv; \
	else \
		echo "✅ 启用合约验证"; \
		forge script script/MyFamilyNftDeploy.s.sol \
			--rpc-url $(SEPOLIA_RPC_URL) \
			--private-key $(SEPOLIA_PRIVATE_KEY) \
			--broadcast \
			--verify \
			--etherscan-api-key $(ETHERSCAN_API_KEY) \
			-vvvv; \
	fi


# ==================== 交互脚本 ====================
# 获取发送者地址
get-sender-address:
	@if [ -z "$(SEPOLIA_PRIVATE_KEY)" ]; then \
		echo "使用默认 Anvil 地址..."; \
		cast wallet address --private-key $(DEFAULT_ANVIL_KEY); \
	else \
		echo "使用配置私钥地址..."; \
		cast wallet address --private-key $(SEPOLIA_PRIVATE_KEY); \
	fi

# 资助合约（本地）
fund-local:
	@echo "💰 资助本地合约..."
	$(eval SENDER_ADDRESS := $(shell cast wallet address --private-key $(DEFAULT_ANVIL_KEY)))
	@echo "发送者地址: $(SENDER_ADDRESS)"
	forge script script/Interactions.s.sol:FundFundMe \
		--sender $(SENDER_ADDRESS) \
		--rpc-url http://localhost:8545 \
		--private-key $(DEFAULT_ANVIL_KEY) \
		--broadcast

# 资助合约（Sepolia）
fund-sepolia: check-sepolia-env
	@echo "💰 资助 Sepolia 合约..."
	$(eval SENDER_ADDRESS := $(shell cast wallet address --private-key $(SEPOLIA_PRIVATE_KEY)))
	@echo "发送者地址: $(SENDER_ADDRESS)"
	forge script script/Interactions.s.sol:FundFundMe \
		--sender $(SENDER_ADDRESS) \
		--rpc-url $(SEPOLIA_RPC_URL) \
		--private-key $(SEPOLIA_PRIVATE_KEY) \
		--broadcast

# 资助合约（通用版）
fund:
	@if [ "$(NETWORK)" = "sepolia" ]; then \
		$(MAKE) fund-sepolia; \
	else \
		$(MAKE) fund-local; \
	fi

# 提款（本地）
withdraw-local:
	@echo "💸 从本地合约提款..."
	$(eval SENDER_ADDRESS := $(shell cast wallet address --private-key $(DEFAULT_ANVIL_KEY)))
	@echo "发送者地址: $(SENDER_ADDRESS)"
	forge script script/Interactions.s.sol:WithdrawFundMe \
		--sender $(SENDER_ADDRESS) \
		--rpc-url http://localhost:8545 \
		--private-key $(DEFAULT_ANVIL_KEY) \
		--broadcast

# 提款（Sepolia）
withdraw-sepolia: check-sepolia-env
	@echo "💸 从 Sepolia 合约提款..."
	$(eval SENDER_ADDRESS := $(shell cast wallet address --private-key $(SEPOLIA_PRIVATE_KEY)))
	@echo "发送者地址: $(SENDER_ADDRESS)"
	forge script script/Interactions.s.sol:WithdrawFundMe \
		--sender $(SENDER_ADDRESS) \
		--rpc-url $(SEPOLIA_RPC_URL) \
		--private-key $(SEPOLIA_PRIVATE_KEY) \
		--broadcast

# 提款（通用版）
withdraw:
	@if [ "$(NETWORK)" = "sepolia" ]; then \
		$(MAKE) withdraw-sepolia; \
	else \
		$(MAKE) withdraw-local; \
	fi

enterRaffle-sepolia: check-sepolia-env
	@echo "🧪 Running staging tests on Sepolia..."
	forge script script/Interactions.s.sol:EnterRaffle \
    --rpc-url $(SEPOLIA_RPC_URL) \
	--private-key $(SEPOLIA_PRIVATE_KEY) \
    --sender $(SENDER_ADDRESS) \
	--broadcast \
    -vvvv

mintMyFamilyNft-sepolia: check-sepolia-env
	@echo "🧪 Running staging tests on Sepolia..."
	forge script script/Interactions.s.sol:MintMyFamilyNft \
    --rpc-url $(SEPOLIA_RPC_URL) \
	--private-key $(SEPOLIA_PRIVATE_KEY) \
    --sender $(SENDER_ADDRESS) \
	--broadcast \
    -vvvv

uploadImageToPinata-sepolia: check-sepolia-env
	@echo "🧪 Running staging tests on Sepolia..."
	forge script script/Interactions.s.sol:MeatDataUploadDeploy \
    -vvvv		

# ==================== 合约地址管理 ====================
# 获取最近部署的合约地址
get-fundme-address:
	@if [ "$(NETWORK)" = "sepolia" ]; then \
		cast call --rpc-url $(SEPOLIA_RPC_URL) "0x最近部署的地址" "i_owner()(address)" 2>/dev/null || echo "请先部署合约"; \
	else \
		cast call --rpc-url http://localhost:8545 "0x最近部署的地址" "i_owner()(address)" 2>/dev/null || echo "请先部署合约"; \
	fi

# 检查合约余额
check-balance:
	@if [ "$(NETWORK)" = "sepolia" ]; then \
		cast balance --rpc-url $(SEPOLIA_RPC_URL) $(CONTRACT_ADDRESS); \
	else \
		cast balance --rpc-url http://localhost:8545 $(CONTRACT_ADDRESS); \
	fi

# ==================== 帮助信息 ====================
help:
	@echo ""
	@echo "🏗️  节点管理:"
	@echo "  make anvil              - 启动本地 Anvil 节点"
	@echo "  make zk-anvil           - 启动 zkSync 本地节点"
	@echo ""
	@echo "🚀 部署命令 (Ethereum):"
	@echo "  make deploy-fundMe-local       - 部署到本地网络"
	@echo "  make deploy-fundMe-sepolia     - 部署到 Sepolia 测试网"
	@echo ""
	@echo "💰 交互命令:"
	@echo "  make fund-local         - 资助本地合约"
	@echo "  make fund-sepolia       - 资助 Sepolia 合约"
	@echo "  make withdraw-local     - 从本地合约提款"
	@echo "  make withdraw-sepolia   - 从 Sepolia 合约提款"
	@echo "  make fund NETWORK=xxx   - 通用资助"
	@echo "  make withdraw NETWORK=xxx - 通用提款"
	@echo ""
	@echo "🔧 开发命令:"
	@echo "  make build              - 编译合约"
	@echo "  make zkbuild            - 编译合约 (zkSync)"
	@echo "  make test               - 运行测试"
	@echo "  make zktest             - 运行 zkSync 测试"
	@echo "  make clean              - 清理构建文件"
	@echo "  make format             - 格式化代码"
	@echo "  make get-sender-address - 获取发送者地址"
	@echo ""


