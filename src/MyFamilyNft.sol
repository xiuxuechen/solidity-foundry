// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyFamilyNft is ERC721 {
    uint256 public sTokenCounter;
    mapping(uint256 => string) private tokenIdToUri;

    constructor() ERC721("MyFamilyNft", "MyFamily") {
        sTokenCounter = 0;
    }

    function mintNft(string memory _tokenURI) public returns (uint256) {
        sTokenCounter++;
        _safeMint(msg.sender, sTokenCounter);
        tokenIdToUri[sTokenCounter] = _tokenURI;
        return sTokenCounter;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        return tokenIdToUri[tokenId];
    }
}
