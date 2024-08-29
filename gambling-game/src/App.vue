<template>
  <div class="game-page">
    <!-- 左上角的 Game Introduction -->
    <div class="game-introduction">
      <button @click="toggleIntroduction">Game Introduction</button>
      <transition name="fade">
        <div v-if="showIntroduction" class="introduction-text">
          <p v-for="(paragraph, index) in introductionText" :key="index">
            {{ paragraph }}
          </p>
        </div>
      </transition>
    </div>

    <!-- Connect Wallet/Disconnect Wallet button -->
    <button class="connect-wallet" @click="connectWallet">
      Connect Wallet
      <!-- {{ isConnected ? 'Disconnect Wallet' : 'Connect Wallet' }} -->
    </button>

    <div v-if="isConnected" class="account-info">
      Connected account: {{ currentAccount }}
    </div>
    <div class="center-content">
      <h1>G2 Gambling Game</h1>

      <div class="game-result" v-if="gameResult">
        Game Result: {{ gameResult }}
      </div>

      <!-- 抽奖转盘 -->
      <div class="spinner">
        <div class="spinner-grid">
          <!-- 第一行 4 个元素 -->
          <div class="wheel-element" v-for="(element, index) in wheelElements.slice(0, 4)" :key="index">
            {{ element }}
          </div>
          <!-- 第二行 左右各一个元素，中间是控制区域 -->
          <div class="wheel-element" v-for="(element, index) in wheelElements.slice(4, 5)" :key="index">
            {{ element }}
          </div>
          <div class="controls">
            <input type="number" v-model="coinAmount" placeholder="Enter coin amount" /> 
            <button @click="start">Start</button>
          </div>
          <div class="wheel-element" v-for="(element, index) in wheelElements.slice(5, 6)" :key="index">
            {{ element }}
          </div>
          <!-- 第三行 4 个元素 -->
          <div class="wheel-element" v-for="(element, index) in wheelElements.slice(6, 10)" :key="index">
            {{ element }}
          </div>
        </div>
      </div>

      <!-- 余额及操作按钮 -->
      <div class="balance-controls">
        <button class="action-button" @click="openDepositModal">Deposit</button>
        <div class="balance-info">
          <p>BALANCE: {{ balance }} G2</p>
        </div>
        <button class="action-button" @click="openWithdrawModal">Withdraw</button>
      </div>

      <!-- 轮播文字列表 -->
      <div class="event-list">
        <div class="scrolling-text">
          <div v-for="(event, index) in events" :key="index" class="event-item">
            {{ event }}
          </div>
        </div>
      </div>

    <div v-if="showDepositModal" class="modal">
      <div class="modal-content">
        <span class="close" @click="closeDepositModal">&times;</span>
        <h2>Deposit Game Coins</h2>
        <input type="number" v-model="depositAmount" placeholder="Enter amount" />
        <button @click="deposit">Confirm</button>
      </div>
    </div>

    <div v-if="showWithdrawModal" class="modal">
      <div class="modal-content">
        <span class="close" @click="closeWithdrawModal">&times;</span>
        <h2>Withdraw Game Coins</h2>
        <input type="number" v-model="withdrawAmount" placeholder="Enter amount" />
        <button @click="withdraw">Confirm</button>
      </div>
    </div>

      <!-- End 按钮 -->
      <button class="end-button" @click="end">End</button>
    </div>
  </div>
</template>

<script>
import Web3 from 'web3';
import { reactive, ref, onMounted } from 'vue';

