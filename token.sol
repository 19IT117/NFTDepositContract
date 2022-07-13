//1470701 --> 1470483
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SSTestToken1 is ERC20 {
    bool public supplycontroled = false;
    //address constant adr1 =;
    //address constant adr2 =;
  
    constructor() ERC20("SSTest Token 1", "SSTest1") {
         _mint(msg.sender,100000000*10 ** decimals());
         //_mint(adr1,1000);
         //_mint(adr2,1200*10**decimals());
         supplycontroled = true;
    }

    function decimals() public pure override returns (uint8) {
        return 0;
    }
    
    function approveDepositContract(address contractAddress) public{
        approve(contractAddress,balanceOf(msg.sender));
    }

    function mint() virtual external payable{
        require(!supplycontroled, "You can't mint anymore");
        _mint(msg.sender , msg.value);
    } 
}
