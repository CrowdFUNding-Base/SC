// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {Ownable} from "openzeppelin/contracts/access/Ownable.sol";
import {Badge} from "../src/Badge.sol";


contract BadgeTest is Test {
    Badge public badge;
    address public owner;
    address public user;

    function setUp() public {
        owner = makeAddr("owner");
        user = makeAddr("user");
        vm.prank(owner);
        badge = new Badge();
    }

    function testMintBadge() public {
        vm.prank(owner);
        badge.mintBadge(user, "Test Badge", "Test Description");
        assertEq(badge.ownerOf(0), user);
        assertEq(badge.name(), "Badge");
        assertEq(badge.symbol(), "BDG");
    }

    function testMintBadgeFail() public {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user));
        vm.prank(user);
        badge.mintBadge(user, "Test Badge", "Test Description");
    }

    function testBadgeInfo() public {
        vm.startPrank(owner);
        badge.mintBadge(user, "Test Badge", "Test Description");
        badge.mintBadge(user, "Test Badge 2", "Test Description 2");
        vm.stopPrank();
        (uint256 id, string memory name, string memory description) = badge.getBadgeInfo(0);
        assertEq(id, 0);
        assertEq(name, "Test Badge");
        assertEq(description, "Test Description");
        (id, name, description) = badge.getBadgeInfo(1);
        assertEq(id, 1);
        assertEq(name, "Test Badge 2");
        assertEq(description, "Test Description 2");
    }
}