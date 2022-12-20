// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {INFTNameGenDrop} from "../interfaces/INFTNameGenDrop.sol";

contract NFTNameGenDropStorageV1 {
    /// @notice Configuration for NFT minting contract storage
    INFTNameGenDrop.Configuration public config;

    /// @notice Sales configuration
    INFTNameGenDrop.ERC20SalesConfiguration public salesConfig;

    /// @dev Mapping for presale mint counts by address to allow public mint limit
    mapping(address => uint256) public presaleMintsByAddress;
}
