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
  uint256 BPS_SCALE = 1e4;
  uint256 MAX_FEE_BPS = 1000; // 10%

  struct GlobalConfig {
    string name;
    string symbol;
    IERC20 asset;
    address admin;
  }

  struct BPS {
    uint256 fee;
    uint256 treasury;
    uint256 staker;
    uint256 creator;
    uint256 compounder;
  }

  struct Recipients {
    address treasury;
    address staker;
    address creator;
  }

  BPS private _bps;
  Recipients private _recipients;

  error InvalidBPS();
  error InvalidRecipients();

  event BPSUpdated(BPS bps);
  event RecipientsUpdated(Recipients recipients);

  constructor(
    GlobalConfig memory g,
    BPS memory b,
    Recipients memory r
  ) Ownable(msg.sender) ERC20(g.name, g.symbol) ERC4626(g.asset) {
    setBps(b);
    setRecipients(r);
    transferOwnership(g.admin);
  }

  /// @dev Default public getters no good, can't use struct directly
  function bps() public view returns (BPS memory) {
    return _bps;
  }

  /// @dev Default public getters no good, can't use struct directly
  function recipients() public view returns (Recipients memory) {
    return _recipients;
  }

  function setBps(BPS memory b) public onlyOwner {
    uint256 total = b.treasury + b.staker + b.creator + b.compounder;
    if (total > BPS_SCALE) revert InvalidBPS();
    if (b.fee > MAX_FEE_BPS) revert InvalidBPS();
    _bps = b;
    emit BPSUpdated(_bps);
  }

  function setRecipients(Recipients memory r) public onlyOwner {
    if (r.treasury == address(0)) revert InvalidRecipients();
    if (r.staker == address(0)) revert InvalidRecipients();
    if (r.creator == address(0)) revert InvalidRecipients();
    _recipients = r;
    emit RecipientsUpdated(r);
  }
}
