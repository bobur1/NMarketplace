import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { ethers, network } from 'hardhat';
import { expect, assert } from 'chai';
import { BigNumber, ContractFactory, ContractReceipt, ContractTransaction } from "ethers";

import Web3 from 'web3';
// @ts-ignore
const web3 = new Web3(network.provider) as Web3;
const depositTotal = BigNumber.from(10).pow(18).mul(100);

import { CustomToken, CustomNFT, MarketPlace } from '../typechain';
import { AssertionError } from 'assert/strict';

let token0: CustomToken;
let market: MarketPlace;
let nft: CustomNFT;

let NFT:ContractFactory;

let owner: SignerWithAddress;
let user0: SignerWithAddress;
let user1: SignerWithAddress;
let users:Array<SignerWithAddress>;

describe('Contract: MarketPlace', () => {
    beforeEach(async () => {
        [owner, user0, user1, ...users] = await ethers.getSigners();
        let CustomToken = await ethers.getContractFactory('CustomToken');
        token0 = await CustomToken.deploy('CustomToken', 'Ctm', depositTotal) as CustomToken;
        let MarketPlace = await ethers.getContractFactory('MarketPlace');
        market = await MarketPlace.deploy(token0.address) as MarketPlace;
        NFT = await ethers.getContractFactory('CustomNFT');
        let nftAddress = await market.itemToken();
        nft = await NFT.attach(nftAddress) as CustomNFT;
    });
    
	describe('Deployment', () => {
		it('Chech Token Balance', async () => {
			expect(await token0.balanceOf(owner.address)).to.equal(depositTotal);
		});
		it('Chech MarketPlace Token address', async () => {
			expect(await market.currencyToken()).to.equal(token0.address);
		});
        it('Check MarketPlace NFT origin address', async () => {
            expect(await nft.hasRole(await nft.DEFAULT_ADMIN_ROLE(), market.address)).to.be.true;
        });
    });

    describe('Transactions', () => {
        let trade0Price = BigNumber.from(10).pow(18).mul(3);
        
        let contractTx: ContractTransaction;
        let contractReceipt: ContractReceipt;

        beforeEach(async () => {
            // give user1 money
            await token0.transfer(user1.address, trade0Price);
            // approve to use erc20 tokens to MarketPlace; better to allow to use more than less
            await token0.connect(user1).approve(market.address, trade0Price.mul(10));
            // grant user0 'Artist' role
            await market.grantRole(await market.ARTIST_ROLE(), user0.address);
            // give user0 id to add user0's trading item
            await market.connect(user0).mintNFTToken();
            // approve to use newly minted token to MarketPlace
            await nft.connect(user0).approve(market.address, 0);
            // open trade with id 0 by user0
            // event listener from https://stackoverflow.com/questions/68432609/contract-event-listener-is-not-firing-when-running-hardhat-tests-with-ethers-js
            contractTx = await market.connect(user0).openTrade(0, trade0Price);
            contractReceipt = await contractTx.wait();
        });
        it('Mint NFT', async () => {
            // grant user1 'Artist' role
            await market.grantRole(await market.ARTIST_ROLE(), user1.address);
			expect(await market.connect(user1).mintNFTToken()).to.emit(market, 'TokenMinted')
            .withArgs(1, user1.address);
		});
        it('Create new Iteam in the market', async () => {
            const event = contractReceipt.events?.find(event => event.event === 'TradeStatusChange');
            const tradeCounter: BigNumber = event?.args!['tradeCounter'];
            const status: number = event?.args!['status'];
            expect(tradeCounter).to.equal(0);
            expect(status).to.equal(1);
		});
        it('Cannot create new item without owning the token', async () => {
            // using users[2] instead of users[0] due to not messing with already used numbers
            await expect(market.connect(users[2]).openTrade(0, trade0Price)).to.revertedWith('C721: transfer of token that is not own');
		});
        it('Sell item', async () => {
            expect(await market.connect(user1).executeTrade(0)).to.emit(market, 'TradeStatusChange')
            .withArgs(0, 2);
		});
        it('Cannot sell item to the lower price', async () => {
            token0.transfer(users[2].address, trade0Price.div(2));
            await token0.connect(users[2]).approve(market.address, trade0Price);
            await expect(market.connect(users[2]).executeTrade(0)).to.revertedWith('ERC20: transfer amount exceeds balance');
		});
        it('Cancel item', async () => {
            expect(await market.connect(user0).cancelTrade(0)).to.emit(market, 'TradeStatusChange')
            .withArgs(0, 3);
		});
        it('Cannot cancel trading of the item if user not the poster of it', async () => {
            await expect(market.connect(users[2]).cancelTrade(0)).to.revertedWith('Trade can be cancelled only by poster.');
		});
    });
});
