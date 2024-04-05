// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// testing purposes only
import "hardhat/console.sol";

contract GlyphGraph is ERC721URIStorage {
    struct User {
        string _id;
        string email;
        string name;
        string password;
        uint256 timestamp;
    }
    mapping(address => User) Users;
    event UserCreated(
        string _id,
        string email,
        string name,
        string password,
        uint256 timestamp
    );

    struct Vault {
        string _id;
        address user;
        string name;
        bool protected;
        string password;
    }
    mapping(string => Vault)  Vaults;
    event VaultCreated(Vault vault);

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
    mapping(string => Password) Passwords;
    event PasswordCreated(Password password);

    struct Login {
        Vault vault;
        string title;
        string username;
        Password password;
        string[] websites;
        string note;
    }
    mapping(string => Login) Logins;
    event LoginCreated(Login login);

    function __generateRandomString(
        uint256 length
    ) private view returns (string memory) {
        bytes32 randomBytesHash = keccak256(
            abi.encodePacked(block.timestamp, block.number, msg.sender)
        );
        bytes memory randomBytes = abi.encodePacked(randomBytesHash);
        bytes
            memory characters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
        bytes memory randomString = new bytes(length);
        for (uint256 i = 0; i < length; i++) {
            randomString[i] = characters[
                uint8(randomBytes[i]) % characters.length
            ];
        }
        return string(randomString);
    }

    constructor() ERC721("GlyphGraphVaults", "GLG") {}

    function createUser(
        string memory _name,
        string memory _email,
        string memory _password
    ) external {
        require(
            bytes(__users[msg.sender]._id).length == 0,
            "User already exists"
        );

        string memory _randomId = __generateRandomString(32);
        // User memory _user = User({
        //     _id: _randomId,
        //     name: _name,
        //     email: _email,
        //     password: _password,
        //     timestamp: block.timestamp
        // });
        Users[msg.sender] =  User({
            _id: _randomId,
            name: _name,
            email: _email,
            password: _password,
            timestamp: block.timestamp
        });
        emit UserCreated(_randomId, _email, _name, _password, block.timestamp);
    }

    function getUser() public view returns (User memory) {
        console.log(msg.sender, "hello", __users[msg.sender].email);
        return __users[msg.sender];
    }

    function createVault(string memory _name) public {
        User memory __user = __users[msg.sender];
        require(bytes(__user._id).length > 0, "User not found");
        string memory _randomId = __generateRandomString(32);
        Vault memory _vault = Vault({
            _id: _randomId,
            user: msg.sender,
            name: _name,
            protected: false,
            password: ""
        });
        __vaults[_randomId] = _vault;
        emit VaultCreated(_vault);
    }

    function createVault(string memory _name, string memory _password) public {
        User memory __user = __users[msg.sender];
        require(bytes(__user._id).length > 0, "User not found");
        string memory _randomId = __generateRandomString(32);
        Vault memory _vault = Vault({
            _id: _randomId,
            user: msg.sender,
            name: _name,
            protected: true,
            password: _password
        });
        __vaults[_randomId] = _vault;
        emit VaultCreated(_vault);
    }
}
