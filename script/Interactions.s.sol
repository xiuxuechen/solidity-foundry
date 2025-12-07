// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    function fundFundMe(address fundMeAddress) public {
        vm.startBroadcast();
        FundMe(payable(fundMeAddress)).fund{value: 0.1 ether}();
        console.log(unicode"众筹成功！");
        vm.stopBroadcast();
    }

    function run() external {
        address fundMeAddress = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        fundFundMe(fundMeAddress);
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address fundMeAddress) public {
        vm.startBroadcast();
        FundMe(payable(fundMeAddress)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address fundMeAddress = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        withdrawFundMe(fundMeAddress);
        console.log(unicode"提现成功！");
    }
}
