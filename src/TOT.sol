// SPDX-License-Identifier: MIT

// TwoOfTwenty eth denver hacs
// Blink Chen

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract TOT is ERC721Enumerable, ERC721Royalty, Ownable {
    using Strings for uint256;

    string baseURI;
    uint256 public cost = 0.5 ether;
    uint256 public maxSupply = 1000;
    mapping(address => bool) public userMinted;
    bool public paused = false;

    constructor(string memory _initBaseURI) ERC721("2 OF 20", "TOT") {
        setBaseURI(_initBaseURI);
        _setDefaultRoyalty(msg.sender, 500);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721Royalty) {
        super._burn(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Enumerable, ERC721Royalty)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function mint(address to) public payable returns (uint256 tokenId) {
        uint256 supply = totalSupply();
        require(!paused, "Sale is not active");
        require(supply < maxSupply, "Max mint supply reached");

        if (msg.sender != owner()) {
            require(
                !userMinted[to],
                "Over mint limit"
            );
            require(msg.value >= cost, "Not enough value sent");
        }

        uint256 newItemId = totalSupply() + 1;
        userMinted[to] = true;
        _safeMint(to, newItemId);
        return newItemId;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(abi.encodePacked(currentBaseURI, tokenId.toString()))
                : "";
    }

    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        Address.sendValue(payable(owner()), balance);
    }
}
