// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {HelloWorld} from "../src/HelloWorld.sol";
import {console} from "forge-std/console.sol";

contract HelloWorldDeploy is Script {
    function run() external {
        // 获取部署者私钥
        uint256 deployerPrivateKey = vm.envUint("SEPOLIA_PRIVATE_KEY");

        // 开始广播交易
        vm.startBroadcast(deployerPrivateKey);

        console.log(unicode"部署合约中，请等待...");

        // 部署合约
        HelloWorld helloWorld = new HelloWorld(1, "Hello, Foundry!");

        vm.stopBroadcast();

        console.log(unicode"合约已部署到地址:", address(helloWorld));

        // 验证合约（需要安装 foundry-verify 插件）
        if (block.chainid == vm.envUint("SEPOLIA_CHAIN_ID")) {
            // Sepolia chainId
            console.log(unicode"等待区块确认...");
            // Foundry 默认会等待交易确认

            // 验证合约
            //verify(address(helloWorld), 1, "Hello, Foundry!");
        }
        console.log("----------------------------------------------------");
    }
}
