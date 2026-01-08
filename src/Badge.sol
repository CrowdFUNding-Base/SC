// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {ERC721A} from "erc721a/contracts/ERC721A.sol";
import {Ownable} from "openzeppelin/contracts/access/Ownable.sol";

contract Badge is ERC721A, Ownable {
    struct BadgeInfo {
        uint256 id;
        string name;
        string description;
    }
    // mapping from tokenId => BadgeInfo
    mapping(uint256 => BadgeInfo) private _badgeInfos;

    event BadgeMinted(uint256 indexed tokenId, address indexed to, string name);

    constructor() ERC721A("Badge", "BDG") Ownable(msg.sender) {}

    /// @notice Mint a new Badge to `to` with given `name` and `description`
    /// @dev only owner can mint. Uses ERC721A sequential minting; capture _nextTokenId before mint.
    function mintBadge(
        address to,
        string memory name,
        string memory description
    ) external onlyOwner {
        uint256 tokenId = _nextTokenId();
        _safeMint(to, 1);
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
        require(_exists(tokenId), "Badge: query for nonexistent token");
        BadgeInfo storage info = _badgeInfos[tokenId];
        return (info.id, info.name, info.description);
    }
}
