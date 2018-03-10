pragma solidity ^0.4.18;

import './HashPuzzle.sol';

contract HashHunters {

    address private contractOwner;
    uint8 private contractOwnerFee;
    
    mapping (bytes32 => address) public hashAlgorithmAddresses;
    bytes32[] public hashAlgorithms; // supported hash algorithms
    
    mapping (address => HashPuzzleData) hashPuzzles; // every hash puzzle is a new contract
    address[] public hashPuzzleContracts;
    
    struct HashPuzzleData {
        address owner;
        uint256 bounty;
        bytes hash;
        bytes32 hashAlgorithm;
        string description;
        string password;
        bool solved;
    }
    
    function HashHunters(uint8 fee) public {
        contractOwner = msg.sender;
        contractOwnerFee = fee;
    }
    
    modifier isOwner() {
        require(msg.sender == contractOwner);
        _;
    }

    function addNewHashAlgorithm(
        bytes32 _name,   // SHA1, MD4, NTLMv1, ...
        address _address // contract address of new hash algorithm supported
    ) public isOwner {
        if(hashAlgorithmAddresses[_name] == 0)
            hashAlgorithms.push(_name);
        
        hashAlgorithmAddresses[_name] = _address;
    }
    
    function changeFee(uint8 newFee) public isOwner {
        // 0 to 10 percents fee maximum for contract owner if hash being cracked
        require(0 <= newFee && newFee <= 10);
        
        contractOwnerFee = newFee;
    }
    
    function newHashPuzzle(
        bytes _hash,
        bytes32 _hashAlgorithmName,
        string _description
    ) public payable returns (bool) {
        require(0 < msg.value); // 0 < bounty, make spam expensive
        require(hashAlgorithmAddresses[_hashAlgorithmName] != 0); // check support for this algorithm
        
        bytes32 keccak256OfHash = keccak256(_hash);
        
        // TODO: check if hash puzzle exists and not solved
        // keccak256(toLower(_hash)|toLower(_hashAlgorithm)) // keccak256(...) returns (bytes32)
        
        HashPuzzleData memory hpd;
        hpd.owner = msg.sender;
        hpd.bounty = msg.value;
        hpd.hash = _hash;       // TODO: check hash for valid symbols
        hpd.hashAlgorithm = _hashAlgorithmName;
        hpd.description = _description;
        hpd.solved = false;

        HashPuzzle hashPuzzleAddress = new HashPuzzle(
            keccak256OfHash, 
            hashAlgorithmAddresses[_hashAlgorithmName],
            contractOwnerFee
        );
            
        hashPuzzles[hashPuzzleAddress] = hpd;
        hashPuzzleContracts.push(hashPuzzleAddress);
        
        return true;
    }
    
    function solveHashPuzzle(
        bytes message, 
        address hashPuzzleAddress
    ) public returns (bool) {
        HashPuzzle hp = HashPuzzle(hashPuzzleAddress);
        bool success = hp.solve(message);
        
        if(success) {
            hashPuzzles[hashPuzzleAddress].solved = true;
            return true;
        }
        
        return false;
    }
}

