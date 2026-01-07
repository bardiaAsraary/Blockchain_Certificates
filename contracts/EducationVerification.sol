// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract EducationVerification {
    address public university;
    bytes32 public revocationMerkleRoot;

    constructor() {
        university = msg.sender;
    }

    modifier onlyUniversity() {
        require(msg.sender == university, "Not authorized");
        _;
    }

    function revokeCertificate(bytes32 newRoot) external onlyUniversity {
        revocationMerkleRoot = newRoot;
    }

    function verify(bytes32 leaf, bytes32[] calldata proof)
        external
        view
        returns (bool)
    {
        // ✅ SINGLE-LEAF TREE CASE (CRITICAL FIX)
        if (proof.length == 0) {
            return leaf == revocationMerkleRoot;
        }

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                computedHash = keccak256(
                    abi.encodePacked(computedHash, proofElement)
                );
            } else {
                computedHash = keccak256(
                    abi.encodePacked(proofElement, computedHash)
                );
            }
        }

        return computedHash == revocationMerkleRoot;
    }
}
