import { CustomToken, MarketPlace } from '../typechain';
import {ethers, run} from 'hardhat';
import {delay} from '../utils';
import { BigNumber} from "ethers";

async function deployMarketPlace() {
	const depositTotal = BigNumber.from(10).pow(18).mul(100);

	// ---CustomToken---
	const CustomToken = await ethers.getContractFactory('CustomToken');
	console.log('starting deploying token...');
	const token = await CustomToken.deploy('CustomToken', 'Ctm', depositTotal) as CustomToken;
	console.log('CustomToken deployed with address: ' + token.address);
	console.log('wait of deploying...');
	await token.deployed();
	console.log('wait of delay...');
	await delay(25000);
	console.log('starting verify token...');
	try {
		await run('verify:verify', {
			address: token!.address,
			contract: 'contracts/CustomToken.sol:CustomToken',
			constructorArguments: [ 'CustomToken', 'Ctm', depositTotal ],
		});
		console.log('verify success');
	} catch (e: any) {
		console.log(e.message);
	}
	// ---MarketPlace---
	const MarketPlace = await ethers.getContractFactory('MarketPlace');
	console.log('starting deploying MarketPlace...');
	const market = await MarketPlace.deploy(token.address) as MarketPlace;
	console.log('MarketPlace deployed with address: ' + market.address);
	console.log('wait of deploying...');
	await market.deployed();
	console.log('wait of delay...');
	await delay(25000);
	console.log('starting verify MarketPlace...');
	try {
		await run('verify:verify', {
			address: market!.address,
			contract: 'contracts/MarketPlace.sol:MarketPlace',
			constructorArguments: [ token.address ],
		});
		console.log('verify success');
	} catch (e: any) {
		console.log(e.message);
	}
}

deployMarketPlace()
.then(() => process.exit(0))
.catch(error => {
	console.error(error);
	process.exit(1);
});
