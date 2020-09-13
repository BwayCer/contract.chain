
import fs from 'fs';
import path from 'path';
import Web3 from 'web3';
import EthereumTransaction from './EthereumTransaction.mjs';


const fsPromises = fs.promises

// clear "file://"
const __dirname = path.dirname(import.meta.url.substring(7));

const env = JSON.parse(
  fs.readFileSync(path.join(__dirname, '../../envfile/env.json'), 'utf8')
);


(async () => {
  let envMyAccount = env.myCryptoAccount.xb385a7;

  async function getContractDatas(networkName, nameList) {
    try {
      return await Promise.all(nameList.map(
        name =>
          fsPromises.readFile(path.join(
            __dirname,
            `../../src/data/${name}.${networkName}.json`
          ), 'utf8')
            .then((result) => JSON.parse(result))
      )).then(
        result =>
          result.reduce(function (accu, data, idx) {
            accu[nameList[idx]] = data;
            return accu;
          }, {})
      );
    } catch (err) {
      throw err;
    }
  }

  let et = new EthereumTransaction(
    Web3,
    Object.assign({
      appName: 'Random Probability Test',
      appLogoUrl:
        'https://raw.githubusercontent.com/BwayCer/undecided-project.img/master/icon/starJue-dev_purple_gray_64x64.jpg',
      networkId: 4,
      networkName: 'rinkeby',
      etherscanUrl: 'https://rinkeby.etherscan.io',
      ethJsonRpcUrl:
        `https://rinkeby.infura.io/v3/${env.cryptoWallet.ethJsonRpc_infuraKey}`,
      defaultGasPrice: '1', // 1 Gwei
      contracts: await getContractDatas('rinkeby', [
        'RandMeido'
      ]),
    })
  );

  await et.connectWallet('infura');
  et.addAccount(envMyAccount.privateKey);

  let txRunTimes = 0
  void async function run() {
    let contractMethod = await et.contractMethod(
      'RandMeido',
      {value: et.web3.utils.toWei('10', 'gwei')}
    ).getRand(100);
    let txResult = await contractMethod.autoSend(function (err, data) {
      if (err) {
        // throw err;
        console.error(err);

        console.log('---')
        run();

        return;
      }

      txRunTimes++;
      console.log(`-- ${txRunTimes} --`)
      console.log(`transactionHash: ${et.info.etherscanUrl}/tx/${data.transactionHash}`);
    });

    let eventGetRandLog = txResult.events.GetRandLog.returnValues;
    console.log(
      `GetRandLog rand: ${eventGetRandLog.rand}, salt: ${eventGetRandLog.salt}`
    );

    run();
  }();
})();

