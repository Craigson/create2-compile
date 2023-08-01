## CREATE2 deploy experiments

Foundry uses a "deterministic deployment proxy" when doing salted contract creating via scripts, you can read more about how it works here: https://github.com/Arachnid/deterministic-deployment-proxy

The contract is deployed on testnets, and mainnet, at `0x4e59b44847b379578588920cA78FbF26c0B4956C`.

We want to test using this factory to deploy contracts on local nodes using both hardhat and foundry.

The factory is not present by default on local nodes, so we'll use some environment specific tools to make sure the contracts are present on each network.


## Deploy using anvil

Run a local anvil node:

```shell
anvil
```

Next, you'll need to set the code for the constant address deployer.

Copy/paste and execute the following command into your terminal and execute it to achieve this:

```bash
curl --location 'localhost:8545/' \
--header 'Content-Type: application/json' \
--data '{
"jsonrpc":"2.0",
"method":"anvil_setCode",
"params":[
"0x4e59b44847b379578588920cA78FbF26c0B4956C",
"0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe03601600081602082378035828234f58015156039578182fd5b8082525050506014600cf3"
],
"id":67
}'
```

Finally, deploy the test contract.

```
forge script --optimizer-runs 200 scripts/foundry/deploy.s.sol --rpc-url http://127.0.0.1:8545 --broadcast 
```

## Deploy using hardhat

```shell
npm install
```

```shell
npx hardhat run script/deploy.ts
```