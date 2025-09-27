// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {DoctorDetails} from "../src/DoctorDetails.sol";

/// @title DoctorDetailsScript
/// @notice A script to deploy the DoctorDetails contract.
/// @dev This script requires two environment variables:
///      - HEDERA_PRIVATE_KEY: The private key of the deploying account.
///      - PATIENTS_CONTRACT_ADDRESS: The address of the already deployed Patients contract.
contract DoctorDetailsScript is Script {
    function run() external returns (address) {
        // 1. Load configuration from the .env file
        uint256 deployerPrivateKey = vm.envUint("HEDERA_PRIVATE_KEY");
        address patientsContractAddress = vm.envAddress("PATIENTS_CONTRACT_ADDRESS");

        // A quick check to ensure the Patients contract address was loaded correctly
        require(patientsContractAddress != address(0), "PATIENTS_CONTRACT_ADDRESS not set in .env file");

        // 2. Start broadcasting transactions with the loaded private key
        vm.startBroadcast(deployerPrivateKey);

        // 3. Deploy the DoctorDetails contract, passing the Patients contract address
        //    to its constructor. The deployer will become the owner.
        DoctorDetails doctorDetails = new DoctorDetails(patientsContractAddress);

        // 4. Stop broadcasting
        vm.stopBroadcast();

        // 5. Log the address of the newly deployed contract for verification
        console.log("DoctorDetails contract deployed to:", address(doctorDetails));
        console.log("It is linked to the Patients contract at:", patientsContractAddress);

        // 6. Return the contract's address
        return address(doctorDetails);
    }
}