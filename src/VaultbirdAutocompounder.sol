// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Vaultbird Autocompounder
 * @author sepyke.eth
 * @dev Simple & secure auto-compounder
 * @custom:contact security@vaultbird.com
 */
contract VaultbirdAutocompounder is ERC4626, Ownable {
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

  uint256 private BPS_SCALE = 1e4;
  uint256 public MAX_FEE_BPS = 1000; // 10%
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
  event ReinvestFeeDistributionUpdated(
    uint256 treasury,
    uint256 feeDistributor,
    uint256 strategist,
    uint256 caller
  );

  constructor(
    Config memory c
  ) Ownable(msg.sender) ERC20(c.name, c.symbol) ERC4626(c.asset) {
    rewards = c.rewards;
    native = c.native;

    setTreasury(c.treasury);
    setFeeDistributor(c.feeDistributor);
    setStrategist(c.strategist);
    setReinvestMinAmount(c.reinvestMinAmount);
    setReinvestFeeBps(c.reinvestFeeBps);
    setReinvestFeeDistribution(
      c.reinvestFeeTreasuryBps,
      c.reinvestFeeDistributorBps,
      c.reinvestFeeStrategistBps,
      c.reinvestFeeCallerBps
    );

    transferOwnership(c.admin);
  }

  function setTreasury(address t) public onlyOwner {
    if (t == address(0)) revert InvalidTreasuryAddress();
    treasury = t;
    emit TreasuryAddressUpdated(t);
  }

  function setFeeDistributor(address fd) public onlyOwner {
    if (fd == address(0)) revert InvalidFeeDistributorAddress();
    feeDistributor = fd;
    emit FeeDistributorAddressUpdated(fd);
  }

  function setStrategist(address s) public onlyOwner {
    if (s == address(0)) revert InvalidStrategistAddress();
    strategist = s;
    emit StrategistAddressUpdated(s);
  }

  function setReinvestMinAmount(uint256 a) public onlyOwner {
    reinvestMinAmount = a;
    emit ReinvestMinAmountUpdated(a);
  }

  function setReinvestFeeBps(uint256 bps) public onlyOwner {
    if (bps > MAX_FEE_BPS) revert InvalidReinvestFeeBps();
    reinvestFeeBps = bps;
    emit ReinvestFeeBpsUpdated(bps);
  }

  function setReinvestFeeDistribution(
    uint256 treasury_,
    uint256 feeDistributor_,
    uint256 strategist_,
    uint256 caller_
  ) public onlyOwner {
    uint256 total = treasury_ + feeDistributor_ + strategist_ + caller_;
    if (total != BPS_SCALE) revert InvalidReinvestFeeDistribution();
    reinvestFeeTreasuryBps = treasury_;
    reinvestFeeDistributorBps = feeDistributor_;
    reinvestFeeStrategistBps = strategist_;
    reinvestFeeCallerBps = caller_;
    emit ReinvestFeeDistributionUpdated(
      treasury_,
      feeDistributor_,
      strategist_,
      caller_
    );
  }
}
