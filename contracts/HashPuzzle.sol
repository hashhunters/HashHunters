pragma solidity ^0.4.18;
//pragma experimental ABIEncoderV2; 

import "./AbstractAlg.sol";

contract HashPuzzle {
    event HashCracked(
        address crackedBy, 
        uint256 bounty, 
        bytes message, 
        bytes32 keccak256OfHash, 
        bytes32 keccak256OfCalcHash
    );

    event AttemptFailed(
        address source, 
        bytes message, 
        bytes32 keccak256OfHash, 
        bytes32 keccak256OfCalcHash
    );

    address private contractOwner;

    bytes32 private keccak256OfHash; // keccak256 of hash we search for
    address private hashAlgAddress;
    uint8 private percentsFee;
    uint256 private fee;
    uint256 private bounty;

    function HashPuzzle(
        bytes32 _keccak256OfHash, 
        address _hashAlgAddress, 
        uint8 _percentsFee
    ) public payable {
        require(0 < msg.value);
        
        // 0 to 10 percents fee maximum for contract owner if hash being cracked
        require(0 <= _percentsFee && _percentsFee <= 10);
        
        // In a simple call chain A -> B -> C -> D, 
        // inside D msg.sender will be C, and tx.origin will be A.
        contractOwner = msg.sender;
        
        keccak256OfHash = _keccak256OfHash;
        hashAlgAddress = _hashAlgAddress;
        percentsFee = _percentsFee;
        fee = (msg.value / 100) * percentsFee;
        bounty = msg.value - fee;
    }

    function increaseBounty() public payable {
        require(0 < msg.value);
        require(msg.sender == contractOwner);
        fee = (this.balance / 100) * percentsFee;
        bounty = this.balance - fee;
    }

    function checkBounty() public view returns (uint256) {
        return bounty;
    }
    
    function checkPercentsFee() public view returns (uint8) {
        require(msg.sender == contractOwner);
        return percentsFee;
    }
    
    function checkFee() public view returns (uint256) {
        require(msg.sender == contractOwner);
        return fee;
    }

    function solve(bytes _message) public returns (bool) {
        AbstractAlg abstractAlg = AbstractAlg(hashAlgAddress);
        bytes32 keccak256OfCalcHash = abstractAlg.keccak256OfCalcHash(_message);

        if (keccak256OfCalcHash == keccak256OfHash) {
            uint256 feeBeforeTransfer = fee;
            fee = 0;
            
            uint256 bountyBeforeTransfer = bounty;
            bounty = 0;
            
            // send fee
            contractOwner.transfer(feeBeforeTransfer);
        
            // send bounty
            msg.sender.transfer(bountyBeforeTransfer);
            
            HashCracked(msg.sender, bounty, _message, keccak256OfHash, keccak256OfCalcHash);
            return true;
        }
    
        AttemptFailed(msg.sender, _message, keccak256OfHash, keccak256OfCalcHash);
        return false;
    }
}
