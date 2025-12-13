// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Raffle} from "../src/Raffle.sol";
import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {
    AddConsumer,
    CreateSubscription,
    FundSubscription
} from "./interactions/RaffleInteraction.s.sol";

contract RaffleDeploy is Script {
    function deployRaffle() public returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory netWorkConfig = helperConfig
            .getConfigByChainId(block.chainid);

        if (block.chainid == 0) {
            CreateSubscription createSubscription = new CreateSubscription();
            createSubscription.createSubscription(
                netWorkConfig.vrfCoordinator,
                netWorkConfig.account
            );
            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(
                netWorkConfig.vrfCoordinator,
                netWorkConfig.subscriptionId,
                netWorkConfig.link,
                netWorkConfig.account
            );
        }

        vm.startBroadcast(netWorkConfig.account);
        Raffle raffle = new Raffle(
            netWorkConfig.vrfCoordinator,
            netWorkConfig.subscriptionId,
            netWorkConfig.gasLane,
            netWorkConfig.interval,
            netWorkConfig.entranceFee,
            netWorkConfig.callbackGasLimit
        );
        vm.stopBroadcast();
        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(
            netWorkConfig.subscriptionId,
            netWorkConfig.vrfCoordinator,
            address(raffle)
        );
        return (raffle, helperConfig);
    }

    function run() external returns (Raffle, HelperConfig) {
        return deployRaffle();
    }
}
