// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.23;

import {ERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {Ownable, Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

/**
 * @title Vaultbird Turbo
 * @author sepyke.eth
 * @dev Simple, efficient & secure auto-compounder
 * @custom:contact security@vaultbird.com
 */
contract VaultbirdTurbo is ERC4626, Ownable2Step {
  struct Config {
    string name;
    string symbol;
    IERC20 asset;
    IERC20 rewards;
    IERC20 native;
    address admin;
    address treasury;
    address feeDistributor;
    address strategist;
    uint256 reinvestMinAmount;
    uint256 reinvestFeeBps;
    uint256 reinvestFeeTreasuryBps;
    uint256 reinvestFeeDistributorBps;
    uint256 reinvestFeeStrategistBps;
    uint256 reinvestFeeCallerBps;
  }

  IERC20 public rewards;
  IERC20 public native;

  address public treasury;
  address public feeDistributor;
  address public strategist;

  uint256 private constant BPS_SCALE = 1e4;
  uint256 public constant MAX_FEE_BPS = 1000; // 10%
  uint256 public reinvestMinAmount;
  uint256 public reinvestFeeBps;
  uint256 public reinvestFeeTreasuryBps;
  uint256 public reinvestFeeDistributorBps;
  uint256 public reinvestFeeStrategistBps;
  uint256 public reinvestFeeCallerBps;

  error InvalidTreasuryAddress();
  error InvalidFeeDistributorAddress();
  error InvalidStrategistAddress();
  error InvalidReinvestFeeBps();
  error InvalidReinvestFeeDistribution();

  event TreasuryAddressUpdated(address);
  event FeeDistributorAddressUpdated(address);
  event StrategistAddressUpdated(address);
  event ReinvestMinAmountUpdated(uint256);
  event ReinvestFeeBpsUpdated(uint256);
  event ReinvestFeeDistributionUpdated(uint256 treasury, uint256 feeDistributor, uint256 strategist, uint256 caller);

  constructor(Config memory c) Ownable(msg.sender) ERC20(c.name, c.symbol) ERC4626(c.asset) {
    rewards = c.rewards;
    native = c.native;

    setTreasury(c.treasury);
    setFeeDistributor(c.feeDistributor);
    setStrategist(c.strategist);
    setReinvestMinAmount(c.reinvestMinAmount);
    setReinvestFeeBps(c.reinvestFeeBps);
    setReinvestFeeDistribution(c.reinvestFeeTreasuryBps, c.reinvestFeeDistributorBps, c.reinvestFeeStrategistBps, c.reinvestFeeCallerBps);

    _transferOwnership(c.admin);
  }

  function setTreasury(address treasury_) public onlyOwner {
    if (treasury_ == address(0)) revert InvalidTreasuryAddress();
    treasury = treasury_;
    emit TreasuryAddressUpdated(treasury_);
  }

  function setFeeDistributor(address feeDistributor_) public onlyOwner {
    if (feeDistributor_ == address(0)) revert InvalidFeeDistributorAddress();
    feeDistributor = feeDistributor_;
    emit FeeDistributorAddressUpdated(feeDistributor_);
  }

  function setStrategist(address strategist_) public onlyOwner {
    if (strategist_ == address(0)) revert InvalidStrategistAddress();
    strategist = strategist_;
    emit StrategistAddressUpdated(strategist_);
  }

  function setReinvestMinAmount(uint256 amount_) public onlyOwner {
    reinvestMinAmount = amount_;
    emit ReinvestMinAmountUpdated(amount_);
  }

  function setReinvestFeeBps(uint256 bps_) public onlyOwner {
    if (bps_ > MAX_FEE_BPS) revert InvalidReinvestFeeBps();
    reinvestFeeBps = bps_;
    emit ReinvestFeeBpsUpdated(bps_);
  }

  function setReinvestFeeDistribution(uint256 treasury_, uint256 feeDistributor_, uint256 strategist_, uint256 caller_) public onlyOwner {
    uint256 total = treasury_ + feeDistributor_ + strategist_ + caller_;
    if (total != BPS_SCALE) revert InvalidReinvestFeeDistribution();
    reinvestFeeTreasuryBps = treasury_;
    reinvestFeeDistributorBps = feeDistributor_;
    reinvestFeeStrategistBps = strategist_;
    reinvestFeeCallerBps = caller_;
    emit ReinvestFeeDistributionUpdated(treasury_, feeDistributor_, strategist_, caller_);
  }
}
