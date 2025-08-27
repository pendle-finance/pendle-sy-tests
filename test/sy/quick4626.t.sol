// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {SYTest} from "../common/SYTest.t.sol";
import {
    PendleERC4626UpgSYV2,
    IERC4626
} from "pendle-sy/core/StandardizedYield/implementations/PendleERC4626UpgSYV2.sol";
import {
    PendleERC4626NoRedeemUpgSY
} from "pendle-sy/core/StandardizedYield/implementations/PendleERC4626NoRedeemUpgSY.sol";
import {PendleDoubleERC4626SY} from "pendle-sy/core/StandardizedYield/implementations/PendleDoubleERC4626SY.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";

contract Quick4626Test is SYTest {
    function setUpFork() internal override {
        vm.createSelectFork("berachain", 9139201);
    }

    enum Type4626 {
        ERC4626,
        ERC4626NoRedeem,
        ERC4626Double
    }

    address public constant ERC4626_TOKEN = 0x1d22592F66Fc92e0a64eE9300eAeca548cd466c5;
    Type4626 public constant ERC4626_TYPE = Type4626.ERC4626Double;

    function deploySY() internal override {
        vm.startPrank(deployer);

        (address logic, bytes memory initData) = deployImpl();

        sy = IStandardizedYield(deployTransparentProxy(logic, deployer, initData));

        vm.stopPrank();
    }

    function deployImpl() internal returns (address, bytes memory) {
        if (ERC4626_TYPE == Type4626.ERC4626) {
            return (
                address(new PendleERC4626UpgSYV2(ERC4626_TOKEN)),
                abi.encodeWithSelector(PendleERC4626UpgSYV2.initialize.selector, "SY 4626", "SY-4626")
            );
        } else if (ERC4626_TYPE == Type4626.ERC4626NoRedeem) {
            return (
                address(new PendleERC4626NoRedeemUpgSY(ERC4626_TOKEN)),
                abi.encodeWithSelector(
                    PendleERC4626NoRedeemUpgSY.initialize.selector,
                    "SY 4626 No Redeem",
                    "SY-4626-NO-REDEEM"
                )
            );
        } else if (ERC4626_TYPE == Type4626.ERC4626Double) {
            return (
                address(new PendleDoubleERC4626SY(ERC4626_TOKEN)),
                abi.encodeWithSelector(
                    PendleDoubleERC4626SY.initialize.selector,
                    "SY 4626 Double",
                    "SY-4626-DOUBLE",
                    deployer
                )
            );
        } else {
            revert("Unsupported Type4626");
        }
    }

    function initializeSY() internal override {
        super.initializeSY();
        startToken = IERC4626(ERC4626_TOKEN).asset();
    }

    function hasFee() internal pure override returns (bool) {
        return true;
    }
}
