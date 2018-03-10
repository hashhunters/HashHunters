pragma solidity ^0.4.18;

/* 
 * We can enter the address of an already deployed contract to load it and be 
 * able to call its functions. Specially useful when you have a contract that 
 * deploys other contracts and you want to interact with those contracts.
 * Another use case is to interact with verified contracts on etherscan.io 
 */
contract AbstractAlg {
    /*  
     *  Function returns keccak256 of calculated hash: keccak256(calcHash(message)).
     *  This is workaround because there was no way to properly retrieve variable 
     *  length data in cross-contract calls. This will change with Metropolis and
     *  will be possible to use bytes instead of bytes32.
     *
     *  https://github.com/ethereum/solidity/issues/2708#issuecomment-320957367
     */
    function keccak256OfCalcHash(bytes message) public pure returns (bytes32 ret);
}
