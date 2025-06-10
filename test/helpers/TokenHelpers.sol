// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {IERC20, IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {console, StdCheats} from "forge-std/Test.sol";

abstract contract TokenHelpers is StdCheats {
    address internal constant NATIVE = address(0);

    function getSymbol(address token) internal view virtual returns (string memory) {
        if (token == NATIVE) {
            return "NATIVE";
        } else {
            return IERC20Metadata(token).symbol();
        }
    }

    function getDecimals(address token) internal view virtual returns (uint8) {
        if (token == NATIVE) {
            return 18;
        } else {
            return IERC20Metadata(token).decimals();
        }
    }

    function printTokenSymbols(address[] memory tokens) internal view virtual {
        for (uint256 i = 0; i < tokens.length; i++) {
            console.log(tokens[i], getSymbol(tokens[i]));
        }
    }

    function getBalance(address wallet, address token) internal view virtual returns (uint256) {
        if (token == NATIVE) {
            return wallet.balance;
        } else {
            return IERC20(token).balanceOf(wallet);
        }
    }

    function getBalances(
        address wallet,
        address[] memory tokens
    ) internal view virtual returns (uint256[] memory balances) {
        balances = new uint256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            balances[i] = getBalance(wallet, tokens[i]);
        }
    }

    function fundToken(address wallet, address token, uint256 amount) internal virtual {
        if (token == NATIVE) {
            deal(wallet, amount);
        } else {
            deal(token, wallet, amount, false);
        }
    }
}
