// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Box} from "../../src/Box.sol";
import {DeployBox} from "../../script/DeployBox.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

contract BoxTest is StdCheats, Test {
    Box box;
    DeployBox deployer;
    address public saga = makeAddr("saga");
    uint256 testNumber = 100;

    function setUp() public {
        deployer = new DeployBox();
        box = deployer.run();
    }

    function testWrongOwner() public {
        vm.prank(saga);
        vm.expectRevert();
        box.store(testNumber);
    }

    function testCorrectOwner() public {
        address actualOwner = box.owner();
        vm.prank(actualOwner);
        box.store(testNumber);
        assertEq(box.getNumber(), testNumber);
    }

}