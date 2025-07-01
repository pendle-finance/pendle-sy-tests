// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {SYTest} from "../../common/SYTest.t.sol";
import {
    PendleERC4626Scaled18SY,
    IERC4626,
    IERC20Metadata
} from "pendle-sy/core/StandardizedYield/implementations/PendleERC4626Scaled18SY.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";
import {console} from "forge-std/console.sol";

contract Scaled4626Test is SYTest {
    function setUpFork() internal override {
        vm.createSelectFork("arbitrum", 353001197);
    }

    address public constant ERC4626_TOKEN = 0x29cF6e8eCeFb8d3c9dd2b727C1b7d1df1a754F6f;
    address public constant DECIMALS_FACTORY = 0x992EC6A490A4B7f256bd59E63746951D98B29Be9;
    bool public constant IS_REDEEMABLE = false;

    function deploySY() internal override {
        vm.startPrank(deployer);



        sy = IStandardizedYield(
            deployTransparentProxy(
                deployImpl(),
                deployer,
                abi.encodeCall(PendleERC4626Scaled18SY.initialize, ("SY 4626", "SY-4626", deployer))
            )
        );

        vm.stopPrank();
    }

    function deployImpl() internal returns (address) {
        return address(new PendleERC4626Scaled18SY(ERC4626_TOKEN, DECIMALS_FACTORY));
        // address logic2 = address(new PendleERC4626UpgSYV2(ERC4626_TOKEN));
        // return IS_REDEEMABLE ? logic2 : logic1;
    }

    function initializeSY() internal override {
        super.initializeSY();
        startToken = IERC4626(ERC4626_TOKEN).asset();
    }

    function getPreviewTestAllowedDiff() internal pure virtual override returns (uint256) {
        return 1;
    }

    function fundToken(address wallet, address token, uint256 amount) internal override {
        if (token == ERC4626_TOKEN) {
            address asset = IERC4626(token).asset();
            super.fundToken(wallet, asset, amount * 2);

            vm.startPrank(wallet);
            IERC20Metadata(asset).approve(token, type(uint256).max);
            IERC4626(token).deposit(IERC4626(token).convertToAssets(amount), wallet);
            vm.stopPrank();
        } else {
            super.fundToken(wallet, token, amount);
        }
    }
}
