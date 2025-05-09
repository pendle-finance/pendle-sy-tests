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

An example for adapter is available in `test/sy/adapters/PendleUSDSAdapter.sol` where we launch an ERC20 wrapper for `USDS` with minting available from `DAI`. Please refer to the [Pendle Adapter documentation](./lib/pendle-sy/contracts/interfaces/IStandardizedYieldAdapter.sol) for better understanding of the interface.

Once you have implemented your adapter, running test is as short as 10 LOCs. Please check the example [here](./test/sy/usds.t.sol).

### 2. Writing your own SY

If your yield bearing asset is not in the above three standards, you can implement your own SY token. Please refer to examples in [our public sy repository](https://github.com/pendle-finance/Pendle-SY-Public).

## Deploy your implementation

For your own safety, we recommend you to move the tested implementation to your preferred place where you have better control over its security. To make this easier, you can use Foundry's flattening feature:

```bash
forge flatten [YOUR_IMPLEMENTATION_PATH] > flattened_contracts/[YOUR_CONTRACT_NAME].sol
```
