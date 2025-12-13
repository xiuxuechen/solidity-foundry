// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {MyFamilyNft} from "../../src/MyFamilyNft.sol";
import {MyFamilyNftDeploy} from "../../script/MyFamilyNftDeploy.s.sol";

contract MyFamilyNftTest is Test {
    MyFamilyNftDeploy public myFamilyNftDeploy;
    MyFamilyNft public myFamilyNft;
    address public USER = makeAddr("user");

    string public constant MY_CHILDREN_TOKEN_URI =
        "gold-definite-quelea-479.mypinata.cloud/ipfs/bafybeifv5w4dxvscqam3lqin5vn4r32wjdguqp2xtw4pmpyroh4j3gx244";

    function setUp() public {
        myFamilyNftDeploy = new MyFamilyNftDeploy();
        myFamilyNft = myFamilyNftDeploy.deployMyFamilyNft();
    }

    function testNftName() public view {
        string memory expected = "MyFamilyNft";
        string memory actual = myFamilyNft.name();
        assertEq(abi.encodePacked(expected), abi.encodePacked(actual));
    }

    function testNftSymbol() public view {
        string memory expected = "MyFamily";
        string memory actual = myFamilyNft.symbol();
        assertEq(abi.encodePacked(expected), abi.encodePacked(actual));
    }

    function testMintNft() public {
        vm.prank(USER);
        uint256 tokenId = myFamilyNft.mintNft(MY_CHILDREN_TOKEN_URI);
        assert(myFamilyNft.balanceOf(USER) == 1);
        assertEq(
            abi.encodePacked(myFamilyNft.tokenURI(tokenId)),
            abi.encodePacked(MY_CHILDREN_TOKEN_URI)
        );
    }
}
