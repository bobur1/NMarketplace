# MarketPlace

## Deployed

### BSC Testnet

CustomNFT deployed with address: [0x1B1abEeAA98Dee1daC97c027ed237F479907B8B6](https://testnet.bscscan.com/address/0x1B1abEeAA98Dee1daC97c027ed237F479907B8B6)

CustomToken deployed with address: [0xC5b816D272fC22864403f851d92E5e92dFe02304](https://testnet.bscscan.com/address/0xC5b816D272fC22864403f851d92E5e92dFe02304)

MarketPlace deployed with address: [0xd960ACb79f7847501d64D4CBA915EEEca31d2457](https://testnet.bscscan.com/address/0xd960ACb79f7847501d64D4CBA915EEEca31d2457)

### Goerli

CustomNFT deployed with address: [0x1B1abEeAA98Dee1daC97c027ed237F479907B8B6](https://goerli.etherscan.io/address/0x1B1abEeAA98Dee1daC97c027ed237F479907B8B6)

CustomToken deployed with address: [0xC5b816D272fC22864403f851d92E5e92dFe02304](https://goerli.etherscan.io/address/0xC5b816D272fC22864403f851d92E5e92dFe02304)

MarketPlace deployed with address: [0xd960ACb79f7847501d64D4CBA915EEEca31d2457](https://goerli.etherscan.io/address/0xd960ACb79f7847501d64D4CBA915EEEca31d2457)

### Rinkeby (!can be deprecated soon)

CustomNFT deployed with address: [0x1B1abEeAA98Dee1daC97c027ed237F479907B8B6](https://rinkeby.etherscan.io/address/0x1B1abEeAA98Dee1daC97c027ed237F479907B8B6)

CustomToken deployed with address: [0xC5b816D272fC22864403f851d92E5e92dFe02304](https://rinkeby.etherscan.io/address/0xC5b816D272fC22864403f851d92E5e92dFe02304)

MarketPlace deployed with address: [0xd960ACb79f7847501d64D4CBA915EEEca31d2457](https://rinkeby.etherscan.io/address/0xd960ACb79f7847501d64D4CBA915EEEca31d2457)


### Polygon Testnet (MATIC)

CustomNFT deployed with address: [0x1B1abEeAA98Dee1daC97c027ed237F479907B8B6](https://mumbai.polygonscan.com/address/0x1B1abEeAA98Dee1daC97c027ed237F479907B8B6)

CustomToken deployed with address: [0xC5b816D272fC22864403f851d92E5e92dFe02304](https://mumbai.polygonscan.com/address/0xC5b816D272fC22864403f851d92E5e92dFe02304)

MarketPlace deployed with address: [0xd960ACb79f7847501d64D4CBA915EEEca31d2457](https://mumbai.polygonscan.com/address/0xd960ACb79f7847501d64D4CBA915EEEca31d2457)

## Using this Project

Clone this repository, then install the dependencies with `npm install`, then compile contracts with `npm run compile`.

### Run Contract Tests & Get Callstacks

`npm run test`

### Run Coverage Report for Tests

`npm run coverage`

### Run docgen

`npm run doc` or `npx hardhat docgen`

The document will be created in the docs folder.

Check about [NatSpec](https://docs.soliditylang.org/en/v0.5.10/natspec-format.html) to know how to describe your contract to docgen.

### Deploy example

Script to deploy CustomToken in rinkeby.

_create .env before._

`npx hardhat run --network rinkeby scripts/deployCustomToken.ts`

### Task example

`npx hardhat getBalanceByAddress --network rinkeby --token TOKEN_ADDRESS --user OWNER_ADDRESS`

### Using Mocha Test Explorer in Visual Studio Code

[Mocha Test Explorer](https://marketplace.visualstudio.com/items?itemName=hbenl.vscode-mocha-test-adapter)
As we are using typescript tests, we nee to add following attribute in *settings.json* file (Visual Studio Code global settings):
`"mochaExplorer.files": "test/**/*.{j,t}s",`

If you see "Mocha: Error" in test explorer, ensure that `npx hardhat test` works.

### Verification example

`npx hardhat verify --network rinkeby CONTRACT_ADDRESS ARG1 ARG2`

To verify upgradable contract - you need use address of implementation as `CONTRACT_ADDRESS`

Btw you can verify your contract with deploy. You can find example how do it in deploy scripts.

### OpenZeppelin Wizard

[Wizard](https://docs.openzeppelin.com/contracts/4.x/wizard) is a useful generator of smart contracts.
