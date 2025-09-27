// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {RandomNumber} from "../src/RandomNumber.sol";

/// @title RandomNumberScript
/// @notice A Foundry script to deploy the RandomNumber contract on Arbitrum Sepolia.
/// @dev Reads the deployer private key and entropy address from environment variables.
contract RandomNumberScript is Script {
    function run() external returns (address) {
        // Load the private key from .env
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Load entropy contract address (Pyth Entropy contract on Arbitrum Sepolia)
        address entropyAddress = vm.envAddress("ENTROPY_ADDRESS");

        // Start broadcasting with the deployer account
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the RandomNumber contract with entropy address
        RandomNumber randomNumber = new RandomNumber(entropyAddress);

        vm.stopBroadcast();

        // Log the deployed address
        console.log("RandomNumber contract deployed to:", address(randomNumber));

        return address(randomNumber);
    }
}
