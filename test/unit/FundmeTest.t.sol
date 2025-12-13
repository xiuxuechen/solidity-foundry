// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {FundMeDeploy} from "../../script/FundMeDeploy.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    HelperConfig helperConfig;
    address USER = makeAddr("xsx");
    uint256 constant SEND_VALUE = 0.1 ether;

    modifier funded() {
        vm.startPrank(USER);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();
        _;
    }

    /**
     * @dev 测试众筹合约部署
     */
    function setUp() public {
        FundMeDeploy deployer = new FundMeDeploy();
        (fundMe, helperConfig) = deployer.deployFundMe();
        vm.deal(USER, SEND_VALUE);
    }

    /**
     * @dev 测试众筹合约拥有者
     */
    function testFundOwner() public {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    /**
     * @dev 测试众筹金额不足是否回滚
     */
    function testNotEnoughMoney() public {
        vm.expectRevert();
        fundMe.fund();
    }

    /**
     * @dev 测试众筹正确是否记录
     */
    function testFundRecord() public funded {
        assertEq(fundMe.addressToAmountFunded(USER), SEND_VALUE);
        assertEq(fundMe.s_funders(0), USER);
    }

    /**
     * @dev 测试正常众筹
     */
    function testFund() public {
        vm.startPrank(USER);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();
    }

    /**
     * @dev 测试非提现错误
     */
    function testWithdrawByNotOwner() public funded {
        vm.expectRevert();
        vm.prank(address(3));
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() public funded {
        uint256 startingOwnerBalance = fundMe.i_owner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.i_owner());
        fundMe.withdraw();

        assertEq(address(fundMe).balance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            fundMe.i_owner().balance
        );
    }

    function testWithdrawWithMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.i_owner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.i_owner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.i_owner().balance
        );
    }
}
