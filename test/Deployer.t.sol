// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {Deployer} from "../script/Deployer.s.sol";

contract DeployerTest is Test {
    Deployer deployer;

    function testDeploy() public {
        deployer = new Deployer();
        deployer.run();
    }
}
