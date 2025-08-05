// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console} from "forge-std/console.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";
import {PendleKinetiqVKHYPESY} from "pendle-sy/core/StandardizedYield/implementations/Kinetiq/PendleKinetiqVKHYPESY.sol";
import {IVedaTeller} from "pendle-sy/interfaces/EtherFi/IVedaTeller.sol";
import "../../common/SYTest.t.sol";
import "pendle-sy/interfaces/IPTokenWithSupplyCap.sol";

contract PendleKinetiqVKHYPESYTest is SYTest {
    address teller_authority = 0x345BB6a4249419e34a7C750B90178Fc7B2e4c50f;

    function setUpFork() internal override {
        vm.createSelectFork("https://rpc.hyperliquid.xyz/evm");
    }

    function deploySY() internal override {
        vm.startPrank(deployer);

        sy = IStandardizedYield(deployTransparentProxy(
            address(new PendleKinetiqVKHYPESY()),
            deployer,
            abi.encodeCall(PendleKinetiqVKHYPESY.initialize, ("SY Kinetiq vkHYPE", "SY-vkHYPE", deployer))
        ));

        vm.stopPrank();
    }

    function initializeSY() internal override {
        vm.mockCall(
            teller_authority, 
            abi.encodeWithSignature(
                "canCall(address,address,bytes4)",
                address(sy),
                PendleKinetiqVKHYPESY(payable(address(sy))).teller(),
                IVedaTeller.bulkDeposit.selector
            ),
            abi.encode(true)
        );
    }

    function test_info_supply_cap() external view {
        console.log("Absolute Supply Cap: %18e", IPTokenWithSupplyCap(address(sy)).getAbsoluteSupplyCap());
        console.log("Absolute Total Supply: %18e", IPTokenWithSupplyCap(address(sy)).getAbsoluteTotalSupply());
    }
}