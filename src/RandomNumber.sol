// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { IEntropyConsumer } from "@pythnetwork/entropy-sdk-solidity/IEntropyConsumer.sol";
import { IEntropyV2 } from "@pythnetwork/entropy-sdk-solidity/IEntropyV2.sol";

contract RandomNumber is IEntropyConsumer {

    IEntropyV2 public entropy;

    // "Ticket" system: Links a request's sequence number to the user who made it.
    mapping(uint64 => address) public requestMap;

    // Event to announce the random number without storing it permanently.
    event RandomNumberRevealed(uint64 indexed sequenceNumber, uint256 randomNumber, address provider);
 
    constructor(address entropyAddress) {
        entropy = IEntropyV2(entropyAddress);           
    }

    /**
     * @notice Step 1: User calls this to request a random number.
     * Their app should listen for the sequenceNumber emitted by the entropy contract.
     */
    function requestRandomNumber() external payable {
        uint256 fee = entropy.getFeeV2();
        require(msg.value >= fee, "Not enough fee provided");

        uint64 sequenceNumber = entropy.requestV2{ value: fee }();

        // Still need to map the requester to verify the callback is legitimate
        requestMap[sequenceNumber] = msg.sender;
    }
 
    /**
     * @notice Step 2: The Pyth oracle calls this back.
     * The contract emits the random number for an off-chain listener and then forgets it.
     */
    function entropyCallback(
        uint64 sequenceNumber,
        address provider,
        bytes32 randomNumber
    ) internal override {
        // Use the sequence number to find the original requester
        address requester = requestMap[sequenceNumber];

        // Ensure this is a valid, pending request
        require(requester != address(0), "Invalid sequence number");
        
        uint256 myrandomNumber = uint256(randomNumber);

        // Announce the number via an event instead of storing it
        emit RandomNumberRevealed(sequenceNumber, myrandomNumber,provider);

        // Clean up the request map
        delete requestMap[sequenceNumber];
    }
 
    // This method is required by the IEntropyConsumer interface.
    function getEntropy() internal view override returns (address) {
        return address(entropy);
    }

    
}