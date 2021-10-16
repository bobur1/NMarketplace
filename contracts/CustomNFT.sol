// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract CustomNFT is ERC721, AccessControl {
    uint256 public nextTokenId;

    // Create a new role identifier for the minter role
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /**
    * @notice Create custom ERC721
    * @param name of the ERC721 token
    * @param symbol of the ERC721 token
     */
    constructor(string memory name, string memory symbol) ERC721(name, symbol) {        
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        // Grant the minter role to a specified account
        _setupRole(MINTER_ROLE, msg.sender);
    }
    /**
    * @notice Mint some ERC721 tokens
    * @param client address of the potentional owner of the new token
     */
    function mint(address client) public onlyRole(MINTER_ROLE) {
        _safeMint(client, nextTokenId);
        nextTokenId ++;
    }

    /**
    * @notice The following functions are overrides required by Solidity.
    * @dev See {IERC165-supportsInterface}.
    * @param interfaceId interface id
    */
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, AccessControl) returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
