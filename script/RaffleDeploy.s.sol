// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Raffle} from "../src/Raffle.sol";
import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract RaffleDeploy is Script {
    function deployRaffle() public returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory netWorkConfig = helperConfig
            .getConfigByChainId(block.chainid);

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

        return (raffle, helperConfig);
    }

    function run() external {
        deployRaffle();
    }
}