export default {
  setup() {
    const showIntroduction = ref(false);
    const showDepositModal = ref(false);
    const showWithdrawModal = ref(false);
    const withdrawAmount = ref(0);
    const depositAmount = ref(0);
    const introductionText = ref([
      `
The application is an innovative online gaming platform that simulates the atmosphere of a traditional casino but utilizes modern digital assets—specifically Ether (ETH) as the medium of exchange. Users can convert their Ethereum holdings into special in-game tokens, known as game tokens, with an exchange rate set at 1 Ether to 1 game token. This allows users to easily determine their betting amounts in the game based on their Ethereum balance.`,
`When a user is ready to participate in the game, they simply click the "Start" button, and the system automatically activates the roulette feature. At the end of the game, the system automatically calculates the results and distributes the corresponding Ether rewards back to the player's account based on the amount of game tokens wagered and the outcome of the roulette.`,
`This game design not only caters to the entertainment needs of users but also ensures the security and transparency of funds, providing a fun and relatively safe environment for users to enjoy.`
    ]);
    const coinAmount = ref(0);
    const events = reactive([]);
    const wheelElements = ref([]);
    const isConnected = ref(false);
    const currentAccount = ref(null);
    const web3 = ref(null);
    const contract = ref(null);
    const balance = ref(0);
    const gameResult = ref(null);

    const toggleIntroduction = () => {
      showIntroduction.value = !showIntroduction.value;
    };

    const connectWallet = async () => {
      if (window.ethereum) {
        try {
          await window.ethereum.request({ method: 'eth_requestAccounts' });

          web3.value = new Web3(window.ethereum);

          // get account
          const accounts = await web3.value.eth.getAccounts();
          currentAccount.value = accounts[0];
          isConnected.value = true;

          await initContract();
          await initializeData();
        } catch (error) {
          console.error('Error connecting wallet:', error);
        }
      } else {
        alert('Please install MetaMask!');
      }
    };

    const openDepositModal = () => {
      showDepositModal.value = true;
    };

    const closeDepositModal = () =>{
      showDepositModal.value = false;
    }

    const openWithdrawModal = () => {
      showWithdrawModal.value = true;
    };

    const closeWithdrawModal = () => {
      showWithdrawModal.value = false;
    };

    // const disconnectWallet = () => {
    //   web3.value = null;
    //   currentAccount.value = null;
    //   isConnected.value = false;
    //   contract.value = null;
    //   balance.value = 0;
    //   console.log('Disconnected');
    // };

    // const handleWalletAction = () => {
    //   if (isConnected.value) {
    //     disconnectWallet();
    //   } else {
    //     connectWallet();
    //   }
    // };

    const initContract = async () => {
  try {
    // 加载 ABI
    const response = await fetch('/abi.json');
    const abi = await response.json();

    // 初始化合约实例
    const contractAddress = '0x394Ba8dDf74BD27764Ebe9736f6f6A083e9Af0E6'; // 替换为您的合约地址
    contract.value = new web3.value.eth.Contract(abi, contractAddress);

    listenToPlayEvent();
  } catch (error) {
    console.error('Error initializing contract:', error);
  }
};
    const initializeData = async () => {
      if (!contract.value) {
        console.error('Contract is not initialized.');
        return;
      }
      try {
        // 获取轮盘规则
        const rules = await contract.value.methods.getRuls().call();
        wheelElements.value = rules;

        // 获取 G2 Token 余额
        const balanceValue = await contract.value.methods.getG2TokenBalance().call({ from: currentAccount.value });
        balance.value = balanceValue;
      } catch (error) {
        console.error('Error initializing data:', error);
      }
    };

    const start = async () => {
      gameResult.value = "";
      try {
        const number = coinAmount.value;

        if (number < 1) {
          alert("The amount of tokens wagered is less than 1.");
          return;
        }

        // 调用合约的 play 方法
        const result = await contract.value.methods.play(number).send({ from: currentAccount.value });
        // 获取 G2 Token 余额
        const balanceValue = await contract.value.methods.getG2TokenBalance().call({ from: currentAccount.value });
        balance.value = balanceValue;

        // BigInt 转换为字符串
        gameResult.value = result.toString();
        console.log(result);

        // 处理交易结果日志
      if (result.events && result.events.playEvent) {
      const playEvent = result.events.playEvent;
      const topics = playEvent.raw.topics;

      // 提取和处理 topics 中的内容
      const num1 = parseInt(topics[2], 16); // amount of game tokens won
      const num2 = parseInt(topics[3], 16); // rule
      gameResult.value = `You won ${num1} game tokens, \tmultiplier: ${num2}`;
    }
        

      } catch (error) {
        console.error('Error playing game:', error);
      }
    };

    const end = async () => {
      try {
        await contract.value.methods.end().send({ from: currentAccount.value });
        console.log('Game ended and tokens converted to Ether');
      } catch (error) {
        console.error('Error ending game:', error);
      }
    };

    const listenToPlayEvent = () => {
      if (!contract.value) {
        console.error('Contract is not initialized.');
        return;
      }

      console.log('Starting to listen for playEvent...');

      contract.value.events.playEvent({
        fromBlock: 'latest'
      })
      .on('data', (event) => {
        console.log('Event received:', event);
        const rawData = event.raw.data;
        const topics = event.raw.topics;

        try {
          // 数据解析
          const rawDataHex = rawData.substring(2); // time
          const timestamp = parseInt(rawDataHex, 16); 
          const date = new Date(timestamp * 1000); 
          const formattedDate = date.toLocaleString(); 
          const address = '0x' + topics[1].substring(26); // address
          const num1 = parseInt(topics[2], 16); // amount of game tokens won
          const num2 = parseInt(topics[3], 16); // rule

          const eventMessage = ` ${formattedDate}  \t ${address} \t won ${num1} game token,multiplier: ${num2}`;
          events.push(eventMessage);

          // 打印更新后的 events 数组
          console.log('Updated events:', events);
        } catch (error) {
          console.error('Error processing event data:', error);
        }
      })
      .on('error', (error) => {
        console.error('Error listening to playEvent:', error);
      });
    };

    // call deposit
    const deposit = async () => {
  if (depositAmount.value <= 0) {
    alert('Please enter a valid amount.');
    return;
  }
  try {
    await contract.value.methods.deposit(depositAmount.value).send({
      from: currentAccount.value,
      value: web3.value.utils.toWei(depositAmount.value.toString(), 'ether') 
    });
    console.log('Deposit successful');
    closeDepositModal(); 
    const balanceValue = await contract.value.methods.getG2TokenBalance().call({ from: currentAccount.value });
    balance.value = balanceValue;
  } catch (error) {
    console.error('Error depositing coins:', error);
  }
};

    const withdraw = async () => {
  if (withdrawAmount.value <= 0) {
    alert('Please enter a valid amount.');
    return;
  }
  try {
    await contract.value.methods.withdraw(withdrawAmount.value).send({
      from: currentAccount.value
    });
    console.log('Withdrawal successful');
    closeWithdrawModal(); 
    const balanceValue = await contract.value.methods.getG2TokenBalance().call({ from: currentAccount.value });
    balance.value = balanceValue;
  } catch (error) {
    console.error('Error withdrawing coins:', error);
  }
};

    onMounted(async () => {
      if (window.ethereum) {
        web3.value = new Web3(window.ethereum);
        const accounts = await web3.value.eth.getAccounts();
        if (accounts.length > 0) {
          currentAccount.value = accounts[0];
          isConnected.value = true;
          await initContract();
          await initializeData();
        }
      } else {
        console.warn('MetaMask is not installed.');
      }
    });

    return {
      showIntroduction,
      showWithdrawModal,
      withdrawAmount ,
      depositAmount,
      introductionText,
      showDepositModal,
      coinAmount,
      events,
      wheelElements,
      isConnected,
      currentAccount,
      balance,
      gameResult,
      toggleIntroduction,
      connectWallet,
      openDepositModal,
      openWithdrawModal,
      closeWithdrawModal ,
      closeDepositModal,
      initContract,
      initializeData,
      start,
      listenToPlayEvent,
      end,
      deposit,
      withdraw
    };
  }
};
</script>



