// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Ownable} from "openzeppelin/contracts/access/Ownable.sol";
import {ERC721} from "openzeppelin/contracts/token/ERC721/ERC721.sol";
contract Badge is ERC721, Ownable {
    struct BadgeInfo {
        uint256 id;
        string name;
        string description;
    }
    uint256 private _currentTokenId = 0;
    mapping(uint256 => BadgeInfo) private _badgeInfos;

    event BadgeMinted(uint256 indexed tokenId, address indexed to, string name);
    error BadgeNotFound(uint256 tokenId);

    constructor() ERC721("Badge", "BDG") Ownable(msg.sender) {}

    /// @notice Mint a new Badge to `to` with given `name` and `description`
    /// @dev only owner can mint. Uses ERC721 sequential minting; capture totalSupply before mint.
    function mintBadge(
        address to,
        string memory name,
        string memory description
    ) external onlyOwner {
       uint256 tokenId = (_currentTokenId++);
        _safeMint(to, tokenId);
        _badgeInfos[tokenId] = BadgeInfo({
            id: tokenId,
            name: name,
            description: description
        });
        emit BadgeMinted(tokenId, to, name);
    }

    /// @notice Read badge info for a given tokenId
    function getBadgeInfo(
        uint256 tokenId
    )
        external
        view
        returns (uint256 id, string memory name, string memory description)
    {
        if(_badgeInfos[tokenId].id != tokenId) revert BadgeNotFound(tokenId);
        BadgeInfo storage info = _badgeInfos[tokenId];
        return (info.id, info.name, info.description);
    }
}
