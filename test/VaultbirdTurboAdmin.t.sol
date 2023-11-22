// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.23;

import "@std/Test.sol";

import "src/VaultbirdTurbo.sol";

/**
 * @title Vaultbird Turbo Admin test
 * @author sepyke.eth
 * @dev Test admin functionalities
 * @custom:contact security@autocompounderbird.com
 */
contract VaultbirdTurboAdminTest is Test {
  address admin = vm.addr(0xBA5ED);
  address treasury = vm.addr(0xDADD1);
  address alice = vm.addr(0xA11CE);
  address random = vm.addr(0x8888);

  // bps: 100 -> 1%
  VaultbirdTurbo.Config config =
    VaultbirdTurbo.Config({
      name: "Vaultbird Vault",
      symbol: "VV",
      asset: IERC20(random),
      rewards: IERC20(random),
      native: IERC20(random),
      admin: admin,
      treasury: random,
      feeDistributor: random,
      strategist: random,
      reinvestMinAmount: 0,
      reinvestFeeBps: 1000,
      reinvestFeeTreasuryBps: 3500,
      reinvestFeeDistributorBps: 5000,
      reinvestFeeStrategistBps: 1000,
      reinvestFeeCallerBps: 500
    });

  VaultbirdTurbo autocompounder;

  function setUp() public {
    autocompounder = new VaultbirdTurbo(config);
  }

  function test_setTreasury() public {
    assertEq(autocompounder.treasury(), random);
    address newTreasury = vm.addr(0x012);

    vm.startPrank(admin);
    autocompounder.setTreasury(newTreasury);
    vm.stopPrank();

    assertEq(autocompounder.treasury(), newTreasury);
  }

  function test_setTreasuryRevertNonAdmin() public {
    address newTreasury = vm.addr(0x012);

    vm.startPrank(alice);
    vm.expectRevert(
      abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice)
    );
    autocompounder.setTreasury(newTreasury);
  }

  function test_setTreasuryRevertBurnAddress() public {
    vm.startPrank(admin);
    vm.expectRevert(
      abi.encodeWithSelector(VaultbirdTurbo.InvalidTreasuryAddress.selector)
    );
    autocompounder.setTreasury(address(0));
  }

  function test_setFeeDistributor() public {
    assertEq(autocompounder.feeDistributor(), random);
    address newFeeDistributor = vm.addr(0x012);

    vm.startPrank(admin);
    autocompounder.setFeeDistributor(newFeeDistributor);
    vm.stopPrank();

    assertEq(autocompounder.feeDistributor(), newFeeDistributor);
  }

  function test_setFeeDistributorRevertNonAdmin() public {
    address addr = vm.addr(0x012);

    vm.startPrank(alice);
    vm.expectRevert(
      abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice)
    );
    autocompounder.setFeeDistributor(addr);
  }

  function test_setFeeDistributorRevertBurnAddress() public {
    vm.startPrank(admin);
    vm.expectRevert(
      abi.encodeWithSelector(
        VaultbirdTurbo.InvalidFeeDistributorAddress.selector
      )
    );
    autocompounder.setFeeDistributor(address(0));
  }

  function test_setStrategist() public {
    assertEq(autocompounder.strategist(), random);
    address newStrategist = vm.addr(0x012);

    vm.startPrank(admin);
    autocompounder.setStrategist(newStrategist);
    vm.stopPrank();

    assertEq(autocompounder.strategist(), newStrategist);
  }

  function test_setStrategistRevertNonAdmin() public {
    address newStrategist = vm.addr(0x012);

    vm.startPrank(alice);
    vm.expectRevert(
      abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice)
    );
    autocompounder.setStrategist(newStrategist);
  }

  function test_setStrategistRevertBurnAddress() public {
    vm.startPrank(admin);
    vm.expectRevert(
      abi.encodeWithSelector(VaultbirdTurbo.InvalidStrategistAddress.selector)
    );
    autocompounder.setStrategist(address(0));
  }

  function test_setReinvestMinAmount() public {
    assertEq(autocompounder.reinvestMinAmount(), 0);

    vm.startPrank(admin);
    autocompounder.setReinvestMinAmount(1 ether);
    vm.stopPrank();

    assertEq(autocompounder.reinvestMinAmount(), 1 ether);
  }

  function test_setReinvestMinAmountRevertNonAdmin() public {
    vm.startPrank(alice);
    vm.expectRevert(
      abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice)
    );
    autocompounder.setReinvestMinAmount(1 ether);
  }

  function test_setReinvestFeeBps() public {
    assertEq(autocompounder.reinvestFeeBps(), 1000);

    vm.startPrank(admin);
    autocompounder.setReinvestFeeBps(100);
    vm.stopPrank();

    assertEq(autocompounder.reinvestFeeBps(), 100);
  }

  function test_setReinvestFeeBpsRevertNonAdmin() public {
    vm.startPrank(alice);
    vm.expectRevert(
      abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice)
    );
    autocompounder.setReinvestFeeBps(100);
  }

  function test_setReinvestFeeBpsRevertGreaterThanMax() public {
    vm.startPrank(admin);
    vm.expectRevert(
      abi.encodeWithSelector(VaultbirdTurbo.InvalidReinvestFeeBps.selector)
    );
    autocompounder.setReinvestFeeBps(1001);
  }

  function test_setReinvestFeeDistribution() public {
    assertEq(autocompounder.reinvestFeeTreasuryBps(), 3500);
    assertEq(autocompounder.reinvestFeeDistributorBps(), 5000);
    assertEq(autocompounder.reinvestFeeStrategistBps(), 1000);
    assertEq(autocompounder.reinvestFeeCallerBps(), 500);

    vm.startPrank(admin);
    autocompounder.setReinvestFeeDistribution(5000, 4000, 500, 500);
    vm.stopPrank();

    assertEq(autocompounder.reinvestFeeTreasuryBps(), 5000);
    assertEq(autocompounder.reinvestFeeDistributorBps(), 4000);
    assertEq(autocompounder.reinvestFeeStrategistBps(), 500);
    assertEq(autocompounder.reinvestFeeCallerBps(), 500);
  }

  function test_setReinvestFeeDistributionRevertNonAdmin() public {
    vm.startPrank(alice);
    vm.expectRevert(
      abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice)
    );
    autocompounder.setReinvestFeeDistribution(5000, 4000, 500, 500);
  }

  function test_setReinvestFeeDistributionRevertInvalid() public {
    vm.startPrank(admin);
    vm.expectRevert(
      abi.encodeWithSelector(
        VaultbirdTurbo.InvalidReinvestFeeDistribution.selector
      )
    );
    autocompounder.setReinvestFeeDistribution(5000, 4000, 1000, 500);
  }
}
