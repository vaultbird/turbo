// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.23;

/**
 * @title Vaultbird Strategy
 * @author sepyke.eth
 * @dev Vaultbird Strategy extends Vaultbird Vault
 * @custom:contact security@vaultbird.com
 */
interface IVaultbirdStrategy {
  function strategist() external returns (address);

  function rewards() external returns (address);

  function invest(uint256 amount) external returns (uint256);
}
