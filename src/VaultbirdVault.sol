// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "./interfaces/IVaultbirdStrategy.sol";

/**
 * @title Vaultbird Vault
 * @author sepyke.eth
 * @dev Simple, secure and extensible ERC4626
 * @custom:contact security@vaultbird.com
 */
abstract contract VaultbirdVault is ERC4626, Ownable {
  using Math for uint256;

  struct Config {
    string name;
    string symbol;
    IERC20 asset;
    IERC20 native;
    IVaultbirdStrategy strategy;
    address admin;
    address treasury;
    address feeDistributor;
    uint256 reinvestMinAmount;
    uint256 reinvestFeeBps;
    uint256 reinvestFeeTreasuryBps;
    uint256 reinvestFeeDistributorBps;
    uint256 reinvestFeeStrategistBps;
    uint256 reinvestFeeCallerBps;
  }

  IERC20 public native;
  IVaultbirdStrategy public strategy;

  address public treasury;
  address public feeDistributor;

  uint256 public BPS_SCALE = 1e4;
  uint256 public MAX_FEE_BPS = 1000; // 10%
  uint256 public reinvestMinAmount;
  uint256 public reinvestFeeBps;
  uint256 public reinvestFeeTreasuryBps;
  uint256 public reinvestFeeDistributorBps;
  uint256 public reinvestFeeStrategistBps;
  uint256 public reinvestFeeCallerBps;

  error InvalidStrategyAddress();
  error InvalidTreasuryAddress();
  error InvalidFeeDistributorAddress();
  error InvalidReinvestFeeBps();
  error InvalidReinvestFeeDistribution();

  event TreasuryAddressUpdated(address);
  event FeeDistributorAddressUpdated(address);
  event CreatorAddressUpdated(address);
  event ReinvestMinAmountUpdated(uint256);
  event ReinvestFeeBpsUpdated(uint256);
  event ReinvestFeeDistributionUpdated(
    uint256 treasury,
    uint256 feeDistributor,
    uint256 creator,
    uint256 caller
  );

  constructor(
    Config memory c
  ) Ownable(msg.sender) ERC20(c.name, c.symbol) ERC4626(c.asset) {
    native = c.native;

    setTreasury(c.treasury);
    setFeeDistributor(c.feeDistributor);
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

  function setStrategy(IVaultbirdStrategy newStrategy) public onlyOwner {
    if (newStrategy == address(0)) revert InvalidStrategyAddress();
    // TODO(pyk): gimana
    strategy.free();

    emit TreasuryAddressUpdated(t);
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

  function setCreator(address c) public onlyOwner {
    if (c == address(0)) revert InvalidStrategyAddress();
    creator = c;
    emit FeeDistributorAddressUpdated(c);
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
    uint256 t,
    uint256 fd,
    uint256 cr,
    uint256 ca
  ) public onlyOwner {
    uint256 total = t + fd + cr + ca;
    if (total != BPS_SCALE) revert InvalidReinvestFeeDistribution();
    reinvestFeeTreasuryBps = t;
    reinvestFeeDistributorBps = fd;
    reinvestFeeStrategistBps = cr;
    reinvestFeeCallerBps = ca;
    emit ReinvestFeeDistributionUpdated(t, fd, cr, ca);
  }

  function _getFeeAmount(
    uint256 rewardAmount
  ) internal view returns (uint256 feeAmount) {
    return rewardAmount.mulDiv(reinvestFeeBps, BPS_SCALE, Math.Rounding.Ceil);
  }

  function _deposit(
    address caller,
    address receiver,
    uint256 assets,
    uint256 shares
  ) internal virtual override {
    _reinvest(0);
    super._deposit(caller, receiver, assets, shares);
    _invest(assets);
  }

  function _distributeFees(uint256 feeAmount) internal {
    uint256 nativeAmount = _swapRewardsToNative(feeAmount);
  }

  function _invest(uint256 amount) internal virtual;

  function _reinvest(uint256 minAmount) internal virtual;

  function _swapRewardsToNative(
    uint256 amount
  ) internal virtual returns (uint256);

  // _reinvest()
  // _invest(amount)

  // TODO(pyk): add
  // - _getFeeAmount()
  // - _swapRewardsToNative(amount)
  // - _distributeFees(amount)
  // swap fees to native
}
