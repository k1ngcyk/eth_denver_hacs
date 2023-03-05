// SPDX-License-Identifier: MIT

// TwoOfTwenty eth denver hacs
// Blink Chen

pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract TOT is ERC721Enumerable, Ownable {
    using Strings for uint256;

    string baseURI;
    uint256 public cost = 0.5 ether;
    uint256 public maxSupply = 1000;
    uint256 public maxMintAmount = 10;
    uint256 public amountMinted;
    uint256 public maxUserMintAmount = 20;
    mapping(address => uint256) public userMintedAmount;
    bool public paused = false;

    constructor(string memory _initBaseURI) ERC721("2 OF 20", "TOT") {
        setBaseURI(_initBaseURI);
        // _setDefaultRoyalty(msg.sender, 500);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function mint(uint256 _mintAmount) public payable {
        uint256 supply = totalSupply();
        require(!paused, "Sale is not active");
        require(_mintAmount > 0, "Must mint at least 1 TOT");
        require(_mintAmount <= maxMintAmount, "No more than 10 POF in a tx");
        require(supply + _mintAmount <= maxSupply, "Max mint supply reached");

        if (msg.sender != owner()) {
            require(
                userMintedAmount[msg.sender] + _mintAmount <= maxUserMintAmount,
                "Over mint limit"
            );
            require(msg.value >= cost * _mintAmount, "Not enough value sent");
        }

        amountMinted += _mintAmount;
        userMintedAmount[msg.sender] += _mintAmount;
        _safeMint(msg.sender, _mintAmount);
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

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
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