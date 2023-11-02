// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {MyGovernor} from "../../src/MyGovernor.sol";
import {GovToken} from "../../src/GovToken.sol";
import {TimeLock} from "../../src/TimeLock.sol";
import {Box} from "../../src/Box.sol";
import {DeployDao} from "../../script/DeployDao.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract MyGovernorTest is Test {
    GovToken token;
    TimeLock timelock;
    MyGovernor governor;
    Box box;
    DeployDao deployer; 

    uint256 public constant MIN_DELAY = 300; // 5 minutes - after a vote passes, you have 5 minutes before you can enact
    uint256 public constant QUORUM_PERCENTAGE = 4; // Need 4% of voters to pass
    uint256 public constant VOTING_PERIOD = 50400; // This is how long voting lasts
    uint256 public constant VOTING_DELAY = 1; // How many blocks till a proposal vote becomes active
    uint256 public constant FUND_AMOUNT_ETHER = 100 ether;

    address[] proposers;
    address[] executors;

    bytes[] functionCalls;
    address[] addressesToCall;
    uint256[] values;
    HelperConfig helperConfig = new HelperConfig();


    address public constant VOTER = address(1);
    address public saga = makeAddr("saga");
    address public owner;
    address public proposer;

    function setUp() public {
        (,owner, proposer, , ) = helperConfig.activeNetworkConfig();

        
        deployer = new DeployDao();
        (box, token, governor, timelock) = deployer.run();


        vm.startPrank(owner);
        token.delegate(owner);
        
        bytes32 proposerRole = timelock.PROPOSER_ROLE();
        bytes32 executorRole = timelock.EXECUTOR_ROLE();
        bytes32 adminRole = timelock.CANCELLER_ROLE();

        timelock.grantRole(proposerRole, address(governor));
        timelock.grantRole(executorRole, address(0));
        timelock.revokeRole(adminRole, owner);

        box.transferOwnership(address(timelock));
        vm.stopPrank();
    }

    function testCantUpdateBoxWithoutGovernance() public {
        vm.expectRevert();
        box.store(1);
    }

    function testGovernanceUpdatesBox() public {
         vm.warp(block.timestamp  + 1);
        vm.roll(block.number  + 1);
        uint256 valueToStore = 777;
        string memory description = "Store 1 in Box";
        bytes memory encodedFunctionCall = abi.encodeWithSignature("store(uint256)", valueToStore);
        addressesToCall.push(address(box));
        values.push(0);
        functionCalls.push(encodedFunctionCall);
        // 1. Propose to the DAO
        vm.prank(owner);
        uint256 proposalId = governor.propose(addressesToCall, values, functionCalls, description);

        console.log("Propose - Proposal State:", uint256(governor.state(proposalId)));
        // governor.proposalSnapshot(proposalId)
        // governor.proposalDeadline(proposalId)

        vm.warp(block.timestamp + VOTING_DELAY + 1);
        vm.roll(block.number + VOTING_DELAY + 1);

        console.log("Propose +7200 - Proposal State:", uint256(governor.state(proposalId)));
        // 2. Vote
        string memory reason = "I like a do da cha cha";
        // 0 = Against, 1 = For, 2 = Abstain for this example
        uint8 voteWay = 1;
        vm.prank(owner);
        governor.castVoteWithReason(proposalId, voteWay, reason);

        vm.warp(block.timestamp + VOTING_PERIOD + 1);
        vm.roll(block.number + VOTING_PERIOD + 1);
        console.log("Vote - Proposal State:", uint256(governor.state(proposalId)));

        // 3. Queue
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        vm.prank(owner);
        governor.queue(addressesToCall, values, functionCalls, descriptionHash);
        vm.roll(block.number + MIN_DELAY + 1);
        vm.warp(block.timestamp + MIN_DELAY + 1);
        console.log("Queue - Proposal State:", uint256(governor.state(proposalId)));

        // 4. Execute
        vm.prank(owner);
        governor.execute(addressesToCall, values, functionCalls, descriptionHash);
        console.log("Execute - Proposal State:", uint256(governor.state(proposalId)));

        assert(box.getNumber() == valueToStore);
    }
}