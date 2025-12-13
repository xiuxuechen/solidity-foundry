// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {HelloWorld} from "../../src/HelloWorld.sol";

contract HelloWorldTest is Test {
    HelloWorld public helloWorld;

    function setUp() public {
        helloWorld = new HelloWorld(1, "Hello, Foundry!");
    }

    function testConstructor() public {
        assertEq(helloWorld.name(), "Hello, Foundry!");
        assertEq(helloWorld.count(), 1);
    }

    function testIncrCount() public {
        helloWorld.incrCount(10);
        assertEq(helloWorld.count(), 11);
    }
}
