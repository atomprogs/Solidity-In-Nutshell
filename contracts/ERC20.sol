// SPDX-License-Identifier: MIT

pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract MyToken is ERC20, Ownable, Pausable {
    uint256 public constant maxSupply = 2000000000 * 10**18;
    string public constant NAME = "MEME";
    string public constant SYMBOL = "MEME";

    mapping(address => bool) public isBlacklisted;

    constructor() ERC20(NAME, SYMBOL) Ownable() {
        _mint(msg.sender, 1000000000 * 10**18); // Mint initial supply to the owner
    }

    // Burnable
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    // Mintable (only for the owner)
    function mint(address account, uint256 amount) public onlyOwner {
        unchecked {
            require(totalSupply() + amount <= maxSupply, "Minting would exceed max supply");
        }
        _mint(account, amount);
    }

    // Pausable (temporarily halt transfers)
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // Blacklist functionality (prevent certain addresses from interacting)
    function blacklist(address account) public onlyOwner {
        if (!isBlacklisted[account]) {
            isBlacklisted[account] = true;
        }
    }

    function removeBlacklist(address account) public onlyOwner {
        if (isBlacklisted[account]) {
            isBlacklisted[account] = false;
        }
    }

    // Batch blacklisting for gas efficiency
    function blacklistBatch(address[] calldata accounts) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            if (!isBlacklisted[accounts[i]]) {
                isBlacklisted[accounts[i]] = true;
            }
        }
    }

    function removeBlacklistBatch(address[] calldata accounts) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            if (isBlacklisted[accounts[i]]) {
                isBlacklisted[accounts[i]] = false;
            }
        }
    }

    // Override transfer and transferFrom to check blacklist and pause
    function transfer(address to, uint256 amount)
        public
        override
        notBlacklisted(msg.sender)
        notBlacklisted(to)
        whenNotPaused
        returns (bool)
    {
        return super.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount)
        public
        override
        notBlacklisted(from)
        notBlacklisted(to)
        whenNotPaused
        returns (bool)
    {
        return super.transferFrom(from, to, amount);
    }

    modifier notBlacklisted(address account) {
        require(!isBlacklisted[account], "Address is blacklisted");
        _;
    }
}
