// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721, Ownable {
    uint256 public nextTokenId;
    string private baseTokenURI; // Renamed to avoid shadowing

    constructor(string memory name, string memory symbol, string memory baseURI_) ERC721(name, symbol) {
        baseTokenURI = baseURI_;  // Set the base URI for NFT metadata
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function mintNFT(address recipient) public onlyOwner {
        uint256 tokenId = nextTokenId;
        nextTokenId++;
        _safeMint(recipient, tokenId);
    }

    function setBaseURI(string memory newBaseURI) public onlyOwner {
        baseTokenURI = newBaseURI;
    }
}
