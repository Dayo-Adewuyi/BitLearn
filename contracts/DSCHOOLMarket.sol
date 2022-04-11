//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/** imported contracts from openzeppelin to use the 
    COUNTER function, ERC721 token contract and prevent 
    Re-entrancy attacks*/
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @title A market place for DSCHOOL courses
/// @author Wande Adewuyi
/// @dev All function calls are currently implemented without side effects

contract DSCHOOLMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    ///total number of items ever created
    Counters.Counter private _itemIds;

    ///total number of items sold
    Counters.Counter private _itemsSold;

    /// owner of the smart contract
    address payable owner;
    //listing price for courses
    uint256 listingPrice = 0.01 ether;

    constructor() {
        owner = payable(msg.sender);
    }

    ///@dev this is a struct for items on the market

    struct MarketItem {
        uint itemId;
        address nftContract;
        uint256 tokenId;
        address payable tutor;
        address owner;
        uint256 price;
        bool sold;
    }

    /// an identification system for the MarketItem struct above by passing an integer ID
    mapping(uint256 => MarketItem) private idMarketItem;

    ///event to be listened to anytime a course is created

    event MarketItemCreated(
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address tutor,
        address owner,
        uint256 price,
        bool sold
    );

    /// @notice function to get listingprice
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    ///@notice function to update listingprice
    function setListingPrice(uint _price) public returns (uint) {
        if (msg.sender == address(this)) {
            listingPrice = _price;
        }
        return listingPrice;
    }

    /// @notice function to create market item
    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant {
        require(price > 0, "Price must be above zero");
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        );

        _itemIds.increment(); //add 1 to the total number of items ever created
        uint256 itemId = _itemIds.current();

        idMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender), //address of the tutor putting the course up for sale
            payable(address(0)), //no owner yet (set owner to empty address)
            price,
            false
        );

        //transfer ownership of the course to the contract itself
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        //emit this transaction
        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price,
            false
        );
    }

    /// @notice function to create a sale
    function createMarketSale(address nftContract, uint256 itemId)
        public
        payable
        nonReentrant
    {
        uint price = idMarketItem[itemId].price;
        uint tokenId = idMarketItem[itemId].tokenId;

        require(msg.value == price, "please pay the exact price");

        ///transfer exact sum to the tutor
        idMarketItem[itemId].tutor.transfer(msg.value);

        ///transfer ownership of the course from the contract itself to the buyer
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);

        /// make the buyer the new owner
        idMarketItem[itemId].owner = payable(msg.sender);
        /// change status to item sold
        idMarketItem[itemId].sold = true;
        ///increment the total number of Items sold by 1
        _itemsSold.increment();
        ///pay owner of contract the listing price
        payable(owner).transfer(listingPrice);
    }

    /// @notice total number of items unsold on our platform
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        /// total number of items ever created
        uint itemCount = _itemIds.current();
        ///total number of items that are unsold = total items ever created - total items ever sold
        uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
        uint currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);

        ///loop through all items ever created
        for (uint i = 0; i < itemCount; i++) {
            ///get only unsold item
            ///check if the item has not been sold
            ///by checking if the owner field is empty
            if (idMarketItem[i + 1].owner == address(0)) {
                ///this item has never been sold
                uint currentId = idMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        ///return array of all unsold items
        return items;
    }

    /// @notice fetch list of courses owned/bought by the user
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        ///get total number of items ever created
        uint totalItemCount = _itemIds.current();

        uint itemCount = 0;
        uint currentIndex = 0;

        for (uint i = 0; i < totalItemCount; i++) {
            ///get only the items that this user has bought/is the owner
            if (idMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1; //total length
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint i = 0; i < totalItemCount; i++) {
            if (idMarketItem[i + 1].owner == msg.sender) {
                uint currentId = idMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    /// @notice fetch list of courses owned/bought by this user
    function fetchItemsCreated() public view returns (MarketItem[] memory) {
        ///get total number of items ever created
        uint totalItemCount = _itemIds.current();

        uint itemCount = 0;
        uint currentIndex = 0;

        for (uint i = 0; i < totalItemCount; i++) {
            ///get only the items that this user has bought/is the owner
            if (idMarketItem[i + 1].tutor == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint i = 0; i < totalItemCount; i++) {
            if (idMarketItem[i + 1].tutor == msg.sender) {
                uint currentId = idMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
}
