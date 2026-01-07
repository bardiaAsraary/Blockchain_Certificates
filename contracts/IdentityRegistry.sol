
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract IdentityRegistry {

    mapping(bytes32 => address) public educationChain;

    function register(bytes32 personID, address eduAddress) external {
        educationChain[personID] = eduAddress;
    }

    function resolve(bytes32 personID) external view returns (address) {
        return educationChain[personID];
    }
}
