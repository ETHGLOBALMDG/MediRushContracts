// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

struct PatientDetails {
    bool isRegistered;
    bool IDvalid;
    string nationality;
    uint256 age;
}

interface IPatients {
    function registeredPatients(address _walletAddress) external view returns (PatientDetails memory);
}


contract PatientDetailsContract {

    IPatients public patientsContract;


    constructor(address _patientsContractAddress) {
        patientsContract = IPatients(_patientsContractAddress);
    }

    // This is the modifier that acts as a guard
    modifier onlyRegisteredPatient() {
        // Step 1: Look up the caller (msg.sender) in the Patients contract.
        PatientDetails memory patient = patientsContract.registeredPatients(msg.sender);
        
        // Step 2: Check if the 'isRegistered' flag is true.
        // If it's false, stop the function and show an error.
        require(patient.isRegistered, "Caller is not a registered patient.");
        
        // If the check passes, the underscore tells Solidity to run the rest of the function.
        _;
    }

    mapping (uint256 => string) public patientDetailsinBlob;

    event PatientAdded(uint256 indexed patientID, string blobID);
    event PatientIDUpdated(uint256 indexed oldID, uint256 indexed newID);
    event BlobIDUpdated(uint256 indexed patientID, string newBlobID);

    /**
     * @notice Adds a new patient record. Only for demonstration.
     * @param _patientID The unique ID for the patient.
     * @param _blobID The identifier for the patient's off-chain data.
     */
    function addPatient(uint256 _patientID, string memory _blobID) public onlyRegisteredPatient {
        require(bytes(patientDetailsinBlob[_patientID]).length == 0, "Patient ID already exists.");
        patientDetailsinBlob[_patientID] = _blobID;
        emit PatientAdded(_patientID, _blobID);
    }

    /**
     * @notice Updates the blob ID for an existing patient.
     * @param _patientID The ID of the patient to update.
     * @param _newBlobID The new blob ID to associate with the patient.
     */
    function updateBlobID(uint256 _patientID, string memory _newBlobID) public {
        require(bytes(patientDetailsinBlob[_patientID]).length > 0, "Patient ID not found.");
        patientDetailsinBlob[_patientID] = _newBlobID;
        emit BlobIDUpdated(_patientID, _newBlobID);
    }

    /**
     * @notice Updates a patient's ID, moving their record to a new ID.
     * @param _prevID The current ID of the patient.
     * @param _newID The new ID to assign to the patient.
     */
    function updateID(uint256 _prevID, uint256 _newID) public {
        require(bytes(patientDetailsinBlob[_prevID]).length > 0, "Previous Patient ID not found.");
        require(bytes(patientDetailsinBlob[_newID]).length == 0, "New Patient ID is already in use.");

        // Copy the blob ID to the new patient ID
        patientDetailsinBlob[_newID] = patientDetailsinBlob[_prevID];

        // Delete the old record
        delete patientDetailsinBlob[_prevID];
        
        emit PatientIDUpdated(_prevID, _newID);
    }
    
    /**
     * @notice Fetches the blob ID for a given patient ID.
     * @param _patientID The ID of the patient to look up.
     * @return The blob ID string associated with the patient.
     */
    function fetchBlobID(uint256 _patientID) public view returns (string memory) {
        require(bytes(patientDetailsinBlob[_patientID]).length > 0, "Patient ID not found.");
        return patientDetailsinBlob[_patientID];
    }
}