<style scoped>
.modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
}
.modal-content {
  position: relative;
  background: white;
  padding: 20px;
  border-radius: 8px;
  width: 300px;
  max-width: 100%;
}
.close {
  position: absolute;
  top: 10px;
  right: 10px;
  color:#0056b3;
  cursor: pointer;
  font-size: 20px;
}
/* 整体布局 */
.game-page {
  display: flex;
  flex-direction: column;
  align-items: center;
  height: 100vh;
  padding: 20px;
  background-color: #f4f6f9;
}

/* 左上角的 Game Introduction */
.game-introduction {
  position: absolute;
  top: 20px;
  left: 20px;
  max-width: 300px; 
}

.introduction-text {
  margin-top: 10px;
  line-height: 1.6;
  color: #444;
  background-color: #f0f4f8;
  padding: 15px;
  border-radius: 8px;
  border: 1px solid #e1e4e8;
  box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.1);
  font-family: 'Arial', sans-serif;
  font-size: 14px;
}

.fade-enter-active, .fade-leave-active {
  transition: opacity 0.5s;
}

.fade-enter, .fade-leave-to {
  opacity: 0;
}


.connect-wallet {
  position: absolute;
  top: 20px;
  right: 20px;
  background-color: #28a745;
  color: white;
  padding: 10px 20px;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 14px;
  box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.1);
  transition: background-color 0.3s;
}

