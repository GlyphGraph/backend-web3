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
    address _address;
    string email;
    string name;
    string password;
    uint256 timestamp;
    bool registered;
}

struct Vault {
    string _id;
    address user;
    string name;
    bool protected;
    string password;
    bool created;
}

enum PasswordType {
    RANDOM,
    MEMORABLE
}

struct Password {
    address user;
    string image;
    uint32 rows;
    uint32 cols;
    bool specialCharacters;
    bool capitalLetters;
    bool numbers;
    PasswordType passwordType;
    bool created;
}

struct Login {
    Vault vault;
    string title;
    string username;
    Password password;
    string[] websites;
    string note;
    bool created;
}

interface IGlyphGraph is IERC721 {
    // user
    function getUserDetails() external view returns (User memory);

    function addUser(
        string memory _email,
        string memory _name,
        string memory _password
    ) external;

    // vault

    function createVaultWithPassword(
        string memory _name,
        bool _protected,
        string memory _password
    ) external;

    function getUserVaults() external view returns (Vault[] memory);

    function updateVaultPassword(
        string memory _vaultId,
        string memory _newPassword
    ) external;

    function protectVault(
        string memory _vaultId,
        string memory _newPassword
    ) external;

    // function removeProtection(string memory _vaultId) external;

    // password

    function createPasswordWithSettings(
        string memory _image,
        uint32 _rows,
        uint32 _cols,
        bool _specialCharacters,
        bool _capitalLetters,
        bool _numbers,
        PasswordType _passwordType
    ) external;

    function getPassword(
        string memory _id
    ) external view returns (Password memory);

    function getUserPasswords() external view returns (Password[] memory);

    // logins
    function createLogin(
        string memory _vaultId,
        string memory _title,
        string memory _username,
        string memory _passwordId,
        string[] memory _websites,
        string memory _note
    ) external;

    function getLogin(string memory _id) external view returns (Login memory);
    function getVaultLogins(string memory _vaultId) external view returns (Login[] memory);
}

