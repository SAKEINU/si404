# SAKEINU

**SAKEINU is just a drunk dawg with sake, tryin’ to escape from fucked up life for dog’s sake.**  


## Introduction

Welcome to SAKEINU (SI404), where the digital currency meets drunken fun in a memecoin form.  

SI404 extends beyond traditional crypto projects by blending in fun with functionality, creating a vibrant community and an engaging user experience.  

This project extends ERC404 by integrating overridable base units. For the base implementation of ERC404, see [ERC404 repository](https://github.com/Pandora-Labs-Org/erc404).

## Features
- 100,000 tokens are combined with 1 NFT.
- Transfers on one side will be reflected on the other side.

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Deploy

```shell
$ forge script script/SI404.s.sol:SI404Script --rpc-url <your_rpc_url> --private-key <your_private_key> --sig "run(address,address)" -- <owner> <initialMinter>
```

## Safety
SAKEINU is experimental software provided "as is" and "as available," without warranties of any kind. Use of this software could result in risks including, but not limited to, financial loss. Users should proceed with caution.

Despite extensive testing of SI404, emergent behavior or incompatibilities with future versions of Solidity may occur. We strongly recommend conducting comprehensive tests to ensure compatibility and functionality with your specific implementations.
