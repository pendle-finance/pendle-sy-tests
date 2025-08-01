// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2 as console} from "forge-std/Test.sol";
import {PendleExternalCapGates} from "pendle-sy/core/misc/PendleExternalCapGates.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";
import {IPTokenWithSupplyCap} from "pendle-sy/interfaces/IPTokenWithSupplyCap.sol";
import {DeployHelpers} from "../../helpers/DeployHelpers.sol";

abstract contract ExternalCapGatesTest is Test, DeployHelpers {
    address public constant PROXY_ADMIN = 0xA28c08f165116587D4F3E708743B4dEe155c5E64;
    address deployer;

    IStandardizedYield sy;
    IPTokenWithSupplyCap externalCap;
    PendleExternalCapGates externalCapGates;

    function setUp() public {
        deployer = makeAddr("deployer");

        setUpFork();

        vm.startPrank(deployer);
        externalCapGates = PendleExternalCapGates(
            deployTransparentProxy(
                address(new PendleExternalCapGates()),
                0xA28c08f165116587D4F3E708743B4dEe155c5E64,
                abi.encodeCall(PendleExternalCapGates.initialize, (deployer))
            )
        );
        setUpSYExternalCap();
        vm.stopPrank();
    }

    function setUpFork() internal virtual;
    function setUpSYExternalCap() internal virtual;

    function test_externalCap_absoluteSupplyCap_success() public view {
        console.log("Absolute Supply Cap: %d", externalCapGates.getAbsoluteSupplyCap(address(sy)));
        assertEq(externalCapGates.getAbsoluteSupplyCap(address(sy)), externalCap.getAbsoluteSupplyCap());
    }

    function test_externalCap_absoluteTotalSupply_success() public view {
        console.log("Absolute Supply Cap: %d", externalCapGates.getAbsoluteTotalSupply(address(sy)));
        assertEq(externalCapGates.getAbsoluteTotalSupply(address(sy)), externalCap.getAbsoluteTotalSupply());
    }

    function test_externalCap_setInGate() public view {
        assertEq(externalCapGates.externalCapContracts(address(sy)), address(externalCap));
    }
}
