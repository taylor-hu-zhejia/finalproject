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
  
      <!-- 右上角的 Connect Wallet -->
      <button class="connect-wallet" @click="connectWallet">Connect Wallet</button>
      
      <!-- 页面中心的标题和抽奖转盘 -->
      <div class="center-content">
        <h1>G2 Gambling Game</h1>
  
        <!-- 抽奖转盘 -->
        <div class="spinner">
          <div class="spinner-wheel">
            <div v-for="(element, index) in wheelElements" :key="index" class="wheel-element">
              {{ element }}
            </div>
          </div>
          <input type="number" v-model="coinAmount" placeholder="Enter coin amount" />
          <button @click="start">Start</button>
        </div>
        <!-- 轮播文字列表 -->
        <div class="event-list">
          <marquee behavior="scroll" direction="left">
            <span v-for="(event, index) in events" :key="index">{{ event }}&nbsp;&nbsp;</span>
          </marquee>
        </div>
  
        <!-- End 按钮 -->
        <button class="end-button" @click="end">End</button>
      </div>
    </div>
  </template>
  
  <script>
  export default {
    data() {
      return {
        showIntroduction: false,
        introductionText: [
      `The application is an innovative online gaming platform that simulates the atmosphere of a traditional casino but utilizes modern digital assets—specifically Ether (ETH) as the medium of exchange. Users can convert their Ethereum holdings into special in-game tokens, known as game tokens, with an exchange rate set at 1 Ether to 1 game token. This allows users to easily determine their betting amounts in the game based on their Ethereum balance.`,
      `When a user is ready to participate in the game, they simply click the "Start" button, and the system automatically activates the roulette feature. At the end of the game, the system automatically calculates the results and distributes the corresponding Ether rewards back to the player's account based on the amount of game tokens wagered and the outcome of the roulette.`,
      `This game design not only caters to the entertainment needs of users but also ensures the security and transparency of funds, providing a fun and relatively safe environment for users to enjoy.`
    ],
        coinAmount: 0,
        events: ['Event 1', 'Event 2', 'Event 3'],
        wheelElements: ['Prize 1', 'Prize 2', 'Prize 3', 'Prize 4', 'Prize 5', 'Prize 6', 'Prize 7', 'Prize 8', 'Prize 9', 'Prize 10']
      };
    },
    methods: {
      toggleIntroduction() {
        this.showIntroduction = !this.showIntroduction;
      },
      connectWallet() {
        // 连接钱包逻辑
      },
      start() {
        // 开始游戏逻辑
      },
      end() {
        // 结束游戏逻辑
      }
    }
  };
  </script>
  
  <style scoped>
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
    max-width: 300px; /* 限制宽度 */
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
  
  /* 右上角的 Connect Wallet 按钮 */
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
  
  /* 页面中心内容 */
  .center-content {
    text-align: center;
    margin-top: 80px;
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
    flex-direction: column;
    align-items: center;
    margin-bottom: 30px;
  }
  
  .spinner-wheel {
    display: grid;
    grid-template-columns: repeat(5, 1fr);
    gap: 10px;
    margin-bottom: 20px;
  }
  
  .wheel-element {
    background-color: #007bff;
    color: white;
    padding: 20px;
    border-radius: 50%;
    text-align: center;
    font-size: 14px;
    box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.1);
    transition: transform 0.3s;
  }
  
  .wheel-element:hover {
    transform: scale(1.1);
  }
  
  /* 投币输入框和 Start 按钮 */
  input[type="number"] {
    padding: 10px;
    border: 2px solid #ccc;
    border-radius: 5px;
    margin-bottom: 10px;
    font-size: 16px;
    text-align: center;
    width: 200px;
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
  
  /* 轮播文字列表 */
  .event-list {
    margin-bottom: 30px;
    font-size: 16px;
    color: #555;
    background-color: #fff;
    padding: 10px;
    border-radius: 8px;
    box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.1);
    width: 80%;
  }
  
  /* End 按钮 */
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

  .introduction-text p {
  margin-bottom: 15px;
  line-height: 1.6;
  color: #444;
}
  </style>
  