// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {PatientDetailsContract} from "../src/PatientDetails.sol";

/// @title PatientDetailsContractScript
/// @notice A script to deploy the PatientDetailsContract.
/// @dev This script depends on two environment variables:
///      1. HEDERA_PRIVATE_KEY: The private key of the account that will deploy the contract.
///      2. PATIENTS_CONTRACT_ADDRESS: The address of the main Patients contract that this contract will link to.
contract PatientDetailsContractScript is Script {
    function run() external returns (address) {
        // Load the deployer's private key from the environment.
        uint256 deployerPrivateKey = vm.envUint("HEDERA_PRIVATE_KEY");

        // Load the address of the deployed Patients contract.
        address patientsContractAddress = vm.envAddress("PATIENTS_CONTRACT_ADDRESS");

        // Ensure that the Patients contract address is provided.
        require(patientsContractAddress != address(0), "PATIENTS_CONTRACT_ADDRESS must be set in your .env file.");

        // Begin broadcasting transactions signed by the deployer.
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the contract, passing the Patients contract address to the constructor.
        PatientDetailsContract patientDetails = new PatientDetailsContract(patientsContractAddress);

        // Stop broadcasting transactions.
        vm.stopBroadcast();

        // Log the results to the console for easy access.
        console.log("PatientDetailsContract deployed to:", address(patientDetails));
        console.log("Linked to Patients contract at:", patientsContractAddress);

        // Return the address of the newly deployed contract.
        return address(patientDetails);
    }
}