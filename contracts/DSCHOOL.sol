//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

///imported contracts from openzepplin
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract DSCHOOL is ERC721URIStorage {

    ///auto-increment field for each token
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;



    ///address of Dschool Market
     address contractAddress;

    constructor(address DSchoolMarket) ERC721("DSchool", "DSC"){
       contractAddress = DSchoolMarket;
    }

    /// @notice create a new token
    /// @param tokenURI : token URI
    function createToken(string memory tokenURI) public returns(uint) {
        //set a new token id for the token to be minted
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId); //mint the token
        _setTokenURI(newItemId, tokenURI); //generate the URI
        setApprovalForAll(contractAddress, true); //grant transaction permission to marketplace

        //return token ID
        return newItemId;

    }
}