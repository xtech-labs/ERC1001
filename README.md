# ERC1001

ERC1001 developed by [x.tech](https://x.tech) that enhances security and identity based on core technology from ERC-20 along with Smart Contract platform from ERC-1155

# Usage

```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./ERC1001.sol";

contract MyTokenERC1001 is ERC1001 {
    constructor() ERC1001("MyTokenERC1001", "MTK", 18, "https://metadata_url.com/{id}.json") {
        // mint 1,000,000 token to the contract creator
        _mint(msg.sender, 1000000 * 10 ** decimals);

        // mint 1,000,000 NFTs to the contract creator tokenId = 1
        _safeMint(msg.sender, 1, 1000000);
    }
}
```

## What is ERC-1001?
ERC-1001 is a hybrid technology between ERC20 and ERC1155 standards, fostering both enhanced liquidity and robust decentralization for Web3 Domains.

## ERC-1001 technology
A hyper-secure technical standard represents a groundbreaking fusion, empowering NFT with unwavering decentralization.

## X Name Service
XNS is a domain naming system that provides domain registration services to create a readable domain and leads to a certain wallet address.

# Social Links
[![Website](https://img.shields.io/badge/Website-000000?style=for-the-badge&logo=internet-explorer&logoColor=white)](https://x.tech)

[![Discord](https://img.shields.io/badge/Discord-7289DA?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/uMSwamHZwg)

[![Twitter](https://img.shields.io/badge/X-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/xtech_web3)

[![Telegram](https://img.shields.io/badge/Telegram-26A5E4?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/xtech_official)
