// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console} from "forge-std/console.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";
import {PendleKinetiqVKHYPESY} from "pendle-sy/core/StandardizedYield/implementations/Kinetiq/PendleKinetiqVKHYPESY.sol";
import {IVedaTeller} from "pendle-sy/interfaces/EtherFi/IVedaTeller.sol";
import {IVedaAccountant} from "pendle-sy/interfaces/EtherFi/IVedaAccountant.sol";
import "../../common/SYTest.t.sol";
import "pendle-sy/interfaces/IPTokenWithSupplyCap.sol";

interface Teller {
    function setDepositCap(uint112 cap) external;
}

contract PendleKinetiqVKHYPESYTest is SYTest {
    address PROXY_ADMIN = 0xA28c08f165116587D4F3E708743B4dEe155c5E64;

    address teller = 0x29C0C36eD3788F1549b6a1fd78F40c51F0f73158;
    address teller_authority = 0x345BB6a4249419e34a7C750B90178Fc7B2e4c50f;
    address accountant = 0x74392Fa56405081d5C7D93882856c245387Cece2;

    address public constant vkHYPE = 0x9BA2EDc44E0A4632EB4723E81d4142353e1bB160;
    address public constant WHYPE = 0x5555555555555555555555555555555555555555;
    address public constant KHYPE = 0xfD739d4e423301CE9385c1fb8850539D657C296D;

    function setUpFork() internal override {
        vm.createSelectFork("https://rpc.hyperliquid.xyz/evm");
    }

    function deploySY() internal override {
        vm.startPrank(deployer);

        sy = IStandardizedYield(deployTransparentProxy(
            address(new PendleKinetiqVKHYPESY()),
            PROXY_ADMIN,
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

    function test_cap_yieldToken() external {
        deal(vkHYPE, deployer, 1e18 + 1);
        uint256 currentTotalSupply = IPTokenWithSupplyCap(address(sy)).getAbsoluteTotalSupply();
        uint256 fakeCap = currentTotalSupply + 1e18;

        vm.mockCall(
            teller,
            abi.encodeWithSignature(
                "depositCap()"
            ),
            abi.encode(currentTotalSupply + fakeCap)
        );

        deposit(deployer, vkHYPE, 1e18 + 1);
    }

    function test_cap_asset_revertPreviewDeposit() external {
        address tokenIn = KHYPE;
        uint256 amountIn = 10 ** 18;
        deal(tokenIn, deployer, amountIn);
        uint256 currentTotalSupply = IPTokenWithSupplyCap(address(sy)).getAbsoluteTotalSupply();
        uint256 fakeCap = currentTotalSupply + amountIn * (10 ** 18) / IVedaAccountant(accountant).getRateInQuoteSafe(tokenIn) - 1;

        vm.mockCall(
            teller,
            abi.encodeWithSignature(
                "depositCap()"
            ),
            abi.encode(fakeCap)
        );  

        uint256 newSupply = currentTotalSupply + amountIn * (10 ** 18) / IVedaAccountant(accountant).getRateInQuoteSafe(tokenIn);

        vm.expectRevert(abi.encodeWithSelector(PendleKinetiqVKHYPESY.SupplyCapExceeded.selector, newSupply, fakeCap));
        sy.previewDeposit(tokenIn, amountIn);
    }

    function test_cap_asset_revertDeposit() external {
        address tokenIn = KHYPE;
        uint256 amountIn = 10 ** 18;
        deal(tokenIn, deployer, amountIn);
        uint256 currentTotalSupply = IPTokenWithSupplyCap(address(sy)).getAbsoluteTotalSupply();
        uint256 fakeCap = currentTotalSupply + amountIn * (10 ** 18) / IVedaAccountant(accountant).getRateInQuoteSafe(tokenIn) - 1;

        vm.mockCall(
            teller,
            abi.encodeWithSignature(
                "depositCap()"
            ),
            abi.encode(fakeCap)
        );

        vm.prank(address(0));
        Teller(teller).setDepositCap(uint112(fakeCap));

        vm.startPrank(deployer);
        safeApprove(tokenIn, address(sy), amountIn);

        vm.expectRevert(bytes4(0xed32f3bb)); // TellerWithMultiAssetSupport__DepositExceedsCap(); 
        sy.deposit(deployer, tokenIn, amountIn, 0);
    }
}