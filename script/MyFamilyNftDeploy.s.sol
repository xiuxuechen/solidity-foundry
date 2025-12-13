// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {MyFamilyNft} from "../src/MyFamilyNft.sol";

contract MyFamilyNftDeploy is Script {
    function deployMyFamilyNft() public returns (MyFamilyNft) {
        vm.startBroadcast();
        MyFamilyNft myFamilyNft = new MyFamilyNft();
        vm.stopBroadcast();
        return myFamilyNft;
    }
    function run() external {
        deployMyFamilyNft();
    }
}
