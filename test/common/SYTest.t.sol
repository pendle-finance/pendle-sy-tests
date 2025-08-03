// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {DepositRedeemTest} from "./tests/DepositRedeem.t.sol";
import {MetadataTest} from "./tests/Metadata.t.sol";
import {PreviewTest} from "./tests/Preview.t.sol";
import {RewardsTest} from "./tests/Rewards.t.sol";
import {SupplyCapTest} from "./tests/SupplyCap.t.sol";
import {ExchangeRateTest} from "./tests/ExchangeRate.t.sol";

abstract contract SYTest is DepositRedeemTest, MetadataTest, PreviewTest, RewardsTest, SupplyCapTest, ExchangeRateTest {}
