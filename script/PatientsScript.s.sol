// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Patients} from "../src/Patients.sol";

/// @title PatientsScript
/// @notice A script to deploy the Patients contract.   
/// @dev This script reads the deployer's private key from the HEDERA_PRIVATE_KEY
///      environment variable to deploy the contract. The deployer will be set
///      as the initial owner of the Patients contract.
contract PatientsScript is Script {
    function run() external returns (address) {
        // Load the private key from the .env file.
        // Make sure HEDERA_PRIVATE_KEY is set in your environment.
        uint256 deployerPrivateKey = vm.envUint("HEDERA_PRIVATE_KEY");

        // Start broadcasting transactions with the loaded private key.
        // The address corresponding to this key will become the contract owner.
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the Patients contract.
        // The Ownable constructor will automatically assign ownership to msg.sender,
        // which is the address of the deployerPrivateKey.
        Patients patients = new Patients();

        // Stop broadcasting.
        vm.stopBroadcast();

        // Log the address of the newly deployed contract.
        console.log("Patients contract deployed to:", address(patients));

        // Return the contract's address.
        return address(patients);
    }
}
