// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Vaultbird Vault
 * @author sepyke.eth
 * @notice Simple and secure auto-compounder
 */
contract Vault is ERC4626, Ownable {
  struct Config {
    string name;
    string symbol;
    IERC20 asset;
    IERC20 rewards;
    IERC20 native;
    address admin;
    address treasury;
    address feeDistributor;
    address creator;
    uint256 reinvestMinAmount;
    uint256 reinvestFeeBps;
    uint256 reinvestFeeTreasuryBps;
    uint256 reinvestFeeDistributorBps;
    uint256 reinvestFeeCreatorBps;
    uint256 reinvestFeeCallerBps;
  }

  IERC20 public rewards;
  IERC20 public native;
  address public treasury;
  address public feeDistributor;
  address public creator;

  uint256 public BPS_SCALE = 1e4;
  uint256 public MAX_FEE_BPS = 1000; // 10%
  uint256 public reinvestMinAmount;
  uint256 public reinvestFeeBps;
  uint256 public reinvestFeeTreasuryBps;
  uint256 public reinvestFeeDistributorBps;
  uint256 public reinvestFeeCreatorBps;
  uint256 public reinvestFeeCallerBps;

  error InvalidTreasuryAddress();
  error InvalidFeeDistributorAddress();
  error InvalidCreatorAddress();
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
    rewards = c.rewards;
    native = c.native;

    setTreasury(c.treasury);
    setFeeDistributor(c.feeDistributor);
    setCreator(c.creator);
    setReinvestMinAmount(c.reinvestMinAmount);
    setReinvestFeeBps(c.reinvestFeeBps);
    setReinvestFeeDistribution(
      c.reinvestFeeTreasuryBps,
      c.reinvestFeeDistributorBps,
      c.reinvestFeeCreatorBps,
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

  function setCreator(address c) public onlyOwner {
    if (c == address(0)) revert InvalidCreatorAddress();
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
    reinvestFeeCreatorBps = cr;
    reinvestFeeCallerBps = ca;
    emit ReinvestFeeDistributionUpdated(t, fd, cr, ca);
  }
}
