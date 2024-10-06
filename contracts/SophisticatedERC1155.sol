// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract SophisticatedERC1155 is ERC1155, Ownable, Pausable, ERC1155Supply {
    using Strings for uint256;

    // Mapping from token ID to its minting price
    mapping(uint256 => uint256) public tokenPrices;
    
    // Mapping from token ID to its maximum supply
    mapping(uint256 => uint256) public maxSupply;
    
    // Base URI for metadata
    string private _baseUri;
    
    // Contract name
    string public name;
    
    // Royalty information
    uint256 public royaltyPercentage;
    address public royaltyRecipient;

    // Events
    event PriceSet(uint256 indexed tokenId, uint256 price);
    event MaxSupplySet(uint256 indexed tokenId, uint256 supply);
    event RoyaltyUpdated(address indexed recipient, uint256 percentage);

    constructor(
        string memory _name,
        string memory baseUri
    ) ERC1155(baseUri) Ownable() {
        name = _name;
        _baseUri = baseUri;
        royaltyPercentage = 250; // 2.5%
        royaltyRecipient = msg.sender;
    }

    // Modifier to check if max supply won't be exceeded
    modifier withinMaxSupply(uint256 id, uint256 amount) {
        require(
            maxSupply[id] == 0 || totalSupply(id) + amount <= maxSupply[id],
            "Would exceed max supply"
        );
        _;
    }

    function mint(uint256 id, uint256 amount) 
        external 
        payable 
        whenNotPaused 
        withinMaxSupply(id, amount) 
    {
        require(tokenPrices[id] > 0, "Token not for sale");
        require(msg.value >= tokenPrices[id] * amount, "Insufficient payment");
        
        _mint(msg.sender, id, amount, "");
        
        // Refund excess payment
        if (msg.value > tokenPrices[id] * amount) {
            payable(msg.sender).transfer(msg.value - (tokenPrices[id] * amount));
        }
    }

    function mintBatch(
        uint256[] memory ids,
        uint256[] memory amounts
    ) 
        external 
        payable 
        whenNotPaused 
    {
        require(ids.length == amounts.length, "Length mismatch");
        
        uint256 totalPrice = 0;
        for (uint256 i = 0; i < ids.length; i++) {
            require(
                maxSupply[ids[i]] == 0 || 
                totalSupply(ids[i]) + amounts[i] <= maxSupply[ids[i]],
                "Would exceed max supply"
            );
            require(tokenPrices[ids[i]] > 0, "Token not for sale");
            totalPrice += tokenPrices[ids[i]] * amounts[i];
        }
        
        require(msg.value >= totalPrice, "Insufficient payment");
        
        _mintBatch(msg.sender, ids, amounts, "");
        
        // Refund excess payment
        if (msg.value > totalPrice) {
            payable(msg.sender).transfer(msg.value - totalPrice);
        }
    }

    // Owner functions

    function setTokenPrice(uint256 id, uint256 price) external onlyOwner {
        tokenPrices[id] = price;
        emit PriceSet(id, price);
    }

    function setMaxSupply(uint256 id, uint256 supply) external onlyOwner {
        require(
            supply == 0 || supply >= totalSupply(id),
            "Cannot set max supply lower than current supply"
        );
        maxSupply[id] = supply;
        emit MaxSupplySet(id, supply);
    }

    function setRoyaltyInfo(
        address recipient,
        uint256 percentage
    ) external onlyOwner {
        require(percentage <= 1000, "Royalty percentage too high"); // Max 10%
        royaltyRecipient = recipient;
        royaltyPercentage = percentage;
        emit RoyaltyUpdated(recipient, percentage);
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    function setURI(string memory newuri) external onlyOwner {
        _setURI(newuri);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    // View functions

    function uri(uint256 tokenId) 
        public 
        view 
        virtual 
        override 
        returns (string memory) 
    {
        return string(abi.encodePacked(_baseUri, tokenId.toString()));
    }

    function royaltyInfo(
        uint256,
        uint256 salePrice
    ) external view returns (address, uint256) {
        return (royaltyRecipient, (salePrice * royaltyPercentage) / 10000);
    }

    // Internal functions

    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal virtual override(ERC1155, ERC1155Supply) whenNotPaused {
        super._update(from, to, ids, values);
    }
}