// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Import OpenZeppelin's ERC721 and Ownable libraries from GitHub
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.7.3/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.7.3/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.7.3/contracts/utils/Counters.sol";

contract MyNFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    
    // Counter to keep track of token IDs
    Counters.Counter private _tokenIdCounter;

    // Constructor to set the NFT's name and symbol
    constructor() ERC721("MyNFT", "MNFT") {}

    // Function to mint new NFTs, only callable by the contract owner
    function mintNFT(address to) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _mint(to, tokenId);
    }

    // Optional: Set the base URI for metadata
    function _baseURI() internal view virtual override returns (string memory) {
        return "https://my-nft-metadata.io/"; // Replace with your base URI
    }
}