.connect-wallet:hover {
  background-color: #218838;
}


.account-info {
  position: absolute;
  top: 70px;
  right: 20px;
  background-color: #f0f4f8;
  padding: 10px;
  border-radius: 8px;
  border: 1px solid #e1e4e8;
  box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.1);
  color: #333;
  font-size: 14px;
}


.center-content {
  text-align: center;
  margin-top: 80px;
  max-width: 80vw;
  width: 100%; 
  box-sizing: border-box;
}

/* 标题样式 */
h1 {
  font-family: 'Arial', sans-serif;
  color: #333;
  font-size: 36px;
  margin-bottom: 40px;
}

/* 抽奖转盘样式 */
.spinner {
  display: flex;
  justify-content: center;
  width: 100%;
}

.spinner-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr); 
  grid-template-rows: repeat(3, 1fr);
  gap: 10px; 
  max-width: 400px; 
  width: 100%; 
  height: 300px; 
  grid-template-areas:
    "a a a a"
    "b c c d"
    "e e e f";
}
.wheel-element {
  background-color: #007bff;
  color: white;
  padding: 20px;
  border-radius: 8px; 
  text-align: center;
  font-size: 14px;
  box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.1);
  transition: transform 0.3s;
  display: flex;
  justify-content: center;
  align-items: center;
}

.wheel-element:hover {
  transform: scale(1.1);
}

.controls {
  grid-area: c;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
}

input[type="number"] {
  padding: 10px;
  border: 2px solid #ccc;
  border-radius: 5px;
  margin-bottom: 10px;
  font-size: 16px;
  text-align: center;
  width: 100px; 
}

button {
  background-color: #007bff;
  color: white;
  padding: 10px 20px;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 16px;
  transition: background-color 0.3s;
}

button:hover {
  background-color: #0056b3;
}

.event-list {
  margin-top: 20px; 
  font-size: 16px;
  color: #555;
  background-color: #fff;
  padding: 10px;
  border-radius: 8px;
  box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.1);
  overflow: hidden;
  height: 100px;
  /* max-width: 400px; */
  width: 100%;
  box-sizing: border-box; 
}

.scrolling-text {
  display: flex;
  flex-direction: column;
  height: 100%;
  animation: scroll-up 10s linear infinite;
}

@keyframes scroll-up {
  0% {
    transform: translateY(100%);
  }
  100% {
    transform: translateY(-100%);
  }
}

.event-item {
  padding: 10px 0;
  text-align: center;
}

.balance-controls {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 20px;
  margin-top: 20px;
}

.action-button {
  background-color: #007bff;
  color: white;
  padding: 10px 20px;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 16px;
  transition: background-color 0.3s;
}

.action-button:hover {
  background-color: #0056b3;
}

.balance-info {
  font-size: 16px;
  color: #333;
}

.end-button {
  background-color: #dc3545;
  color: white;
  padding: 10px 20px;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 16px;
  transition: background-color 0.3s;
}

.end-button:hover {
  background-color: #c82333;
}
</style>
