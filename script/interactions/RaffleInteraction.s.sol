// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {Raffle} from "../../src/Raffle.sol";
import {
    VRFCoordinatorV2_5Mock
} from "../../test/mock/VRFCoordinatorV2_5Mock.sol";
import {HelperConfig, CodeConstants} from "../../script/HelperConfig.s.sol";
import {LinkToken} from "../../test/mock/LinkToken.sol";

contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns (uint256, address) {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinatorV2_5 = helperConfig
            .getConfigByChainId(block.chainid)
            .vrfCoordinator;
        address account = helperConfig
            .getConfigByChainId(block.chainid)
            .account;
        return createSubscription(vrfCoordinatorV2_5, account);
    }

    function createSubscription(
        address vrfCoordinatorV2_5,
        address account
    ) public returns (uint256, address) {
        console.log(unicode"正在创建订阅ID: ", block.chainid);
        vm.startBroadcast(account);
        uint256 subId = VRFCoordinatorV2_5Mock(vrfCoordinatorV2_5)
            .createSubscription();
        vm.stopBroadcast();
        console.log(unicode"订阅ID创建成功: ", subId);
        return (subId, vrfCoordinatorV2_5);
    }

    function run() external returns (uint256, address) {
        return createSubscriptionUsingConfig();
    }
}

contract AddConsumer is Script {
    function addConsumer(
        uint256 subId,
        address vrfCoordinatorV2_5,
        address consumer
    ) public {
        console.log(unicode"正在添加消费者: ", consumer);
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock(vrfCoordinatorV2_5).addConsumer(subId, consumer);
        vm.stopBroadcast();
        console.log(unicode"消费者添加成功: ", consumer);
    }

    function run() external {
        address raffleAddress = DevOpsTools.get_most_recent_deployment(
            "Raffle",
            block.chainid
        );

        HelperConfig.NetworkConfig memory config = new HelperConfig()
            .getConfigByChainId(block.chainid);

        addConsumer(
            config.subscriptionId,
            config.vrfCoordinator,
            raffleAddress
        );
    }
}

contract FundSubscription is Script, CodeConstants {
    uint96 public constant FUND_AMOUNT = 3 ether;

    function fundSubscriptionUsingConfig() public {
        HelperConfig.NetworkConfig memory config = new HelperConfig()
            .getConfigByChainId(block.chainid);
        uint256 subId = config.subscriptionId;
        address vrfCoordinatorV2_5 = config.vrfCoordinator;
        address link = config.link;
        address account = config.account;

        if (subId == 0) {
            CreateSubscription createSub = new CreateSubscription();
            (uint256 updatedSubId, address updatedVRFv2) = createSub.run();
            subId = updatedSubId;
            vrfCoordinatorV2_5 = updatedVRFv2;
            console.log(
                "New SubId Created! ",
                subId,
                "VRF Address: ",
                vrfCoordinatorV2_5
            );
        }

        fundSubscription(vrfCoordinatorV2_5, subId, link, account);
    }

    function fundSubscription(
        address vrfCoordinatorV2_5,
        uint256 subId,
        address link,
        address account
    ) public {
        if (block.chainid == LOCAL_CHAIN_ID) {
            vm.startBroadcast(account);
            VRFCoordinatorV2_5Mock(vrfCoordinatorV2_5).fundSubscription(
                subId,
                FUND_AMOUNT
            );
            vm.stopBroadcast();
        } else {
            console.log(LinkToken(link).balanceOf(msg.sender));
            console.log(msg.sender);
            console.log(LinkToken(link).balanceOf(address(this)));
            console.log(address(this));
            vm.startBroadcast(account);
            LinkToken(link).transferAndCall(
                vrfCoordinatorV2_5,
                FUND_AMOUNT,
                abi.encode(subId)
            );
            vm.stopBroadcast();
        }
    }

    function run() external {
        fundSubscriptionUsingConfig();
    }
}

contract EnterRaffle is Script, CodeConstants {
    function enterRaffle() public {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig
            .getConfigByChainId(block.chainid);
        address raffle = DevOpsTools.get_most_recent_deployment(
            "Raffle",
            block.chainid
        );
        vm.startBroadcast();
        Raffle(payable(raffle)).enterRaffle{value: config.entranceFee}();
    }

    function run() external {
        enterRaffle();
    }
}
