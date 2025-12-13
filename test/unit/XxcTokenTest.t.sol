// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {XxcToken} from "../../src/XxcToken.sol";
import {XxcTokenDeploy} from "../../script/XxcTokenDeploy.s.sol";
import {
    IERC20Errors
} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

interface MintToken {
    function _mint(address to, uint256 amount) external;
}

contract XxcTokenTest is Test {
    XxcTokenDeploy deployer;
    XxcToken xxcToken;

    address player1 = makeAddr("stupid dog");
    address player2 = makeAddr("daughter");
    function setUp() public {
        deployer = new XxcTokenDeploy();
        xxcToken = deployer.run();

        vm.prank(msg.sender);
        xxcToken.transfer(player1, 100 ether);
    }

    function testPlayer1Balance() public {
        assertEq(xxcToken.balanceOf(player1), 100 ether);
    }

    function testTokenBalance() public {
        assertEq(xxcToken.balanceOf(msg.sender), 900 ether);
    }

    function testTransFromBalance() public {
        vm.prank(player1);
        xxcToken.approve(player2, 10 ether);

        vm.prank(player2);
        xxcToken.transferFrom(player1, player2, 10 ether);
        assertEq(xxcToken.balanceOf(player2), 10 ether);
        assertEq(xxcToken.balanceOf(player1), 90 ether);
    }

    function testTransFromMoreBalance() public {
        vm.prank(player1);
        xxcToken.approve(player2, 10 ether);

        vm.expectRevert(
            abi.encodeWithSignature(
                "ERC20InsufficientAllowance(address,uint256,uint256)",
                player2,
                10 ether,
                20 ether
            )
        );
        vm.prank(player2);
        xxcToken.transferFrom(player1, player2, 20 ether);
    }

    function testUserCanMint() public {
        vm.expectRevert();
        MintToken(address(xxcToken))._mint(player1, 10 ether);
    }
}
