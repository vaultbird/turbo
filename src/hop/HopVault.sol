// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {Vault} from "../Vault.sol";
import {IStakingRewards} from "./interfaces/IStakingRewards.sol";
import {IPool} from "./interfaces/IPool.sol";

/**
 * @title HopVault
 * @author sepyke.eth
 * @notice HOP LP token auto-compounder
 */
contract HopVault is Vault {
  using SafeERC20 for IERC20;

  struct Config {
    IERC20 rewards;
    IStakingRewards staking;
    IPool pool;
  }

  Config private _config;

  constructor(
    GlobalConfig memory g,
    BPS memory b,
    Recipients memory r,
    Config memory c
  ) Vault(g, b, r) {
    _config = c;
  }

  function _stake(uint256 amount) internal {
    IERC20(asset()).safeIncreaseAllowance(address(_config.staking), amount);
    _config.staking.stake(amount);
  }

  function _deposit(
    address caller,
    address receiver,
    uint256 assets,
    uint256 shares
  ) internal virtual override {
    // TODO(pyk): add reinvest here
    super._deposit(caller, receiver, assets, shares);
    _stake(assets);
  }

  function totalAssets() public view virtual override returns (uint256) {
    return _config.staking.balanceOf(address(this));
  }

  function _reinvest() internal {
    _config.staking.getReward();
    uint256 amount = _config.rewards.balanceOf(address(this));
    if (amount == 0) return;
    // swap amount hop to
    // calculate fees
    // reinvestAmount, feeAmount
    // reinvestAmount -> depositAmount
    //
  }

  // TODO(pyk): implement reinvest
}
