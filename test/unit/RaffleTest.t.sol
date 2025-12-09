// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {RaffleDeploy} from "../../script/RaffleDeploy.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {HelperConfig, CodeConstants} from "../../script/HelperConfig.s.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {VRFCoordinatorV2_5Mock} from "../mock/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "../mock/LinkToken.sol";

contract RaffleTest is Test, CodeConstants {
    Raffle public raffle;
    HelperConfig public helperConfig;
    address[] public players;

    uint256 subscriptionId;
    bytes32 gasLane;
    uint256 interval;
    uint256 entranceFee;
    uint32 callbackGasLimit;
    address vrfCoordinator;
    LinkToken link;

    uint256 public constant LINK_BALANCE = 100 ether;

    function setUp() public {
        for (uint256 i = 1; i <= 5; i++) {
            address player = makeAddr(string.concat("player", vm.toString(i)));
            vm.deal(player, 10 ether);
            players.push(player);
        }
        RaffleDeploy deployer = new RaffleDeploy();
        (raffle, helperConfig) = deployer.deployRaffle();

        HelperConfig.NetworkConfig memory config = helperConfig
            .getConfigByChainId(block.chainid);
        subscriptionId = config.subscriptionId;
        gasLane = config.gasLane;
        interval = config.interval;
        entranceFee = config.entranceFee;
        callbackGasLimit = config.callbackGasLimit;
        vrfCoordinator = config.vrfCoordinator;
        link = LinkToken(config.link);

        vm.startPrank(msg.sender);
        if (block.chainid == LOCAL_CHAIN_ID) {
            link.mint(msg.sender, LINK_BALANCE);
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(
                subscriptionId,
                LINK_BALANCE
            );
        }
        link.approve(vrfCoordinator, LINK_BALANCE);
        vm.stopPrank();
    }

    function testRaffleInitializesInOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function testRaffleRevertsWhenYouDontPayEnough() public {
        vm.prank(address(1));
        vm.expectRevert(
            abi.encodeWithSignature(
                "Raffle__NotEnoughEntranceFee(string)",
                unicode"亲，您的入场费不够哦！"
            )
        );
        raffle.enterRaffle();
    }
}
