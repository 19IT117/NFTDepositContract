// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SSNFT is ERC721, Ownable {
    uint256 totalsupply;
    //address constant adr2 =;
    constructor() ERC721("SS-NFT", "SSNFT") {
        //safeMint(adr2);  
    }

    function safeMint(address to) public onlyOwner {
        totalsupply++;
        _safeMint(to, totalsupply);
    }
}
