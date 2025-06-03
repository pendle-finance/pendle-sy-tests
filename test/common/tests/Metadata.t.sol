// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {console} from "forge-std/Test.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";

import {TestFoundation} from "../TestFoundation.sol";

abstract contract MetadataTest is TestFoundation {
    function test_metadata_assetInfo() public view {
        (IStandardizedYield.AssetType assetType, address assetAddress, uint8 assetDecimals) = sy.assetInfo();

        if (assetType == IStandardizedYield.AssetType.TOKEN) {
            console.log("Asset type: TOKEN");
        } else if (assetType == IStandardizedYield.AssetType.LIQUIDITY) {
            console.log("Asset type: LIQUIDITY");
        } else {
            assert(false);
        }
        console.log("Asset address:", assetAddress);

        if (assetAddress == address(0)) {
            console.log("Asset symbol: ETH");
        } else if (assetAddress == address(1)) {
            console.log("Asset symbol: Wrapped");
        } else {
            console.log("Asset symbol:", assetAddress);
        }
        console.log("Asset decimals:", assetDecimals);

        address yieldToken = sy.yieldToken();
        console.log("Yield token:", yieldToken);
        console.log("Yield token symbol:", getSymbol(yieldToken));
        console.log("Yield token decimals:", getDecimals(yieldToken));
    }

    function test_metadata_getTokensIn() public view {
        address[] memory tokens = sy.getTokensIn();
        console.log("Tokens in:", tokens.length);
        printTokenSymbols(tokens);
    }

    function test_metadata_getTokensOut() public view {
        address[] memory tokens = sy.getTokensOut();
        console.log("Tokens out:", tokens.length);
        printTokenSymbols(tokens);
    }

    function test_metadata_getRewardTokens() public view {
        address[] memory tokens = sy.getRewardTokens();
        console.log("Reward tokens:", tokens.length);
        printTokenSymbols(tokens);
    }

    function test_metadata_isValidTokenIn() public view {
        address[] memory tokens = sy.getTokensIn();
        for (uint256 i = 0; i < tokens.length; ++i) {
            assertTrue(sy.isValidTokenIn(tokens[i]));
        }
        assertFalse(sy.isValidTokenIn(vm.addr(123456)));
    }

    function test_metadata_isValidTokenOut() public view {
        address[] memory tokens = sy.getTokensOut();
        for (uint256 i = 0; i < tokens.length; ++i) {
            assertTrue(sy.isValidTokenOut(tokens[i]));
        }
        assertFalse(sy.isValidTokenOut(vm.addr(123456)));
    }
}
