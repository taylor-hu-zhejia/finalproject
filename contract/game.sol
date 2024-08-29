pragma solidity >= 0.5.0 < 0.6.0; 

contract gameblingGame {
   event playEvent(address indexed player ,uint256  time, uint256 indexed amount,uint256 indexed rule);

   //合约拥有者
   address public  owner;

    //最小规则id
   uint256 constant private  MIN_RULE_ID=1;

    //最大规则id
    uint256 constant private  MAX_RULE_ID=10;

    //最小投入游戏币数量金额
    uint256 public MIN_TOKRN_NUMBER = 1;

    //用户游戏币余额
    mapping (address => uint256)  private g2TokenBalance;
    
    //中奖规则
    uint256[MAX_RULE_ID] public rule;
    
    //@dev 初始化参数
    constructor(uint256[] memory rules) public {
      for(uint i=0;i< rules.length; i++ ) {
         rule[i]= rules[i];
      }

      owner = msg.sender;
    }


   // @notice 启动游戏
   // @param number 投入游戏币的数量
   function play(uint256 number) public returns (uint256){

      //投入数量不能低于最小投币数量
      require(number>=MIN_TOKRN_NUMBER,"");

      //投币数量不能超过实际拥有游戏币数量
      require(g2TokenBalance[msg.sender]>=number,"Insufficient G2 token balance");

      //开启转盘
      g2TokenBalance[msg.sender]-=number;
      uint256 ruleId =processPrizes(number);

      return ruleId;
   }

  // @notion 结束本轮游戏，将游戏币兑换后以太币，发放给用户
   function end() public  {
      withdraw(g2TokenBalance[msg.sender]);
   }

   // @notice 生成1-10的随机数
   function generateRandomNumber()  private view   returns(uint256)  {
      uint256 randomHash = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender)));
      uint256 randomNumber = uint256(randomHash % MAX_RULE_ID + MIN_RULE_ID);
      return randomNumber;
   }

   // @notic 转盘
   // @param number 投入游戏币的数量
   function processPrizes(uint256 number) private   returns(uint256){

      //生成随机数
      uint256 randomNumber = generateRandomNumber();
      //根据随机数获取转盘对应的值
      uint256 resultRule=rule[randomNumber-1];
       //计算中奖金额
      uint256 winningAmount = resultRule * number;

      //将游戏币奖励发放回账户
      if (winningAmount > 0) {
         g2TokenBalance[msg.sender]+=winningAmount;
      }
      
      emit playEvent(msg.sender,block.timestamp,winningAmount,resultRule);

      return randomNumber-1;
   }

   // @notice 充值游戏币
   // @param number 要充值的游戏币数量
   function deposit(uint256 number) public payable  {
      //判断实际充值金额是否与number相符
      require(msg.value >= number * 1e18,"Insufficient ETH sent: please send at least the required amount");

      //将游戏币充值至账户
      g2TokenBalance[msg.sender]+=number;
   }
   
   // @notice 查询账户游戏币余额
   function getG2TokenBalance()public view  returns(uint256) {
      return g2TokenBalance[msg.sender];
   }

   // @notice 将游戏币提取至账户
   // @param number 要提取的游戏币数量
   function withdraw(uint256 number) public   {
      //检查要提取的金额是否超过账户本身余额
      require(g2TokenBalance[msg.sender]>= number,"Insufficient G2 token balance");
      //检查合约余额是否充足
      require(address(this).balance >= number * 1 ether,"Insufficient contract balance");

      g2TokenBalance[msg.sender] -= number;
      address payable recipient = msg.sender;
      recipient.transfer(number * 1 ether);
   }

   //@notice 将合约中的余额提取至owner账户中
   // @param number 要提取的游戏币数量
   function withdrawOwner(uint256 number) external  {
      require(msg.sender==owner);
      //检查合约余额是否充足
      require(address(this).balance >= number,"Insufficient contract balance");
      address payable recipient = msg.sender;
      recipient.transfer(number * 1 ether);
   }
  
}