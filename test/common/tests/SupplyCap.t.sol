// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {console} from "forge-std/Test.sol";

import {TestFoundation} from "../TestFoundation.sol";
import {TokenWithSupplyCapUpg} from "pendle-sy/core/misc/TokenWithSupplyCapUpg.sol";
import {IERC20, IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

abstract contract SupplyCapTest is TestFoundation {
    using SafeERC20 for IERC20;

    function test_supply_cap() public {
        vm.skip(!hasSupplyCap());

        console.log("[-----test_supply_cap-----]");

        // Set supply cap to 1
        vm.prank(TokenWithSupplyCapUpg(address(sy)).owner());
        TokenWithSupplyCapUpg(address(sy)).updateSupplyCap(1);

        // try minting
        address alice = wallets[0];
        uint256 refAmount = refAmountFor(startToken);
        fundToken(alice, startToken, refAmount);

        vm.startPrank(alice);

        console.logBytes4(TokenWithSupplyCapUpg.SupplyCapExceeded.selector);

        if (startToken == address(0)) {
            vm.expectPartialRevert(TokenWithSupplyCapUpg.SupplyCapExceeded.selector);
            sy.deposit{value: refAmount}(alice, startToken, refAmount, 0);
        } else {
            safeApprove(startToken, address(sy), 0);
            safeApprove(startToken, address(sy), refAmount);

            vm.expectPartialRevert(TokenWithSupplyCapUpg.SupplyCapExceeded.selector);
            sy.deposit(alice, startToken, refAmount, 0);
        }
        vm.stopPrank();
    }

    function hasSupplyCap() internal pure virtual returns (bool) {
        return false;
    }
}
