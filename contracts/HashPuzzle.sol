pragma solidity ^0.4.18;
//pragma experimental ABIEncoderV2; 

import "./AbstractAlg.sol";

contract HashPuzzle {
    event HashCracked(address crackedBy, uint256 bounty, bytes message, bytes hash, bytes32 keccak256OfCalcHash);
    event AttemptFailed(address source, bytes message, bytes hash, bytes32 keccak256OfCalcHash);
    
    address private contractOwner;
    
    bytes private hash;
    address private hashAlgAddress;
    uint8 private fee; // (0 to 10 percents max) for contract owner if hash being cracked
    
    function HashPuzzle(bytes _hash, address _hashAlgAddress, uint8 _fee) public payable {
        require(0 <= _fee && _fee <= 10);
        
        // In a simple call chain A -> B -> C -> D, 
        // inside D msg.sender will be C, and tx.origin will be A.
        contractOwner = msg.sender;
        
        hash = _hash;
        hashAlgAddress = _hashAlgAddress;
        fee = _fee;
    }
    
    function increaseBounty() public payable {
    }
    
    function checkBounty() public view returns (uint256) {
       return this.balance;
    }
    
    function solve(bytes _message) public returns (bool) {
        AbstractAlg abstractAlg = AbstractAlg(hashAlgAddress);
        bytes32 keccak256OfCalcHash = abstractAlg.keccak256OfCalcHash(_message);

        if (keccak256OfCalcHash == keccak256(hash)) {
            uint256 bounty = this.balance;
            uint256 ownerFee = (this.balance / 100) * fee;

            contractOwner.transfer(ownerFee);
            msg.sender.transfer(this.balance);
            
            HashCracked(msg.sender, bounty, _message, hash, keccak256OfCalcHash);
            return true;
        }
    
        AttemptFailed(msg.sender, _message, hash, keccak256OfCalcHash);
        return false;
    }
}