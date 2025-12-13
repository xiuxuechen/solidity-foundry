// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {XxcToken} from "../src/XxcToken.sol";

contract XxcTokenDeploy is Script {
    function deployXxcToken(uint256 initialSupply) public returns (XxcToken) {
        return new XxcToken(initialSupply);
    }

    function run() external returns (XxcToken) {
        uint256 initialSupply = 1000 ether;
        vm.startBroadcast();
        XxcToken xxcToken = deployXxcToken(initialSupply);
        vm.stopBroadcast();
        return xxcToken;
    }
}
