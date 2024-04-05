// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// testing purposes only
import "hardhat/console.sol";

struct User {
    string _id;
    string email;
    string name;
    string password;
    uint256 timestamp;
}

struct Vault {
    string _id;
    address user;
    string name;
    bool protected;
    string password;
}

struct Password {
    string image;
    uint32 size;
    uint32 row;
    uint32 col;
    bool specialCharacters;
    bool capitalLetters;
    bool includeNumbers;
    address user;
}

struct Login {
    Vault vault;
    string title;
    string username;
    Password password;
    string[] websites;
    string note;
}

interface IGlyphGraph is IERC721 {
    // user
    function getUser() external view returns (User memory);
    function createUser(
        string memory _email,
        string memory _name,
        string memory _password
    ) external view returns (User memory);
    // function updatePassword(string memory _password) external view;

    // vault
    function createVault(string memory _name) external;
    function createVault(string memory _name, string memory _password) external;
    // function getVaultsByUser() external view returns (Vault[] memory);
    // function updateVault(Vault memory _vault) external view returns (Vault memory);

    // password
    // function createPassword(string memory _image) external;
}

contract GlyphGraph is ERC721URIStorage, IGlyphGraph {
    address payable owner;

    mapping(address => User) private __users;
    event emitUser(User user);

    mapping(string => Vault) private __vaults;
    event emitVault(Vault vault);

    mapping(string => Password) private __passwords;
    event emitPassword(Password password);

    mapping(string => Login) private __logins;
    event emitLogin(Login login);

    function __generateRandomString() private view returns (string memory) {
        bytes32 randomBytesHash = keccak256(
            abi.encodePacked(block.timestamp, block.number, msg.sender)
        );
        uint32 length = 32;
        bytes memory randomBytes = abi.encodePacked(randomBytesHash);
        bytes
            memory characters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~";
        bytes memory randomString = new bytes(length);
        for (uint256 i = 0; i < length; i++) {
            randomString[i] = characters[
                uint8(randomBytes[i]) % characters.length
            ];
        }
        return string(randomString);
    }

    // function __compareStrings(
    //     string memory _str1,
    //     string memory _str2
    // ) private pure returns (bool) {
    //     console.log("S1", _str1);
    //     console.log("S2", _str2);
    //     console.log(keccak256(abi.encodePacked(_str1)) == keccak256(abi.encodePacked(_str2)));
    //     return keccak256(abi.encodePacked(_str1)) == keccak256(abi.encodePacked(_str2));
    // }

    constructor() ERC721("GlyphGraphVaults", "GLG") {
        console.log(__generateRandomString());
    }

    function createUser(
        string memory _name,
        string memory _email,
        string memory _password
    ) external {
        console.log(msg.sender);
        bytes32 emailHash = keccak256(bytes(_email));
        bytes32 existingEmailHash = keccak256(bytes(__users[msg.sender].email));
        require(existingEmailHash == 0 || existingEmailHash == emailHash, "User already exists");

        string memory _randomId = __generateRandomString();
        User memory _user = User({
            _id: _randomId,
            name: _name,
            email: _email,
            password: _password,
            timestamp: block.timestamp
        });
        __users[msg.sender] = _user;
    }

    function getUser() public view returns (User memory) {
        return __users[msg.sender];
    }

    function createVault(string memory _name) public {
        User memory __user = __users[msg.sender];
        require(bytes(__user._id).length > 0, "User not found");
        string memory _randomId = __generateRandomString();
        Vault memory _vault = Vault({
            _id: _randomId,
            user: msg.sender,
            name: _name,
            protected: false,
            password: ""
        });
        __vaults[_randomId] = _vault;
        emit emitVault(_vault);
    }

    function createVault(string memory _name, string memory _password) public {
        User memory __user = __users[msg.sender];
        require(bytes(__user._id).length > 0, "User not found");
        string memory _randomId = __generateRandomString();
        Vault memory _vault = Vault({
            _id: _randomId,
            user: msg.sender,
            name: _name,
            protected: true,
            password: _password
        });
        __vaults[_randomId] = _vault;
        emit emitVault(_vault);
    }

    // function getVaultsByUser() public view returns (Vault[] memory) {
    //     User memory user = __users[msg.sender];
    //     require(bytes(user._id).length > 0, "User not found");
    //     Vault[] memory _vaults = new Vault[](0);
    //     for (uint256 i = 0; i < __vaults.length; i++) {
    //         Vault storage vault = __vaults[__vaults.keys[i]];
    //         if (vault.user == msg.sender) {
    //             _vaults.push(vault);
    //         }
    //     }
    //     return _vaults;
    // }


}
