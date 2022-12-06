// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IAllowListDrop} from "../interfaces/IAllowListDrop.sol";

contract AllowListDropStorageV1 {
    /// @notice Configuration for NFT minting contract storage
    IAllowListDrop.Configuration public config;

    /// @notice Sales configuration
    IAllowListDrop.ERC20SalesConfiguration public salesConfig;

    /// @dev Mapping for presale mint counts by address to allow public mint limit
    mapping(address => uint256) public presaleMintsByAddress;
}
