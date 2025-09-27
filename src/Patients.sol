// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Import the standard Ownable contract from OpenZeppelin
import "@openzeppelin/contracts/access/Ownable.sol";

// Inherit from Ownable to get ownership features
contract Patients is Ownable {

    struct patientDetails {
        bool isRegistered; 
        bool IDvalid;
        string nationality;
        uint256 age;
    } 

    constructor() Ownable(msg.sender) {
    }
    
    mapping (address => patientDetails) public registeredPatients; 

    /**
     * @notice Adds a new patient to the system. Can only be called by the contract owner.
     * @param _patientAddress The wallet address of the patient being added.
     * @param _idvalid The validity status of the patient's ID.
     * @param _nationality The patient's nationality.
     * @param _age The patient's age.
     */
    function addPatient(address _patientAddress, bool _idvalid, string memory _nationality, uint256 _age) public onlyOwner {
        require(!registeredPatients[_patientAddress].isRegistered, "Patient already registered.");
        registeredPatients[_patientAddress] = patientDetails(true, _idvalid, _nationality, _age);
    }

    /**
     * @dev Checks if the calling address is a registered patient.
     * @return bool True if the patient exists, false otherwise.
     */
    function checkPatient() public view returns (bool){
        return registeredPatients[msg.sender].isRegistered;
    }

    /**
     * @notice Fetches the details of a specific patient.
     * @param _walletAddress The address of_patientID the patient to look up.
     * @return The patientDetails struct for the given address.
     */
    function fetchPatient(address _walletAddress) public view returns (patientDetails memory) {
        require(registeredPatients[_walletAddress].isRegistered, "Patient not found.");
        return registeredPatients[_walletAddress];
    } 

    /**
     * @notice Allows the service toggle patient ID validity status.
     */
    function toggleIDstatus() public onlyOwner {
        require(registeredPatients[msg.sender].isRegistered, "Patient not registered.");
        
        patientDetails storage patient = registeredPatients[msg.sender];
        patient.IDvalid = !patient.IDvalid;
    }
}