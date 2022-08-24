// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "./CustomNFT.sol";

contract MarketPlace is ReentrancyGuard, AccessControl {
    using SafeERC20 for IERC20;

    // Create a new role identifier for the minter role
    bytes32 public constant ARTIST_ROLE = keccak256("ARTIST_ROLE");

    uint256 public tradeCounter;
    IERC20 public currencyToken;
    IERC721 public itemToken;

    struct Trade {
        address poster;
        uint256 itemId;
        uint256 price;
        Status status;
    }

    enum Status {Default, Open, Executed, Cancelled}
    mapping(uint256 => Trade) public trades;

    event TokenMinted(uint256 tokenId, address owner);
    event TradeStatusChange(uint256 tradeCounter, Status status);

    /**
    * @notice MarketPlace to sell/trade some items
    * @dev new items should be connected to nft(ERC721) token and paid by {currencyToken}
    * @param _currencyTokenAddress address of ERC20 connected to this marketpalce
    *
     */
    constructor(address _currencyTokenAddress) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        currencyToken = IERC20(_currencyTokenAddress);
        itemToken = IERC721(new CustomNFT('New NFT', 'NNFT'));
    }

    /**
    * @notice mint a new token
     */
    function mintNFTToken() external onlyRole(ARTIST_ROLE) {
        CustomNFT nft = CustomNFT(address(itemToken));
        nft.mint(msg.sender);

        emit TokenMinted(nft.nextTokenId() - 1, msg.sender);
    }

    /**
    * @notice Open trade - creates new item in the trading list(map)
    * @dev Creating new item in the map defined by id : {tradeCounter}; id auto increments 
    * @param _itemId ERC721 token id
    * @param _price item price; defined by poster
     */
    function openTrade(uint256 _itemId, uint256 _price) external nonReentrant {
        itemToken.transferFrom(msg.sender, address(this), _itemId);
        trades[tradeCounter] = Trade({
            poster: msg.sender,
            itemId: _itemId,
            price: _price,
            status: Status.Open
        });
        tradeCounter += 1;

        emit TradeStatusChange(tradeCounter - 1, Status.Open);
    }

    /**
    * @notice Execute trade - sell the item from the trading list(map)
    * @param _trade id in the trading list(map)
     */
    function executeTrade(uint256 _trade) external nonReentrant {
        Trade memory trade = trades[_trade];

        require(trade.status == Status.Open, "Trade is not Open.");

        currencyToken.transferFrom(msg.sender, trade.poster, trade.price);
        itemToken.transferFrom(address(this), msg.sender, trade.itemId);
        trades[_trade].status = Status.Executed;

        emit TradeStatusChange(_trade, Status.Executed);
    }

    /**
    * @notice Execute trade - cancel the item from the trade,
    * but it will still present in the trading list(map)
    * @param _trade id in the trading list(map)
     */
    function cancelTrade(uint256 _trade) external {
        Trade memory trade = trades[_trade];

        require(msg.sender == trade.poster, "Trade can be cancelled only by poster.");
        require(trade.status == Status.Open, "Trade is not Open.");

        itemToken.transferFrom(address(this), trade.poster, trade.itemId);
        trades[_trade].status = Status.Cancelled;

        emit TradeStatusChange(_trade, Status.Cancelled);
    }
}