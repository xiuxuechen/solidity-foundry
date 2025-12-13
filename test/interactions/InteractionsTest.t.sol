// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {FundMeDeploy} from "../../script/FundMeDeploy.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {
    FundFundMe,
    WithdrawFundMe
} from "../../script/interactions/FundMeInteraction.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;
    HelperConfig helperConfig;
    address USER = makeAddr("xsx");
    uint256 constant SEND_VALUE = 0.1 ether;

    function setUp() public {
        FundMeDeploy deployer = new FundMeDeploy();
        (fundMe, helperConfig) = deployer.deployFundMe();
        vm.deal(USER, SEND_VALUE);
    }

    function testInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));
    }
}
