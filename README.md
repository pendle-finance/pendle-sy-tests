# Pendle Standardized Yield (SY) Token tests

## Introduction

This repo aims to provide a standard for testing with Pendle's SY tokens, implemented in [Foundry framework](https://book.getfoundry.sh/).

While the provided testcases give a decent overview on your SY token's functionality, passing them does not guarantee your implementation's security. Please always have your code audited by professional security researchers or reviewed by Pendle team otherwise.

## Getting started

### 1. Install Foundry

If already installed, skip this step. Else please visit [Foundry's installation guide](https://book.getfoundry.sh/getting-started/installation.html) to install Foundry.

### 2. Set up the environment

```bash
yarn install
forge install
```

## Writing your implementation

### 1. Writing adapters

Pendle provides a feature to [quickly launch your SY token/market](https://app.pendle.finance/listing) if your yield bearing asset is in one of the three popular standards:

- ERC20
- ERC4626
- ERC4626 not redeemable to asset

In addition to this, we also have a feature called **_adapter_** which allows you to add more input/output tokens to your SY wrapper. Say if your stablecoin is mintable from `USDC/USDT`, your liquid restaking Bitcoin is mintable from `WBTC`, you can implement an adapter to help users utilize this minting route.

An example for adapter is available in `test/sy/adapters/PendleUSDSAdapter.sol` where we launch an ERC20 wrapper for `USDS` with minting available from `DAI`. Please refer to the [Pendle Adapter documentation](https://github.com/pendle-finance/pendle-sy/blob/main/contracts/interfaces/IStandardizedYieldAdapter.sol) for better understanding of the interface.

Once you have implemented your adapter, running test is as short as 10 LOCs. Please check the example [here](./test/sy/usds.t.sol).

### 2. Writing your own SY

If your yield bearing asset is not in the above three standards, you can implement your own SY token. Please refer to examples in [our public sy repository](https://github.com/pendle-finance/Pendle-SY-Public).

## Import your SY

Before testing, you need to import your SY implementation into the testing framework.

### Option 1: Using existing implementation

If your SY implementation is already available, place it in the appropriate directory within the `test/sy/` folder and import it in your test contract.

### Option 2: Flattening your implementation

For better security control, you can flatten your implementation using Foundry's flattening feature:

```bash
forge flatten [YOUR_IMPLEMENTATION_PATH] > flattened_contracts/[YOUR_CONTRACT_NAME].sol
```

Then import the flattened contract in your test file.

## Implement test

There are two main approaches to testing your SY token, depending on whether you're using an adapter or implementing a custom SY.

### 1. Testing Normal SY

For custom SY implementations, extend the `SYTest` contract which includes all standard tests:

```solidity
import {SYTest} from "../common/SYTest.t.sol";
import {YourSYImplementation} from "./YourSYImplementation.sol";

contract YourSYTest is SYTest {
    function setUpFork() internal override {
        // Set up your fork - specify the network and optionally block number
        vm.createSelectFork("ethereum", BLOCK_NUMBER);
        // or simply: vm.createSelectFork("ethereum");
    }

    function deploySY() internal override {
        vm.startPrank(deployer);
        
        // Deploy your SY implementation
        address logic = address(new YourSYImplementation(/* constructor args */));
        sy = IStandardizedYield(
            deployTransparentProxy(logic, deployer, abi.encodeCall(YourSYImplementation.initialize, (/* init args */)))
        );
        
        vm.stopPrank();
    }

    function initializeSY() internal override {
        super.initializeSY();
        
        // Set the starting token for tests
        startToken = address(YOUR_PRIMARY_TOKEN);
        
        // Any additional initialization logic
    }

    function hasFee() internal pure override returns (bool) {
        return false; // set to true if your protocol has mint/redemption fee
    }

    function getPreviewTestAllowedEps() internal pure virtual returns (uint256) {
        // Specify the acceptable error margin (epsilon) for preview calculations,
        // accommodating minor rounding differences in protocols with fees.
        return 1e15; // e.g: 0.001%
    }

    function hasReward() internal pure override returns (bool) {
        return false; // set to true if protocol has reward
    }

    function addFakeRewards() internal override returns (bool[] memory) {
        // This function simulates the accrual of rewards over time for testing purposes.
        // It allows us to test the reward distribution logic without relying on real user activity.
        // By "fast-forwarding" the blockchain state, we can trigger reward calculations
        // as if a significant amount of time has passed.

        // Simulate time passing to accrue rewards
        vm.roll(block.number + 7200); // ~1 day of blocks
        skip(1 days);
        
        // Return which reward tokens have accrued rewards
        return toArray(true, false, true); // First and third reward tokens have rewards
    }
}
```

#### Utility functions

You can override these utility functions:

- `refAmountFor(address token)`: Returns reference amount for testing with specific tokens (default: $10^{18}$ adjusted for decimals)
- `fundToken(address wallet, address token, uint256 amount)`: Custom logic for funding test wallets with tokens (useful for tokens requiring special acquisition methods, such as `stETH`)

**Example overrides**:
```solidity
function refAmountFor(address token) internal view override returns (uint256) {
    if (token == EXPENSIVE_TOKEN) {
        return 1e15; // Use smaller amount for expensive tokens
    }
    return super.refAmountFor(token);
}

function fundToken(address wallet, address token, uint256 amount) internal override {
    if (token == SPECIAL_TOKEN) {
        // Custom funding logic for tokens that can't be dealt
        address whale = 0x123...;
        vm.prank(whale);
        IERC20(token).transfer(wallet, amount);
    } else {
        super.fundToken(wallet, token, amount);
    }
}
```

### 2. Testing SY with Adapter

For the three standard token types (ERC20, ERC4626, ERC4626 non-redeemable), simply copy or modify one of these examples:
- [ERC20 with adapter test](test/sy/adapters-test/nonzero-address/nza-erc20.t.sol)
- [ERC4626 with adapter test](test/sy/adapters-test/nonzero-address/nza-erc4626.t.sol)
- [ERC4626 non-redeemable with adapter test](test/sy/adapters-test/nonzero-address/nza-erc4626-noredeem.t.sol)

## Run the tests

To run the tests, use the following command:

```bash
forge test --match-contract [YOUR_CONTRACT_NAME] -vv
```

## How to analyze test results

The test output contains several `[CHECK REQUIRED]` sections that need manual verification. Here's an example from the hwHLP test.

### 1. Exchange Rate Validation

```
[CHECK REQUIRED] Exchange rate: 1007967000000000000
                 1 SY = 1.007967 asset
```

**What to check**: The exchange rate shows how much underlying asset you get for 1 SY token.

**Examples**:
- For USDS (ERC20): Exchange rate should be exactly 1.0 (1 SY = 1 USDS)
- For hwHLP (yield-bearing): Exchange rate > 1.0 because it accumulates yield over time. Here 1 SY = 1.007967 USDC means the token has earned ~0.8% yield
- For most yield tokens: Rate should be > 1.0 and increase over time

### 2. Metadata Validation

```
Asset type: TOKEN
Asset address: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
Asset symbol: USDC
Asset decimals: 6
Yield token: 0x9FD7466f987Fd4C45a5BBDe22ED8aba5BC8D72d1
Yield token symbol: hwHLP
Yield token decimals: 6

Tokens in: 3
0xdAC17F958D2ee523a2206206994597C13D831ec7 USDT
0x4c9EDD5852cd905f086C759E8383e09bff1E68B3 USDe
0x9FD7466f987Fd4C45a5BBDe22ED8aba5BC8D72d1 hwHLP

Tokens out: 1
0x9FD7466f987Fd4C45a5BBDe22ED8aba5BC8D72d1 hwHLP

Reward tokens: 0
```

**What to check**: 
- **Asset information**: Verify the underlying asset and yield token details match your implementation
- **Token support**: 
  - **Symmetric support**: Same tokens for deposit and withdrawal (e.g., can deposit USDC and withdraw USDC)
  - **Asymmetric support**: Different tokens for deposit and withdrawal (e.g., can deposit USDC/USDT but only withdraw hwHLP)
- **Addresses and symbols**: Confirm all token addresses and symbols match your expectations
- **Reward tokens**: Verify the reward token count matches your implementation (0 if no rewards)

### 3. Preview Test Results

```
[CHECK REQUIRED] Test 1
Testing  USDT => hwHLP
Amount in : 1000000
Amount out: 992040
No round trip possible for this pair

[CHECK REQUIRED] Test 6
Testing  USDe => hwHLP
Amount in : 200000000000000000
Amount out: 198418
No round trip possible for this pair

[CHECK REQUIRED] Test 11
Testing  hwHLP => hwHLP
Amount in : 125000
Amount out: 125000
Amount round trip: 125000
Round trip delta abs: 0
Round trip delta rel: 0
```

**What to check**:
- **Round-trip accuracy**: A round-trip means deposit token A → get SY tokens → redeem SY tokens → get token A back. You should get roughly the same amount back (minus fees).
- **One-way conversions**: Tests showing "No round trip possible" indicate your SY has asymmetric token support (different input/output tokens). This is normal for many protocols.
- **Conversion rates**: Check if conversion amounts make sense given exchange rates, fees, and different token decimals
- **Delta tolerance**: Delta is the difference between what you put in vs what you got back. For round-trip tests, both absolute and relative deltas should be minimal (close to $0$ for fee-free protocols)
  - **Delta = 0**: Perfect! No loss during round-trip  
  - **Small delta**: Acceptable for protocols with fees or rounding
  - **Large delta**: May indicate a problem with your implementation


### 4. Summary Statistics

```
[CHECK REQUIRED] Summary
Total tests                    : 15
Total round trip tests         : 5
Max round trip delta rel       : 0
Average round trip delta rel   : 0
```

**What to check**:
- All tests completed successfully without errors
- **Delta ranges**: 
  - **Max/Average delta = 0**: Excellent! Perfect precision
  - **Max/Average delta < 0.000001**: Very good for most protocols
  - **Max/Average delta > 0.01**: May need investigation (unless your protocol has high fees)
- Maximum and average round trip deltas should be within acceptable bounds (typically smaller than $10^{-6}$ for non-fee protocols)
- Perfect deltas ($0$) indicate high precision, while small non-zero values may be acceptable depending on your protocol's design

### 5. Rewards Validation (if applicable)

For SY tokens with rewards, verify:
- Reward tokens are being distributed correctly
- Claimed amounts match expected values
- All reward tokens are accounted for

<details>
<summary><span style="font-size:1.5em; font-weight:bold;">Test details</span></summary>

The testing framework includes several test suites that validate different aspects of your SY implementation:

### Preview Tests (`test/common/tests/Preview.t.sol`)

**Purpose**: Tests the accuracy of `previewDeposit` and `previewRedeem` functions by performing round-trip conversions between all supported token pairs.

**What it tests**:
- Deposit preview accuracy vs actual deposit results
- Redeem preview accuracy vs actual redeem results  
- Round-trip conversion accuracy ($tokenA → SY → tokenA$)
- Cross-token conversion accuracy ($tokenA → SY → tokenB$)

**Key overrideable functions**:
- `getPreviewTestAllowedDiff()`: Sets acceptable precision loss in wei (default: $0$). Use this if your protocol has small rounding errors.
- `hasFee()`: Indicates if your protocol charges fees (default: $false$). When true, relaxes round-trip accuracy requirements.
- `getTokensInForPreviewTest()`: Customize which input tokens to test (default: all tokens from `getTokensIn()`)
- `getTokensOutForPreviewTest()`: Customize which output tokens to test (default: all tokens from `getTokensOut()`)

### Metadata Tests (`test/common/tests/Metadata.t.sol`)

**Purpose**: Validates SY token metadata and supported token configurations.

**What it tests**:
- Asset information (type, address, decimals)
- Yield token information
- Input/output token lists and validation
- Reward token configuration

### Rewards Tests (`test/common/tests/Rewards.t.sol`)

**Purpose**: Tests reward token claiming functionality for SY tokens.

**What it tests**:
- Reward accrual over time
- Reward claiming accuracy
- Balance updates after claiming

**Key overrideable functions**:
- `hasReward()`: Whether your SY distributes reward tokens (default: $false$). Set to $true$ to enable reward tests.
- `addFakeRewards()`: Simulate reward accrual for testing. Return array indicating which reward tokens have rewards to claim.

**Example implementation**:
```solidity
function hasReward() internal pure override returns (bool) {
    return true; // Enable reward testing
}

function addFakeRewards() internal override returns (bool[] memory) {
    // Simulate time passing to accrue rewards
    vm.roll(block.number + 7200); // ~1 day of blocks
    skip(1 days);
    
    // Return which reward tokens have accrued rewards
    return toArray(true, false, true); // First and third reward tokens have rewards
}
```
</details>