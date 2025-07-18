// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {IERC20, IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";
import {ArrayHelpers} from "../helpers/ArrayHelpers.sol";
import {DeployHelpers} from "../helpers/DeployHelpers.sol";
import {TokenHelpers} from "../helpers/TokenHelpers.sol";
import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {console} from "forge-std/console.sol";
import {StdStyle} from "forge-std/StdStyle.sol";

abstract contract TestFoundation is ArrayHelpers, DeployHelpers, TokenHelpers, Test {
    using StdStyle for string;

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

    function initializeSY() internal virtual {}

    function test_exchangeRateSanity() public view {
        uint256 exchangeRate = sy.exchangeRate();
        
        
        uint256 decimalsSY = IERC20Metadata(address(sy)).decimals();
        (,,uint8 decimalsAsset) = sy.assetInfo();

        uint256 amtAsset = (10 ** decimalsSY) * sy.exchangeRate() / (10 ** 18);
        uint256 amtAsset18 = amtAsset;
        if (decimalsAsset < 18) {
            amtAsset18 = amtAsset * (10 ** (18 - decimalsAsset));
        } else if (decimalsAsset > 18) {
            amtAsset18 = amtAsset / (10 ** (decimalsAsset - 18));
        }
        
        checkRequired(string.concat("Exchange rate: ", vm.toString(exchangeRate)));
        console.log("                 1 SY = %18e asset", amtAsset18);


        assertGt(exchangeRate, 0, "Exchange rate should be greater than 0");
    }

    function refAmountFor(address token) internal view virtual returns (uint256) {
        if (token == NATIVE) {
            return 1 ether;
        } else {
            return 10 ** IERC20Metadata(token).decimals();
        }
    }

    function upgradeExistingProxy(address proxy, address newImplementation, bytes memory data) internal virtual {
        vm.startPrank(0xA28c08f165116587D4F3E708743B4dEe155c5E64);
        ITransparentUpgradeableProxy(proxy).upgradeToAndCall(newImplementation, data);
        vm.stopPrank();
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
            vm.startPrank(wallet);
            safeApprove(tokenIn, address(sy), 0);
            safeApprove(tokenIn, address(sy), amountTokenIn);
            amountSharesOut = sy.deposit(wallet, tokenIn, amountTokenIn, 0);
            vm.stopPrank();
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

    function checkRequired(string memory message) internal pure {
        console.log(string.concat(string("[CHECK REQUIRED]").red().bold(), " ", message));
    }
}
