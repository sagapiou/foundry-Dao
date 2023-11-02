// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        uint256 deployerKey;
        address proposer1;
        address proposer2;
        address executor1;
        address executor2;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public view returns (NetworkConfig memory sepoliaNetworkConfig) {
        sepoliaNetworkConfig = NetworkConfig({
            deployerKey: vm.envUint("PRIVATE_KEY_SEPOLIA"),
            proposer1: address(uint160(vm.envUint("ADDRESS_1_SEPOLIA"))),
            proposer2: address(uint160(vm.envUint("ADDRESS_2_SEPOLIA"))),
            executor1: address(uint160(vm.envUint("ADDRESS_1_SEPOLIA"))),
            executor2: address(uint160(vm.envUint("ADDRESS_2_SEPOLIA")))
        });
    }

    function getOrCreateAnvilEthConfig() public view returns (NetworkConfig memory anvilNetworkConfig) {
        // Check to see if we set an active network config
        if (activeNetworkConfig.deployerKey != 0) {
            return activeNetworkConfig;
        }
        anvilNetworkConfig = NetworkConfig({
            deployerKey: vm.envUint("PRIVATE_KEY_LOCAL"),
            proposer1: address(uint160(vm.envUint("ADDRESS_1_ANVIL"))),
            proposer2: address(uint160(vm.envUint("ADDRESS_2_ANVIL"))),
            executor1: address(uint160(vm.envUint("ADDRESS_1_SEPOLIA"))),
            executor2: address(uint160(vm.envUint("ADDRESS_2_SEPOLIA")))
        });
    }
}