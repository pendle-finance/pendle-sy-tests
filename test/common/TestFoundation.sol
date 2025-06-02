// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {IERC20, IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";
import {ArrayHelpers} from "../helpers/ArrayHelpers.sol";
import {DeployHelpers} from "../helpers/DeployHelpers.sol";
import {TokenHelpers} from "../helpers/TokenHelpers.sol";
import {IEtherFiLiquidityPool} from "pendle-sy/interfaces/EtherFi/IEtherFiLiquidityPool.sol";

abstract contract TestFoundation is ArrayHelpers, DeployHelpers, TokenHelpers, Test {
    address deployer;
    address[] wallets;

    IStandardizedYield sy;
    address startToken;

    function setUp() public virtual {
        deployer = makeAddr("deployer");

        wallets.push(makeAddr("alice"));
        wallets.push(makeAddr("bob"));
        wallets.push(makeAddr("charlie"));
        wallets.push(makeAddr("david"));
        wallets.push(makeAddr("eve"));

        setUpFork();
        deploySY();
        initializeSY();
    }

    function setUpFork() internal virtual;

    function deploySY() internal virtual;

    function initializeSY() internal virtual {
        console.log("[-----initializeSY-----]");
        console.log("[CHECK REQUIRED] Exchange rate after deployment:", sy.exchangeRate());
        console.log("");
    }

    function refAmountFor(address token) internal view virtual returns (uint256) {
        if (token == NATIVE) {
            return 1 ether;
        } else {
            return 10 ** IERC20Metadata(token).decimals();
        }
    }

    function deposit(
        address wallet,
        address tokenIn,
        uint256 amountTokenIn
    ) internal virtual returns (uint256 amountSharesOut) {
        if (tokenIn == NATIVE) {
            vm.prank(wallet);
            amountSharesOut = sy.deposit{value: amountTokenIn}(wallet, tokenIn, amountTokenIn, 0);
        } else {
            vm.prank(wallet);
            IERC20(tokenIn).approve(address(sy), amountTokenIn);

            vm.prank(wallet);
            amountSharesOut = sy.deposit(wallet, tokenIn, amountTokenIn, 0);
        }
    }

    function redeem(
        address wallet,
        address tokenOut,
        uint256 amountSharesIn
    ) internal virtual returns (uint256 amountTokenOut) {
        vm.prank(wallet);
        amountTokenOut = sy.redeem(wallet, amountSharesIn, tokenOut, 0, false);
    }


    function fundToken(address wallet, address token, uint256 amount) internal virtual {
        if (token == 0x35fA164735182de50811E8e2E824cFb9B6118ac2) {
            vm.prank(wallet);
            deal(wallet, amount);
            IEtherFiLiquidityPool(0x308861A430be4cce5502d0A12724771Fc6DaF216).deposit{value: amount}(address(1));
            vm.stopPrank();
        } else if (token == NATIVE) {
            deal(wallet, amount);
        } else {
            deal(token, wallet, amount);
        }
    }
}
