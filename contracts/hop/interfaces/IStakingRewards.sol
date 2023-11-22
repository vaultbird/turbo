// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.23;

/// @dev Interface of the HOP Staking Rewards
interface IStakingRewards {
  function balanceOf(address account) external view returns (uint256);

  function stake(uint256 amount) external;

  function withdraw(uint256 amount) external;

  function getReward() external;

  function exit() external;
}
