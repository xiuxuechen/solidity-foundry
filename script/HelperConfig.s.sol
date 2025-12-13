// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";
import {VRFCoordinatorV2_5Mock} from "../test/mock/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "../test/mock/LinkToken.sol";
import {Script, console} from "forge-std/Script.sol";

abstract contract CodeConstants {
    // FundMe constant
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    // Raffle constant
    address public constant FOUNDRY_DEFAULT_SENDER =
        0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
    int256 public constant MOCK_WEI_PER_UINT_LINK = 4e15;

    uint256 public constant ZK_SYNC_CHAIN_ID = 300;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
    uint256 public constant SEPOLIA_CHAIN_ID = 11155111;
}

contract HelperConfig is CodeConstants, Script {
    error HelperConfig__InvalidChainId();

    struct NetworkConfig {
        address priceFeed;
        address vrfCoordinator;
        uint256 subscriptionId;
        bytes32 gasLane;
        uint256 interval;
        uint256 entranceFee;
        uint32 callbackGasLimit;
        address link;
        address account;
    }

    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public networkConfigs;

    constructor() {
        networkConfigs[SEPOLIA_CHAIN_ID] = getSepoliaEthConfig();
        networkConfigs[ZK_SYNC_CHAIN_ID] = getZkSyncSepoliaConfig();
    }

    function getConfigByChainId(
        uint256 chainId
    ) public returns (NetworkConfig memory) {
        if (networkConfigs[chainId].priceFeed != address(0)) {
            return networkConfigs[chainId];
        } else if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilEthConfig();
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    function getSepoliaEthConfig() public view returns (NetworkConfig memory) {
        address priceFeed = vm.envAddress("ETH_USD_PRICE_FEED_ADDRESS");
        uint256 subscriptionId = vm.envUint("SUBSCRIPTION_ID");
        address vrfCoordinator = vm.envAddress("VRF_COORDINATOR_ADDRESS");
        bytes32 gasLane = vm.envBytes32("GAS_LANE");

        return
            NetworkConfig({
                priceFeed: priceFeed,
                subscriptionId: subscriptionId,
                gasLane: gasLane,
                interval: 30,
                entranceFee: 0.01 ether,
                callbackGasLimit: 500000,
                vrfCoordinator: vrfCoordinator,
                link: 0x514910771AF9Ca656af840dff83E8264EcF986CA,
                account: 0xB120289C8d2466aD7596007181284639Bd5535fa
            });
    }

    function getZkSyncSepoliaConfig()
        public
        view
        returns (NetworkConfig memory)
    {
        uint256 subscriptionId = vm.envUint("SUBSCRIPTION_ID");
        address vrfCoordinator = vm.envAddress("VRF_COORDINATOR_ADDRESS");
        bytes32 gasLane = vm.envBytes32("GAS_LANE");
        return
            NetworkConfig({
                priceFeed: 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF, // ETH / USD
                subscriptionId: subscriptionId,
                gasLane: gasLane,
                interval: 30,
                entranceFee: 0.01 ether,
                callbackGasLimit: 500000,
                vrfCoordinator: vrfCoordinator,
                link: 0x514910771AF9Ca656af840dff83E8264EcF986CA,
                account: 0xB120289C8d2466aD7596007181284639Bd5535fa
            });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // Check to see if we set an active network config
        if (localNetworkConfig.priceFeed != address(0)) {
            return localNetworkConfig;
        }

        console.log(unicode"⚠️检测到本地网络，正在创建模拟喂价合约...");
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        console.log(unicode"模拟喂价合约部署成功，开始部署模拟随机数合约...");
        VRFCoordinatorV2_5Mock mockVRFCoordinator = new VRFCoordinatorV2_5Mock(
            0.5 ether,
            1e9,
            0.25 ether
        );
        uint256 subscriptionId = mockVRFCoordinator.createSubscription();
        console.log(unicode"模拟随机数合约部署完成！");
        vm.stopBroadcast();

        LinkToken link = new LinkToken();

        localNetworkConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed),
            vrfCoordinator: address(mockVRFCoordinator),
            subscriptionId: subscriptionId,
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            interval: 30,
            entranceFee: 0.01 ether,
            callbackGasLimit: 5000000,
            link: address(link),
            account: FOUNDRY_DEFAULT_SENDER
        });
        vm.deal(localNetworkConfig.account, 100 ether);
        return localNetworkConfig;
    }
}
