// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {Box} from "../src/Box.sol";
import {GovToken} from "../src/GovToken.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {TimeLock} from "../src/TimeLock.sol";
import {console} from "forge-std/Test.sol";

contract DeployDao is Script {
        uint256 private constant MIN_DELAY = 300; // 5 minutes - after a vote passes, you have 5 minutes before you can enact
        uint256 public constant TOTAL_TOKENS = 1000000e18;

       
        GovToken private token;
        TimeLock private timelock;
        MyGovernor private governor;
        address[]  proposersArr = new address[](2);
        address[]  executorsArr = new address[](2);

    function run() external returns (Box, GovToken, MyGovernor, TimeLock) {
        
         HelperConfig helperConfig = new HelperConfig();

        (uint256 deployer, address proposer1, address proposer2, address executor1, address executor2) = helperConfig.activeNetworkConfig();
        
        proposersArr[0] = proposer1;
        proposersArr[1] = proposer2;
        executorsArr[0] = executor1;
        executorsArr[1] = executor2;
                
        vm.startBroadcast(deployer);
        address deployerAddress = proposer1;
        Box box = new Box(deployerAddress);
        token = new GovToken(deployerAddress);
        token.mint(deployerAddress, TOTAL_TOKENS);

        timelock = new TimeLock(MIN_DELAY, proposersArr, executorsArr);
        governor = new MyGovernor(token, timelock);



        vm.stopBroadcast();
        return (box, token, governor, timelock);
    }
    
}

