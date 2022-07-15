// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "https://github.com/19IT117/SSTestToken/blob/main/Token.sol";


contract Deposit is ERC721Holder{
    
    SSTestToken token1;
    SSTestToken token2;
    IERC721 NFT;
    address public owner;
    uint32 public TVLocked;
    uint32 public ownerBalance;
    uint32 public interestPayable;
    uint32 public TVLoaned;
    uint32 ownerEarnings;

    struct LockDetails {
        uint32 amount;
        uint256 lockperiod;
    }


    struct nftCollateralDetails{
        uint256 tokenID;
        uint256 timestamp;
    }

    mapping(address => LockDetails[]) public LockMapping;
  
    mapping (address => nftCollateralDetails[]) public nftCollateralMapping;

    constructor(address _contractaddress1, address NFTAddress){
        token1 = SSTestToken(_contractaddress1);
        NFT = IERC721(NFTAddress);
        owner = msg.sender;
        //t.transferFrom(owner,address(this),1000000);
    }

    function lockNFT(uint256 tokenID) external{
        require(TVLocked-TVLoaned <= 1000, "Insufficent fund in the contract");
        NFT.safeTransferFrom(msg.sender,address(this),tokenID);
        token1.transfer(msg.sender,1000);
        nftCollateralMapping[msg.sender].push(nftCollateralDetails({
            tokenID:tokenID,
            timestamp : block.timestamp
        }));
        TVLoaned += 1000;
        TVLocked -= 1000;
    }

    function unLockNFT(uint256 lockID, uint256 amount) external{
        nftCollateralDetails storage s = nftCollateralMapping[msg.sender][lockID];
        require(amount == 1200 , "Pay complete loan");
        token1.transferFrom(msg.sender,address(this),amount);
        NFT.transferFrom(address(this),msg.sender,s.tokenID);
        TVLoaned -= 1000;
        TVLocked += 1000;
        ownerEarnings += 200;
        delete nftCollateralMapping[msg.sender][lockID]; 
    }
    
    function DepositToken(uint32 amount , uint256 timeperiod) external{
        require(amount>=1000,"Deposit more than 1000");
        require(timeperiod>=10 , "Need to deposit more than 10 Seconds");
        token1.transferFrom(msg.sender,address(this),amount);
        LockMapping[msg.sender].push(LockDetails({amount : amount , lockperiod : block.timestamp + timeperiod}));
        TVLocked += amount;
        interestPayable += (amount * 10)/100;
        require(ownerBalance>interestPayable, "Sorry Deposit can't be done please try later.");
    }

    function ClaimTokens(uint256 index) external{
        require(LockMapping[msg.sender][index].lockperiod<=block.timestamp, "you can't withdraw now");
        LockDetails storage s =  LockMapping[msg.sender][index];
        TVLocked -= s.amount;
        interestPayable -= (s.amount * 10)/100;
        ownerBalance -= (s.amount * 10)/100;    
        token1.transfer(msg.sender,(s.amount*11)/10);
        delete LockMapping[msg.sender][index];
    }

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    function changeOwnership(address newOwner) external onlyOwner{
        token1.transferFrom(newOwner,address(this),ownerBalance);
        owner = newOwner;
        token1.transfer(owner,ownerBalance);
    }

    function ownerDeposit(uint32 amount) external onlyOwner{
        token1.transferFrom(owner,address(this),amount);
        ownerBalance += amount;
    }

    function revokeDeposit(uint32 amount) external onlyOwner{
        require(amount<interestPayable , "Deposit can cause trouble for the project");
        token1.transfer(owner,amount);
        ownerBalance -= amount;
    }

    function withdrawEarnings() public onlyOwner{
        require(ownerEarnings>0,"Nothing earned yet");
        token1.transfer(owner,ownerEarnings);
        ownerEarnings=0;
    }

}

