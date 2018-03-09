pragma solidity ^0.4.18;

// https://github.com/crypto-browserify/hash-test-vectors
// The nist test vectors expanded to cover every hash function supported by node.js, 
// output is saved in a json file, so that it is possible to run tests in the browser.

/*
    SHA1 implementation in Solidity assembly.
    It requires roughly 56k gas per 512 bit block hashed
*/
contract SHA1 {

    /* 
        The fallback function below will be called for each message that is 
        sent to this contract (as there is no other function to call).
        However, if Ether is sent to this contract, an exception will occur.
        That is because this contract does not have the "payable" modifier.
    */
    
    function() public {
        assembly {
            switch div(calldataload(0), exp(2, 224))
            
            // check function name (prevent calls frpm inappropriate functions): 
            // bytes4(keccak256("sha1(bytes)")) is 0x1605782b
            // bytes4(keccak256("keccak256OfCalcHash(bytes)")) is 0xa7b5f164
            case 0xa7b5f164 { } 
            default { revert(0, 0) }
            
            let data := add(calldataload(4), 4)

            // Get the data length, and point data at the first byte
            let len := calldataload(data)
            data := add(data, 32)

            // Find the length after padding
            let totallen := add(and(add(len, 1), 0xFFFFFFFFFFFFFFC0), 64)
            switch lt(sub(totallen, len), 9)
            case 1 { totallen := add(totallen, 64) }

            let h := 0x6745230100EFCDAB890098BADCFE001032547600C3D2E1F0

            for { let i := 0 } lt(i, totallen) { i := add(i, 64) } {
                // Load 64 bytes of data
                calldatacopy(0, add(data, i), 64)

                // If we loaded the last byte, store the terminator byte
                switch lt(sub(len, i), 64)
                case 1 { mstore8(sub(len, i), 0x80) }

                // If this is the last block, store the length
                switch eq(i, sub(totallen, 64))
                case 1 { mstore(32, or(mload(32), mul(len, 8))) }

                // Expand the 16 32-bit words into 80
                for { let j := 64 } lt(j, 128) { j := add(j, 12) } {
                    let temp := xor(xor(mload(sub(j, 12)), mload(sub(j, 32))), xor(mload(sub(j, 56)), mload(sub(j, 64))))
                    temp := or(and(mul(temp, 2), 0xFFFFFFFEFFFFFFFEFFFFFFFEFFFFFFFEFFFFFFFEFFFFFFFEFFFFFFFEFFFFFFFE), and(div(temp, exp(2, 31)), 0x0000000100000001000000010000000100000001000000010000000100000001))
                    mstore(j, temp)
                }
                for { let j := 128 } lt(j, 320) { j := add(j, 24) } {
                    let temp := xor(xor(mload(sub(j, 24)), mload(sub(j, 64))), xor(mload(sub(j, 112)), mload(sub(j, 128))))
                    temp := or(and(mul(temp, 4), 0xFFFFFFFCFFFFFFFCFFFFFFFCFFFFFFFCFFFFFFFCFFFFFFFCFFFFFFFCFFFFFFFC), and(div(temp, exp(2, 30)), 0x0000000300000003000000030000000300000003000000030000000300000003))
                    mstore(j, temp)
                }

                let x := h
                let f := 0
                let k := 0
                for { let j := 0 } lt(j, 80) { j := add(j, 1) } {
                    switch div(j, 20)
                    case 0 {
                        // f = d xor (b and (c xor d))
                        f := xor(div(x, exp(2, 80)), div(x, exp(2, 40)))
                        f := and(div(x, exp(2, 120)), f)
                        f := xor(div(x, exp(2, 40)), f)
                        k := 0x5A827999
                    }
                    case 1{
                        // f = b xor c xor d
                        f := xor(div(x, exp(2, 120)), div(x, exp(2, 80)))
                        f := xor(div(x, exp(2, 40)), f)
                        k := 0x6ED9EBA1
                    }
                    case 2 {
                        // f = (b and c) or (d and (b or c))
                        f := or(div(x, exp(2, 120)), div(x, exp(2, 80)))
                        f := and(div(x, exp(2, 40)), f)
                        f := or(and(div(x, exp(2, 120)), div(x, exp(2, 80))), f)
                        k := 0x8F1BBCDC
                    }
                    case 3 {
                        // f = b xor c xor d
                        f := xor(div(x, exp(2, 120)), div(x, exp(2, 80)))
                        f := xor(div(x, exp(2, 40)), f)
                        k := 0xCA62C1D6
                    }
                    // temp = (a leftrotate 5) + f + e + k + w[i]
                    let temp := and(div(x, exp(2, 187)), 0x1F)
                    temp := or(and(div(x, exp(2, 155)), 0xFFFFFFE0), temp)
                    temp := add(f, temp)
                    temp := add(and(x, 0xFFFFFFFF), temp)
                    temp := add(k, temp)
                    temp := add(div(mload(mul(j, 4)), exp(2, 224)), temp)
                    x := or(div(x, exp(2, 40)), mul(temp, exp(2, 160)))
                    x := or(and(x, 0xFFFFFFFF00FFFFFFFF000000000000FFFFFFFF00FFFFFFFF), mul(or(and(div(x, exp(2, 50)), 0xC0000000), and(div(x, exp(2, 82)), 0x3FFFFFFF)), exp(2, 80)))
                }

                h := and(add(h, x), 0xFFFFFFFF00FFFFFFFF00FFFFFFFF00FFFFFFFF00FFFFFFFF)
            }
            h := or(or(or(or(and(div(h, exp(2, 32)), 0xFFFFFFFF00000000000000000000000000000000), and(div(h, exp(2, 24)), 0xFFFFFFFF000000000000000000000000)), and(div(h, exp(2, 16)), 0xFFFFFFFF0000000000000000)), and(div(h, exp(2, 8)), 0xFFFFFFFF00000000)), and(h, 0xFFFFFFFF))
            ////log1(0, 0, h)
            // ======== sha1(message) ========= //
            //
            //mstore(0, h)
            //return(12, 20)
            //
            // === keccak256(sha1(message)) === //
            
            // store 32 bytes in memory at position 0
            mstore(0, h)
            
            let sh3 := keccak256(12, 20)
            mstore(0, sh3)
            return(0, 32)
            // ================================ //
        }
    }
}
