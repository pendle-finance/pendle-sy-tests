// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {SYTest} from "../common/SYTest.t.sol";
import {
    PendleYearnBalancerLPSY,
    IERC4626,
    PendleERC4626UpgSYV2
} from "pendle-sy/core/StandardizedYield/implementations/Yearn/PendleYearnBalancerLPSY.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";
import {console} from "forge-std/console.sol";

contract YearnBPTTest is SYTest {
    function setUpFork() internal override {
        vm.createSelectFork("ethereum");
    }

    address public constant ERC4626_TOKEN = 0xC0C31393C0B406C9cCfDBFb772202ce3A7cb667E;
    address public immutable BPT = 0x6c5972311191097D002E804A9Bf97C96C54059ed;

    function deploySY() internal override {
        vm.startPrank(deployer);

        address logic = address(new PendleYearnBalancerLPSY(ERC4626_TOKEN));
        sy = IStandardizedYield(
            deployTransparentProxy(
                logic,
                deployer,
                abi.encodeCall(PendleERC4626UpgSYV2.initialize, ("SY Yearn BPT", "SY-yBPT"))
            )
        );

        vm.stopPrank();
    }

    function initializeSY() internal override {
        super.initializeSY();
        startToken = IERC4626(ERC4626_TOKEN).asset();
    }

    function refAmountFor(address token) internal view override returns (uint256) {
        if (token == BPT) {
            return 1e18; // BPT has 18 decimals
        } else {
            return super.refAmountFor(token);
        }
    }

    function fundToken(address wallet, address token, uint256 amount) internal override {
        if (token == BPT) {
            console.log("funding");
            super.fundToken(wallet, ERC4626_TOKEN, amount);
            vm.startPrank(wallet);
            console.log("redeeming", amount);
            IERC4626(ERC4626_TOKEN).redeem(
                amount,
                wallet,
                wallet
            );
            console.log("redeemed");
            vm.stopPrank();
            console.log("funded"); 
        } else {
            super.fundToken(wallet, token, amount);
        }
    }
}
