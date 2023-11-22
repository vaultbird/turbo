// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.23;

/// @dev Interface of the HOP Liquidity Pool
interface IPool {
  function addLiquidity(
    uint256[] calldata amounts,
    uint256 minToMint,
    uint256 deadline
  ) external returns (uint256);
}
