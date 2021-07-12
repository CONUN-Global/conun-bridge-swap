
import "OpenZeppelin/openzeppelin-contracts@4.1.0/contracts/access/Ownable.sol";
import "OpenZeppelin/openzeppelin-contracts@4.1.0/contracts/token/ERC20/IERC20.sol";
import "OpenZeppelin/openzeppelin-contracts@4.1.0/contracts/token/ERC20/utils/SafeERC20.sol";
import "./BridgeTypes.sol";

pragma solidity ^0.8.2;

contract Bridge is BridgeTypes, Ownable {
    using SafeERC20 for IERC20;


    address public CON_IERC20;

    // mappings
    mapping(uint256 => BridgeStorage) private history;


    // events
    event NewDeposit(address indexed from, uint256 indexed depositId, uint256 indexed amount);
    event NewWithdraw(address indexed user, uint256 withdrawId, uint256 indexed amount);

    function depositTokens(
        uint256 _amount,
        uint256 depositId,
        address user

    )
        external

    {
        require(_amount > 0, "Cant deposit 0 amount");
        require(IERC20(CON_IERC20).allowance(msg.sender, address(this)) >= _amount, "Please approve first");
        require(msg.sender == user, "Depositing user should be same as msg.sender");

        // store amount

        history[depositId] =BridgeStorage({
            user: msg.sender,
            amount: _amount,
            action: Types.DEPOSIT});

        IERC20 token = IERC20(CON_IERC20);
        token.safeTransferFrom(msg.sender, address(this), _amount);

        emit NewDeposit(msg.sender, depositId, _amount);

    }


    function getInfoById(uint256 _id) external view returns (BridgeStorage memory) {
        return history[_id];
    }




    ////////////////////////////////////////////////////////////
    /////////// Only Owner           ////////////////////////////
    ////////////////////////////////////////////////////////////

    function claimTokens(
        uint256 _amount,
        address _to, uint256
        withdrawId
    )
        external onlyOwner
    {
        //Lets get our lockRecord by index
        require(_amount <= IERC20(CON_IERC20).balanceOf(address(this)), "Insufficient balance");
        require(_to != address(0), "sender address must be valid address");


        history[withdrawId] =BridgeStorage({
            user: msg.sender,
            amount: _amount,
            action: Types.WITHDRAW});        //send tokens
        IERC20 token = IERC20(CON_IERC20);
        token.safeTransfer(_to, _amount);

        emit NewWithdraw(_to, withdrawId, _amount);
    }



    function setConTokenAddress(address conun) external onlyOwner {
        require(conun != address(0), "cant set address to zero");

        CON_IERC20 = conun;
    }
}
