// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

struct PatientDetails {
    bool isRegistered;
    bool IDvalid;
    string nationality;
    uint256 age;
}

interface IPatients {
    function registeredPatients(address _walletAddress) external view returns (PatientDetails memory);
}

contract DoctorDetails is Ownable{

    struct docDetails {
        string name;
        string speciality;
        bool isRegistered; 
        uint256 slashes;
        bool isLegit;   
        uint256 reputation;
        string nationality;
        string certificateBlob;
    }

    IPatients public patientsContract;

    constructor(address _patientContractAddress) Ownable(msg.sender) {
        patientsContract = IPatients(_patientContractAddress);
    }

    modifier onlyRegisteredPatient() {
        // Step 1: Look up the caller (msg.sender) in the Patients contract.
        PatientDetails memory patient = patientsContract.registeredPatients(msg.sender);
        
        // Step 2: Check if the 'isRegistered' flag is true.
        // If it's false, stop the function and show an error.
        require(patient.isRegistered, "Caller is not a registered patient.");
        
        // If the check passes, the underscore tells Solidity to run the rest of the function.
        _;
    }

    mapping (address => docDetails) public doctorDetails;
    mapping (address => string) public doctorReviews;

    event DoctorAdded(address indexed doctor);
    event DoctorRemoved(address indexed doctor);
    event ReputationUpdated(address indexed doctor, uint256 newReputation);
    event DoctorSlashed(address indexed doctor, uint256 newSlashCount);
    event LegitimacyChanged(address indexed doctor, bool isLegit);

    /**
     * @notice Adds a new doctor to the system.
     * @param _doctor The address of the doctor to add.
     * @param _nationality The doctor's nationality.
     * @param _certificateBlob The blob ID for the doctor's certificates.
     */
    function addDoctor(string memory _name,string memory _speciality, address _doctor, string memory _nationality, string memory _certificateBlob) public onlyOwner {
        require(!doctorDetails[_doctor].isRegistered, "Doctor already exists.");

        doctorDetails[_doctor] = docDetails({
            name : _name,
            speciality : _speciality,
            isRegistered: true,
            slashes: 0,
            isLegit: true,
            reputation: 0,
            nationality: _nationality,
            certificateBlob: _certificateBlob
        });
        emit DoctorAdded(_doctor);
    }

    /**
     * @notice Removes a doctor from the system entirely.
     * @param _doctor The address of the doctor to remove.
     */
    function removeDoctor(address _doctor) public onlyOwner {
        require(doctorDetails[_doctor].isRegistered, "Doctor not found.");
        delete doctorDetails[_doctor];
        delete doctorReviews[_doctor];
        emit DoctorRemoved(_doctor);
    }

    /**
     * @notice Adds a specified amount to a doctor's reputation score.
     * @param _doctor The address of the doctor.
     * @param _amount The amount of reputation to add.
     */
    function addReputation(address _doctor, uint256 _amount) public onlyOwner {
        require(doctorDetails[_doctor].isRegistered, "Doctor not found.");
        docDetails storage d = doctorDetails[_doctor];
        d.reputation += _amount;
        emit ReputationUpdated(_doctor, d.reputation);
    }

    /**
     * @notice Subtracts a specified amount from a doctor's reputation score.
     * @param _doctor The address of the doctor.
     * @param _amount The amount of reputation to subtract.
     */
    function subtractReputation(address _doctor, uint256 _amount) public onlyOwner {
        require(doctorDetails[_doctor].isRegistered, "Doctor not found.");
        docDetails storage d = doctorDetails[_doctor];
        require(d.reputation >= _amount, "Cannot subtract more than current reputation.");
        d.reputation -= _amount;
        emit ReputationUpdated(_doctor, d.reputation);
    }

    /**
     * @notice Records a slash against a doctor and checks if they should be de-listed.
     * @param _doctor The address of the doctor to slash.
     */
    function increaseSlash(address _doctor) public onlyOwner {
        require(doctorDetails[_doctor].isRegistered, "Doctor not found.");
        docDetails storage d = doctorDetails[_doctor];
        require(d.isLegit, "Doctor is already not legitimate.");
        
        d.slashes++;
        emit DoctorSlashed(_doctor, d.slashes);

        if (d.slashes >= 3) {
            d.isLegit = false;
            emit LegitimacyChanged(_doctor, false);
        }
    }

    /**
     * @notice Adds or updates the blob ID for a doctor's certificate.
     * @param _doctor The address of the doctor.
     * @param _blobId The new blob ID for their certificate.
     */
    function updateCertificateBlob(address _doctor, string memory _blobId) public {
        require(doctorDetails[_doctor].isRegistered, "Doctor not found.");
        doctorDetails[_doctor].certificateBlob = _blobId;
    }

    /**
     * @notice Adds or updates the blob ID for a doctor's public reviews.
     * @param _doctor The address of the doctor.
     * @param _blobId The new blob ID for their reviews.
     */
    function updateReviewsBlob(address _doctor, string memory _blobId) public onlyRegisteredPatient {
        require(doctorDetails[_doctor].isRegistered, "Doctor not found.");
        doctorReviews[_doctor] = _blobId;
    }

    function fetchUserReviews (address _doctor) public view onlyRegisteredPatient returns (string memory) {
        return doctorReviews[_doctor];
    }
}