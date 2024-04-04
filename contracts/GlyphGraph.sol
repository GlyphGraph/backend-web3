// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract GlyphGraph is ERC721URIStorage {
    address payable owner;

    struct Account {
        uint id;
        string email;
        string name;
        address[] wallets;
        uint timestamp;
    }

    function _generateRandomId() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(msg.sender, block.timestamp)));
    }

    constructor() ERC721("GlyphGraphVaults", "GLG") {}
}