contract GlyphGraph is ERC721URIStorage, IGlyphGraph {
    error GlyphGraph__UserAlreadyExists();
    error GlyphGraph__UserNotFound();
    error GlyphGraph__VaultNotFound();
    error GlyphGraph__VaultAlreadyExists();
    error GlyphGraph__PasswordNotFound();
    error GlyphGraph__PasswordAlreadyExists();
    error GlyphGraph__LoginAlreadyExists();
    error GlyphGraph__LoginNotFound();

    mapping(address => User) private Users;
    mapping(address => string[]) private UserVaults;
    mapping(string => Vault) private Vaults;
    mapping(address => string[]) private UserPasswords;
    mapping(string => Password) private Passwords;
    mapping(address => string[]) private UserLogins;
    mapping(string => Login) private Logins;

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

    constructor() ERC721("GlyphGraph", "GLG") {}

    function addUser(
        string memory _name,
        string memory _email,
        string memory _password
    ) public {
        if (
            Users[msg.sender].registered == true ||
            bytes(Users[msg.sender]._id).length > 0
        ) {
            revert GlyphGraph__UserAlreadyExists();
        }
        string memory _randomId = __generateRandomString(32);
        Users[msg.sender] = User(
            _randomId,
            msg.sender,
            _name,
            _email,
            _password,
            block.timestamp,
            true
        );
    }

    function getUserDetails() public view returns (User memory) {
        User memory __user = Users[msg.sender];
        if (bytes(__user._id).length == 0) {
            revert GlyphGraph__UserNotFound();
        }
        return __user;
    }

    function createVaultWithPassword(
        string memory _name,
        bool _protected,
        string memory _password
    ) public {
        User memory __user = Users[msg.sender];
        if (bytes(__user._id).length == 0) {
            revert GlyphGraph__UserNotFound();
        }
        string memory _randomId = __generateRandomString(32);
        Vault memory _vault = Vault(
            _randomId,
            msg.sender,
            _name,
            _protected,
            _password,
            true
        );
        Vaults[_randomId] = _vault;
        UserVaults[msg.sender].push(_randomId);
    }

    function getUserVaults() public view returns (Vault[] memory) {
        User memory __user = Users[msg.sender];
        if (bytes(__user._id).length == 0) {
            revert GlyphGraph__UserNotFound();
        }
        Vault[] memory _vaults = new Vault[](UserVaults[msg.sender].length);
        for (uint256 i = 0; i < UserVaults[msg.sender].length; i++) {
            string memory vaultId = UserVaults[msg.sender][i];
            _vaults[i] = Vaults[vaultId];
        }
        return _vaults;
    }

    function updateVaultPassword(
        string memory _vaultId,
        string memory _newPassword
    ) public {
        User memory __user = Users[msg.sender];
        if (bytes(__user._id).length == 0) {
            revert GlyphGraph__UserNotFound();
        }
        if (bytes(Vaults[_vaultId]._id).length == 0) {
            revert GlyphGraph__VaultNotFound();
        }
        Vaults[_vaultId].password = _newPassword;
    }

    function protectVault(
        string memory _vaultId,
        string memory _newPassword
    ) public {
        User memory __user = Users[msg.sender];
        if (bytes(__user._id).length == 0) {
            revert GlyphGraph__UserNotFound();
        }
        if (bytes(Vaults[_vaultId]._id).length == 0) {
            revert GlyphGraph__VaultNotFound();
        }
        Vaults[_vaultId].protected = true;
        Vaults[_vaultId].password = _newPassword;
    }

    // function removeProtection(string memory _vaultId) public {
    //     User memory __user = Users[msg.sender];
    //     if (bytes(__user._id).length == 0) {
    //         revert GlyphGraph__UserNotFound();
    //     }
    //     if (bytes(Vaults[_vaultId]._id).length == 0) {
    //         revert GlyphGraph__VaultNotFound();
    //     }
    //     Vaults[_vaultId].protected = false;
    //     Vaults[_vaultId].password = "";
    // }

    function createPasswordWithSettings(
        string memory _image,
        uint32 _rows,
        uint32 _cols,
        bool _specialCharacters,
        bool _capitalLetters,
        bool _numbers,
        PasswordType _passwordType
    ) external {
        User memory __user = Users[msg.sender];
        if (bytes(__user._id).length == 0) {
            revert GlyphGraph__UserNotFound();
        }
        string memory _randomId = __generateRandomString(32);
        Password memory _password = Password(
            msg.sender,
            _image,
            _rows,
            _cols,
            _specialCharacters,
            _capitalLetters,
            _numbers,
            _passwordType,
            true
        );
        Passwords[_randomId] = _password;
        UserPasswords[msg.sender].push(_randomId);
    }

    function getPassword(
        string memory _id
    ) external view returns (Password memory) {
        User memory __user = Users[msg.sender];
        if (bytes(__user._id).length == 0) {
            revert GlyphGraph__UserNotFound();
        }
        if (bytes(Passwords[_id].image).length == 0) {
            revert GlyphGraph__PasswordNotFound();
        }
        return Passwords[_id];
    }

    function getUserPasswords() external view returns (Password[] memory) {
        User memory __user = Users[msg.sender];
        if (bytes(__user._id).length == 0) {
            revert GlyphGraph__UserNotFound();
        }

        Password[] memory userPasswords = new Password[](0);
        for (uint256 i = 0; i < UserPasswords[msg.sender].length; i++) {
            string memory passwordId = UserPasswords[msg.sender][i];
            userPasswords[i] = Passwords[passwordId];
        }
        return userPasswords;
    }

    function createLogin(
        string memory _vaultId,
        string memory _title,
        string memory _username,
        string memory _passwordId,
        string[] memory _websites,
        string memory _note
    ) external {
        User memory __user = Users[msg.sender];
        if (bytes(__user._id).length == 0) {
            revert GlyphGraph__UserNotFound();
        }
        if (bytes(Vaults[_vaultId]._id).length == 0) {
            revert GlyphGraph__VaultNotFound();
        }
        if (bytes(Passwords[_passwordId].image).length == 0) {
            revert GlyphGraph__PasswordNotFound();
        }
        string memory _randomId = __generateRandomString(32);
        Login memory _login = Login(
            Vaults[_vaultId],
            _title,
            _username,
            Passwords[_passwordId],
            _websites,
            _note,
            true
        );
        Logins[_randomId] = _login;
        UserLogins[msg.sender].push(_randomId);
    }

    function getLogin(string memory _id) external view returns (Login memory) {
        User memory __user = Users[msg.sender];
        if (bytes(__user._id).length == 0) {
            revert GlyphGraph__UserNotFound();
        }
        if (bytes(Logins[_id].vault._id).length == 0) {
            revert GlyphGraph__LoginNotFound();
        }
        return Logins[_id];
    }

    function getVaultLogins(string memory _vaultId) external view returns (Login[] memory) {
        User memory __user = Users[msg.sender];
        if (bytes(__user._id).length == 0) {
            revert GlyphGraph__UserNotFound();
        }

        if (bytes(Vaults[_vaultId]._id).length == 0) {
            revert GlyphGraph__VaultNotFound();
        }

        Login[] memory vaultLogins = new Login[](0);
        uint256 counter = 0;
        for (uint256 i = 0; i < UserLogins[msg.sender].length; i++) {
            string memory loginId = UserLogins[msg.sender][i];
            Login memory login = Logins[loginId];
            if (Strings.equal(login.vault._id, _vaultId)) {
                vaultLogins[counter] = login;
                counter++;
            }
        }
        return vaultLogins;
    }
}
