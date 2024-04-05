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
        address _address;
        string email;
        string name;
        string password;
        uint256 timestamp;
        bool registered;
    }
    mapping(address => User) private Users;
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
        bool created;
    }
    mapping(string => Vault) private Vaults;
    event VaultCreated(
        string _id,
        address user,
        string nam,
        bool protecte,
        string password
    );

    struct Password {
        string image;
        uint32 size;
        uint32 row;
        uint32 col;
        bool specialCharacters;
        bool capitalLetters;
        bool includeNumbers;
        address user;
        bool created;
    }
    mapping(string => Password) private Passwords;
    event PasswordCreated(Password password);

    struct Login {
        Vault vault;
        string title;
        string username;
        Password password;
        string[] websites;
        string note;
        bool created;
    }
    mapping(string => Login) private Logins;
    event LoginCreated(Login login);

    error GlyphGraph__UserAlreadyExists();
    error GlyphGraph__UserDoesNotFound();
    error GlyphGraph__VaultNotFound();
    error GlyphGraph__VaultAlreadyExists();
    error GlyphGraph__PasswordNotFound();
    error GlyphGraph__PasswordAlreadyExists();
    error GlyphGraph__LoginAlreadyExists();
    error GlyphGraph__LoginNotFound();

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
    ) publi {
        if (Users[msg.sender].registered == true) {
            revert GlyphGraph__UserAlreadyExists(); 
        }
        string memory _randomId = __generateRandomString(32);
        Users[msg.sender]._id = _randomId;
        Users[msg.sender]._address = msg.sender;
        Users[msg.sender].name = _name;
        Users[msg.sender].email = _email;
        Users[msg.sender].password = _password;
        Users[msg.sender].timestamp = block.timestamp;
        emit UserCreated(_randomId, _email, _name, _password, block.timestamp);
        // _mint(msg.sender, 1);
    }

    function getUser(address _address) external view returns (User memory) {
        return Users[_address];
    }

    function createVault(address _user, string memory _name) public {
        User memory __user = Users[_user];
        require(bytes(__user._id).length > 0, "User not found");
        string memory _randomId = __generateRandomString(32);
        Vault memory _vault = Vault({
            _id: _randomId,
            user: _user,
            name: _name,
            protected: false,
            password: "",
            created: true
        });
        Vaults[_randomId] = _vault;
        emit VaultCreated(_randomId, msg.sender, _name, false, "");
    }

    function createVaultWithPassword(address _user, string memory _name, string memory _password) public {
        User memory __user = Users[_user];
        require(bytes(__user._id).length > 0, "User not found");
        string memory _randomId = __generateRandomString(32);
        Vault memory _vault = Vault({
            _id: _randomId,
            user: _user,
            name: _name,
            protected: true,
            password: _password,
            created: true
        });
        Vaults[_randomId] = _vault;
        emit VaultCreated(_randomId, msg.sender, _name, true, _password);
    }
}
