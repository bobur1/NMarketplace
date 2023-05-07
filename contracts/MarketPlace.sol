// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";


import "./CustomNFT.sol";

contract MarketPlace is Initializable, PausableUpgradeable, OwnableUpgradeable, UUPSUpgradeable, ReentrancyGuardUpgradeable {
    using SafeERC20 for IERC20;

    uint256 public tradeCounter;
    // Weth contract for current chain
    address public nativeTokenERC20;
    // local nft contract
    address public nft;


    struct Trade {
        address seller;
        uint256 itemId;
        uint256 price;
        Status status;
    }

    // ToDo::add hash
    enum Status {Default, InSale, Sold, Cancelled}
    mapping(uint256 => Trade) public trades;
    mapping(address=> bool) public blockList;

    event TokenMinted(uint256 tokenId, address owner);
    event TradeStatusChange(uint256 tradeCounter, Status status);

    modifier notBlocked(address _address) {
        uint256 codeSize;
        assembly {codeSize := extcodesize(_address)}

        if(codeSize > 0) {
            require(!blockList[_address], "Address is blocked and cannot perform this action");
        } else {
            require(!blockList[_address], "Contract address is blocked");
        }
        _;
    }

    modifier isContractBlocked(address _address) {
        require(!blockList[_address], "Contract address");
        _;
    }

    // @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
    * @notice MarketPlace to sell/trade some items
    * @param _nft local nft address
    */
    function initialize(address _nft) initializer public {
        __Pausable_init();
        __Ownable_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        nft = _nft;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    /**
    * @notice mint a new token
     */
    function mintNFTToken() external notBlocked(msg.sender) {
        uint256 currentTokenId = CustomNFT(nft).mint(msg.sender);
        emit TokenMinted(currentTokenId, msg.sender);
    }

    /**
    * @notice Open trade - creates new item in the trading list(map)
    * @dev Creating new item in the map defined by id : {tradeCounter}; id auto increments 
    * @param _itemId ERC721 token id
    * @param _price item price; defined by seller
     */
    function openTrade(uint256 _itemId, uint256 _price) external nonReentrant {
        IERC721(nft).transferFrom(msg.sender, address(this), _itemId);
        trades[tradeCounter] = Trade({
            seller: msg.sender,
            itemId: _itemId,
            price: _price,
            status: Status.InSale
        });
        tradeCounter += 1;

        emit TradeStatusChange(tradeCounter - 1, Status.InSale);
    }

    /**
    * @notice Sell the item from the trading list(map)
    * @param _trade id in the trading list(map)
     */
    function sell(uint256 _trade) external nonReentrant {
        Trade memory trade = trades[_trade];

        require(trade.status == Status.InSale, "Trade is not Open.");

        IERC20(nativeTokenERC20).safeTransferFrom(msg.sender, trade.seller, trade.price);
        IERC721(nft).transferFrom(address(this), msg.sender, trade.itemId);
        trades[_trade].status = Status.Sold;

        emit TradeStatusChange(_trade, Status.Sold);
    }

    /**
    * @notice Execute trade - cancel the item from the trade,
    * but it will still present in the trading list(map)
    * @param _trade id in the trading list(map)
     */
    function cancelTrade(uint256 _trade) external {
        Trade memory trade = trades[_trade];

        require(msg.sender == trade.seller, "Trade can be cancelled only by seller.");
        require(trade.status == Status.InSale, "Trade is not Open.");

        IERC721(nft).transferFrom(address(this), trade.seller, trade.itemId);
        trades[_trade].status = Status.Cancelled;

        emit TradeStatusChange(_trade, Status.Cancelled);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
}
