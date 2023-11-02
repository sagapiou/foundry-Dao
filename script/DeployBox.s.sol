// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {Box} from "../src/Box.sol";

contract DeployBox is Script {
    
    function run() external returns (Box) {
        HelperConfig helperConfig = new HelperConfig();

        (uint256 deployerBox,,,,) = helperConfig.activeNetworkConfig();

        vm.startBroadcast(deployerBox);
        Box box = new Box(address(this));
        vm.stopBroadcast();
        return (box);
    }
    
}