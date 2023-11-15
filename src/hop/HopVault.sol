// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "src/Vault.sol";
import "./interfaces/IStakingRewards.sol";
import "./interfaces/IPool.sol";

/**
 * @title HopVault
 * @author sepyke.eth
 * @notice HOP LP token auto-compounder
 */
contract HopVault is Vault {
  using SafeERC20 for IERC20;

  IStakingRewards public staking;
  IPool public pool;

  constructor(Config memory c, IStakingRewards s, IPool p) Vault(c) {
    staking = s;
    pool = p;
  }

  function totalAssets() public view virtual override returns (uint256) {
    return staking.balanceOf(address(this));
  }

  function _invest(uint256 amount) internal override {
    IERC20(asset()).safeIncreaseAllowance(address(staking), amount);
    staking.stake(amount);
  }

  function _reinvest(uint256 minAmount) internal override {
    staking.getReward();
    uint256 rewardAmount = rewards.balanceOf(address(this));
    if (rewardAmount < minAmount) return;
    // get fees
    uint256 feeAmount = _getFeeAmount(rewardAmount);
    uint256 reinvestedAmount = rewardAmount - feeAmount;
    _swapRewardsToNative(feeAmount);
    _distributeFees(feeAmount);
    // swap amount hop to
    // calculate fees
    // reinvestAmount, feeAmount
    // reinvestAmount -> depositAmount
    //
  }

  function _swapRewardsToNative(
    uint256 amount
  ) internal override returns (uint256) {
    // gimana cara swap HOP ke WETH
    return 0;
  }

  // TODO(pyk): implement reinvest
}
