// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract EducationVerification {
    address public university;

    struct Certificate {
        uint256 issuedAt;
        uint256 revokedAt; // 0 = not revoked
        bool exists;
    }

    mapping(bytes32 => Certificate) public certificates;

    event CertificateIssued(bytes32 indexed certHash, uint256 timestamp);
    event CertificateRevoked(bytes32 indexed certHash, uint256 timestamp);

    modifier onlyUniversity() {
        require(msg.sender == university, "Not authorized");
        _;
    }

    constructor() {
        university = msg.sender;
    }

    function issueCertificate(string calldata certId) external onlyUniversity {
        bytes32 certHash = keccak256(abi.encodePacked(certId));
        require(!certificates[certHash].exists, "Already issued");

        certificates[certHash] = Certificate(
            block.timestamp,
            0,
            true
        );

        emit CertificateIssued(certHash, block.timestamp);
    }

    function revokeCertificate(string calldata certId) external onlyUniversity {
        bytes32 certHash = keccak256(abi.encodePacked(certId));
        require(certificates[certHash].exists, "Not issued");
        require(certificates[certHash].revokedAt == 0, "Already revoked");

        certificates[certHash].revokedAt = block.timestamp;

        emit CertificateRevoked(certHash, block.timestamp);
    }

    function verifyCertificate(string memory certId)
        external
        view
        returns (
            bool valid,
            bool revoked,
            uint256 issuedAt,
            uint256 revokedAt
        )
    {
        bytes32 certHash = keccak256(abi.encodePacked(certId));
        Certificate memory cert = certificates[certHash];

        if (!cert.exists) {
            return (false, false, 0, 0);
        }

        if (cert.revokedAt != 0) {
            return (
                false,
                true,
                cert.issuedAt,
                cert.revokedAt
            );
        }

        return (
            true,
            false,
            cert.issuedAt,
            0
        );
    }
}
