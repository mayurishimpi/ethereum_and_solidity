pragma solidity ^0.4.17;

contract Register {
    struct Auditor {
        address auditorAddress;
        bool initialized;
    }

    // Struct to represent a point (x, y) for the polynomial
    struct Point {
        uint256 x;
        uint256 y;
    }

    uint public balance;
    address private _notary;
    uint256 private constant PRIME_MODULUS = 115792089237316195423570985008687907853269984665640564039457584007913129639747;
    uint256 private constant SECRET_MODULUS = 257; 
    // mapping(address => bool) _scoreInitialized;

    mapping(address => bool)  _scoreInitialized;
    mapping(address => uint) private _creditScores;
    mapping(address => uint)  _scoreTimestamps;
    mapping(address => Auditor) private _auditors;
    mapping(address => uint) private _realWorldIds;


    constructor() {
        _notary = msg.sender;
    }
    
    function initScoreLedger(address borrower, uint ficoScore, uint timestamp) public {
        require(!_scoreInitialized[borrower], "Credit score already initialized for this address");
         _creditScores[borrower] = ficoScore;
         _scoreTimestamps[borrower] = timestamp;
         _scoreInitialized[borrower] = true;

    }


function verifyUnusedAddress(address borrower) public view returns (bool) {
        return (!_scoreInitialized[borrower]);
    }

function getScore(address client) public view returns (uint) {
        // Version 1, no encryption of scores
        return _creditScores[client];
        // FIXME: Use amountRequested
    }


     function addAuditor(address auditor) public {
        require(!_auditors[auditor].initialized, "Auditor already added");
        _auditors[auditor] = Auditor(auditor, true);
    }

    function evaluatePolynomial(uint256[] coefficients, uint256 x) private pure returns (uint256) {
        require(coefficients.length > 0, "Coefficients array must not be empty");

        uint256 result = coefficients[0];

        for (uint i = 1; i < coefficients.length; i++) {
            result = addmod(result, mulmod(coefficients[i], modExp(x, i), PRIME_MODULUS), PRIME_MODULUS);
        }

        return result;
    }

    function modExp(uint256 x, uint256 e) private pure returns (uint256 result) {
        result = 1;
        while (e > 0) {
            if (e % 2 == 1) {
                result = mulmod(result, x, PRIME_MODULUS);
            }
            x = mulmod(x, x, PRIME_MODULUS);
            e /= 2;
        }
    }

    function getAuditorCount() private view returns (uint) {
        uint count = 0;
        for (uint i = 0; i < getAuditorCount(); i++) {
            address auditor = getAuditorAddressAtIndex(i);
            if (_auditors[auditor].initialized) {
                count++;
            }
        }
        return count;
    }
    function getAuditorAddressAtIndex(uint index) private view returns (address) {
        require(index < getAuditorCount(), "Index out of bounds");
        address[] memory auditorAddresses = getAuditorAddresses();
        return auditorAddresses[index];
    }


    // Function to get all auditor addresses
    function getAuditorAddresses() private view returns (address[] memory) {
        address[] memory addresses = new address[](getAuditorCount());
        uint count = 0;
        for (uint i = 0; i < getAuditorCount(); i++) {
            address auditor = getAuditorAddressAtIndex(i);
            if (_auditors[auditor].initialized) {
                addresses[count] = auditor;
                count++;
            }
        }
        return addresses;
    }



     function distributeSecret(uint secret, address borrower) private {
        // Define the minimum number of auditors required for secret reconstruction
        uint k = 2; // Change this value based on your requirements

        // Ensure there are enough auditors for secret reconstruction
        require(k <= getAuditorCount(), "Not enough auditors for secret reconstruction");

        // Generate random coefficients for the polynomial
        uint256[] memory coefficients = generateRandomCoefficients(secret, k);

        // Create shares for each auditor
        for (uint i = 0; i < getAuditorCount(); i++) {
            address auditor = getAuditorAddressAtIndex(i);
            uint256 share = evaluatePolynomial(coefficients, i);
            _realWorldIds[auditor] = share;
        }
    }


        // Function to generate random coefficients for the polynomial
    function generateRandomCoefficients(uint secret, uint k) private view returns (uint256[] memory) {
        require(k > 0, "Number of coefficients must be greater than 0");

        uint256[] memory coefficients = new uint256[](k);

        // Set the constant term to the secret
        coefficients[0] = secret;

        // Generate random coefficients for the remaining terms
        for (uint i = 1; i < k; i++) {
            coefficients[i] = uint256(keccak256(abi.encodePacked(secret, i))) % SECRET_MODULUS;
        }

        return coefficients;
    }


    // Reconstruct the secret
    // Function to calculate the inverse modulo
    function inverseModulo(uint256 a) private pure returns (uint256) {
        require(a != 0, "Cannot calculate the inverse modulo of 0");
        return modExp(a, PRIME_MODULUS - 2);
    }


     function reconstructSecret(uint256[] memory auditors, uint256[] memory shares) private pure returns (uint256) {
        require(auditors.length == shares.length, "Mismatched lengths of auditors and shares");
        require(auditors.length > 0, "At least one share is required");

        uint256 secret = 0;

        for (uint i = 0; i < auditors.length; i++) {
            uint256 term = shares[i];

            for (uint j = 0; j < auditors.length; j++) {
                if (j != i) {
                    uint256 numerator = PRIME_MODULUS - auditors[j];
                    uint256 denominator = inverseModulo(auditors[i] - auditors[j]);
                    term = mulmod(term, mulmod(numerator, denominator, PRIME_MODULUS), PRIME_MODULUS);
                }
            }

            secret = addmod(secret, term, PRIME_MODULUS);
        }

        return secret;
    }

    



    // // Function to distribute the contract balance to player1 or player2 randomly
    // function distributeEther() external {

    //     require(balance > 0, "No balance to distribute.");

    //     // Generate a random number (0 or 1)
    //     uint256 randomValue = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 2;



    //     // Distribute all the balance based on the random coin flip
    //     if (randomValue == 0) {
    //         require(player1.send(balance), "Transfer to player1 failed");
    //     } else {
    //     require(player2.send(balance), "Transfer to player2 failed");
    //     }

    //     // Reset the balance to 0
    //     balance = 0;

    // }
}