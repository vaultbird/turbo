// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.23;

import "@std/Test.sol";

import "src/VaultbirdVault.sol";

/**
 * @title Vaultbird Vault Administration test
 * @author sepyke.eth
 * @dev Test admin functionalities
 */
contract VaultbirdVaultAdminTest is Test {
  address admin = vm.addr(0xBA5ED);
  address treasury = vm.addr(0xDADD1);
  address alice = vm.addr(0xA11CE);
  address random = vm.addr(0x8888);

  // bps: 100 -> 1%
  VaultbirdVault.Config config =
    VaultbirdVault.Config({
      name: "Vaultbird Vault",
      symbol: "VV",
      asset: IERC20(random),
      native: IERC20(random),
      strategy: IVaultbirdStrategy(random),
      admin: admin,
      treasury: random,
      feeDistributor: random,
      reinvestMinAmount: 0,
      reinvestFeeBps: 1000,
      reinvestFeeTreasuryBps: 3500,
      reinvestFeeDistributorBps: 5000,
      reinvestFeeStrategistBps: 1000,
      reinvestFeeCallerBps: 500
    });

  VaultbirdVault vault;

  function setUp() public {
    vault = new VaultbirdVault(config);
  }

  function test_AD() public {}
}
