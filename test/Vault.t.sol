// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.23;

import "@std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "src/Vault.sol";

/**
 * @title Vault Test
 * @author sepyke.eth
 * @notice Test basic functionalities
 */
contract VaultTest is Test {
  Vault vault;

  address admin = vm.addr(0xBA5ED);
  address treasury = vm.addr(0xDADD1);
  address staker = vm.addr(0x06);
  address creator = vm.addr(0x60D);
  address asset = vm.addr(0x012);

  uint256 feeBps = 1000; // 10%
  uint256 treasuryBps = 3500; // 35%
  uint256 stakerBps = 4000; // 40%
  uint256 creatorBps = 1000; // 10%
  uint256 compounderBps = 500; // 5%

  function setUp() public {
    Vault.GlobalConfig memory globalConfig = Vault.GlobalConfig({
      name: "Vaultbird Vault",
      symbol: "VBT",
      asset: IERC20(asset),
      admin: admin
    });
    Vault.BPS memory bps = Vault.BPS({
      fee: feeBps,
      treasury: treasuryBps,
      staker: stakerBps,
      creator: creatorBps,
      compounder: compounderBps
    });
    Vault.Recipients memory recipients = Vault.Recipients({
      treasury: treasury,
      staker: staker,
      creator: creator
    });
    vault = new Vault(globalConfig, bps, recipients);
  }

  function test_fees() public {
    Vault.BPS memory bps = vault.bps();
    assertEq(bps.fee, feeBps);
    assertEq(bps.treasury, treasuryBps);
    assertEq(bps.staker, stakerBps);
    assertEq(bps.creator, creatorBps);
    assertEq(bps.compounder, compounderBps);
  }

  function test_recipients() public {
    Vault.Recipients memory r = vault.recipients();
    assertEq(r.treasury, treasury);
    assertEq(r.staker, staker);
    assertEq(r.creator, creator);
  }

  function test_setFees() public {
    Vault.BPS memory newBps = Vault.BPS({
      fee: 1000,
      treasury: 5000,
      staker: 4000,
      creator: 500,
      compounder: 500
    });

    vm.startPrank(admin);
    vault.setFees(newBps);
    vm.stopPrank();

    Vault.BPS memory bps = vault.bps();
    assertEq(bps.fee, newBps.fee);
    assertEq(bps.treasury, newBps.treasury);
    assertEq(bps.staker, newBps.staker);
    assertEq(bps.creator, newBps.creator);
    assertEq(bps.compounder, newBps.compounder);
  }

  function test_setFeesRevertNonAdmin() public {
    Vault.BPS memory newBps = Vault.BPS({
      fee: 1000,
      treasury: 5000,
      staker: 4000,
      creator: 500,
      compounder: 500
    });

    vm.startPrank(creator);
    vm.expectRevert(
      abi.encodeWithSelector(
        Ownable.OwnableUnauthorizedAccount.selector,
        creator
      )
    );
    vault.setFees(newBps);
  }

  function test_setFeesRevertInvalidBPS() public {
    Vault.BPS memory newBps = Vault.BPS({
      fee: 1000,
      treasury: 5000,
      staker: 5000,
      creator: 500,
      compounder: 500
    });

    vm.startPrank(admin);
    vm.expectRevert(abi.encodeWithSelector(Vault.InvalidBPS.selector));
    vault.setFees(newBps);

    newBps = Vault.BPS({
      fee: 10000,
      treasury: 4000,
      staker: 5000,
      creator: 500,
      compounder: 500
    });

    vm.startPrank(admin);
    vm.expectRevert(abi.encodeWithSelector(Vault.InvalidBPS.selector));
    vault.setFees(newBps);
  }

  function test_setRecipients() public {
    Vault.Recipients memory r = Vault.Recipients({
      treasury: vm.addr(0x01),
      staker: vm.addr(0x02),
      creator: vm.addr(0x03)
    });

    vm.startPrank(admin);
    vault.setRecipients(r);
    vm.stopPrank();

    Vault.Recipients memory newR = vault.recipients();
    assertEq(newR.treasury, r.treasury);
    assertEq(newR.staker, r.staker);
    assertEq(newR.creator, r.creator);
  }

  function test_setRecipientsRevertNonAdmin() public {
    Vault.Recipients memory r = Vault.Recipients({
      treasury: vm.addr(0x01),
      staker: vm.addr(0x02),
      creator: vm.addr(0x03)
    });

    vm.startPrank(creator);
    vm.expectRevert(
      abi.encodeWithSelector(
        Ownable.OwnableUnauthorizedAccount.selector,
        creator
      )
    );
    vault.setRecipients(r);
  }

  function test_setRecipientsRevertInvalidRecipients() public {
    Vault.BPS memory newBps = Vault.BPS({
      fee: 1000,
      treasury: 5000,
      staker: 5000,
      creator: 500,
      compounder: 500
    });

    vm.startPrank(admin);
    vm.expectRevert(abi.encodeWithSelector(Vault.InvalidBPS.selector));
    vault.setFees(newBps);

    newBps = Vault.BPS({
      fee: 10000,
      treasury: 4000,
      staker: 5000,
      creator: 500,
      compounder: 500
    });

    vm.startPrank(admin);
    vm.expectRevert(abi.encodeWithSelector(Vault.InvalidBPS.selector));
    vault.setFees(newBps);
  }
}
