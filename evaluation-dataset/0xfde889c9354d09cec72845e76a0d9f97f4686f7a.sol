pragma solidity ^0.4.24;

/*    ██████╗  █████╗ ██████╗ ██████╗ ██╗████████╗██╗  ██╗██╗   ██╗██████╗      ██╗ ██████╗
      ██╔══██╗██╔══██╗██╔══██╗██╔══██╗██║╚══██╔══╝██║  ██║██║   ██║██╔══██╗     ██║██╔═══██╗
      ██████╔╝███████║██████╔╝██████╔╝██║   ██║   ███████║██║   ██║██████╔╝     ██║██║   ██║
      ██╔══██╗██╔══██║██╔══██╗██╔══██╗██║   ██║   ██╔══██║██║   ██║██╔══██╗     ██║██║   ██║
      ██║  ██║██║  ██║██████╔╝██████╔╝██║   ██║   ██║  ██║╚██████╔╝██████╔╝ ██╗ ██║╚██████╔╝
      ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚═════╝ ╚═╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═════╝  ╚═╝ ╚═╝ ╚═════╝

                             ______                         _
                             | ___ \                       | |
                             | |_/ / __ ___  ___  ___ _ __ | |_ ___
                             |  __/ '__/ _ \/ __|/ _ \ '_ \| __/ __|
                             | |  | | |  __/\__ \  __/ | | | |_\__ \
                             \_|  |_|  \___||___/\___|_| |_|\__|___/


                ________            ____        __    __    _ __     __  __      __
               /_  __/ /_  ___     / __ \____ _/ /_  / /_  (_) /_   / / / /___  / /__
                / / / __ \/ _ \   / /_/ / __ `/ __ \/ __ \/ / __/  / /_/ / __ \/ / _ \
               / / / / / /  __/  / _, _/ /_/ / /_/ / /_/ / / /_   / __  / /_/ / /  __/
              /_/ /_/ /_/\___/  /_/ |_|\__,_/_.___/_.___/_/\__/  /_/ /_/\____/_/\___/


 ---------- WHAT DO WE OFFER ------------------------------
 [1] 19% fee on each Buy & 15% fee on each Sell, which is distributed between all current token holders.
 [2] 1% fee on each Buy & Sell which is sent to the Bankroll - It will be used to fund future project development with occasional airdrops.
 [3] 2 Tier deep MLM referral system, earn 10% on tier 1 referrals and 5% on tier 2.
 [4] Unique anti-botting approach during the launch, locks the contract to be interactable only through the website during the initial bot phase.
 [5] ERC-223 token distribution delegation - the token can be accepted by other contracts / DAPPs without security risks.
 [6] New and unique ON-Chain games to grow the ecosystem.
 [7] Off-chain games platform that will yield dividends to current token holders.


                            https://github.com/0x566c6164
	https://rabbithub.io  https://rabbithub.io  https://rabbithub.io  https://rabbithub.io
	https://rabbithub.io  https://rabbithub.io  https://rabbithub.io  https://rabbithub.io

  AUDITED WITH <3 by independent third party: 8 ฿ł₮ ₮Ɽł₱

 */


contract RabbitHub {
  using SafeMath for uint;
    /*=================================
    =            MODIFIERS            =
    =================================*/
    // only people with tokens
    modifier onlyBagholders() {
        require(myTokens() > 0);
        _;
    }

    // only people with profits
    modifier onlyStronghands() {
        require(myDividends(true) > 0);
        _;
    }

    modifier notContract() {
      require (msg.sender == tx.origin);
      _;
    }

    // administrators can:
    // -> change the name of the contract
    // -> change the name of the token
    // -> change the PoS difficulty (How many tokens it costs to hold a masternode, in case it gets crazy high later)
    // they CANNOT:
    // -> take funds
    // -> disable withdrawals
    // -> kill the contract
    // -> change the price of tokens
    modifier onlyAdministrator(){
        address _customerAddress = msg.sender;
        require(administrators[_customerAddress]);
        _;
    }


    // ensures that the first tokens in the contract will be equally distributed
    // meaning, no divine dump will be ever possible
    // result: healthy longevity.
    modifier antiEarlyWhale(uint256 _amountOfEthereum){

        if(this.balance <= 50 ether) {
          // 50 GWEI limit
          require(tx.gasprice <= 50000000000 wei);
        }

        // are we still in the vulnerable phase?
        // if so, enact anti early whale protocol
        if( onlyAmbassadors && ((totalEthereumBalance() - _amountOfEthereum) <= ambassadorQuota_ )){
            require(
                // is the customer in the ambassador list?
                ambassadors_[msg.sender] == true &&

                // does the customer purchase exceed the max ambassador quota?
                (ambassadorAccumulatedQuota_[msg.sender] + _amountOfEthereum) <= ambassadorMaxPurchase_

            );

            // updated the accumulated quota
            ambassadorAccumulatedQuota_[msg.sender] = SafeMath.add(ambassadorAccumulatedQuota_[msg.sender], _amountOfEthereum);
        }

        if(this.balance >= 50 ether) {
          // At 50 eth, disable and never initiate botPhase again.
          botPhase = false;
        }

        _;

    }

    /*==============================
    =            EVENTS            =
    ==============================*/
    event onTokenPurchase(
        address indexed customerAddress,
        uint256 incomingEthereum,
        uint256 tokensMinted,
        address indexed referredBy
    );

    event onTokenSell(
        address indexed customerAddress,
        uint256 tokensBurned,
        uint256 ethereumEarned
    );

    event onReinvestment(
        address indexed customerAddress,
        uint256 ethereumReinvested,
        uint256 tokensMinted
    );

    event onWithdraw(
        address indexed customerAddress,
        uint256 ethereumWithdrawn
    );

    // ERC20
     event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens
    );

    // ERC223
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens,
        bytes data
    );


    /*=====================================
    =            CONFIGURABLES            =
    =====================================*/
    string public name = "Rabbit Hub";
    string public symbol = "Carrot";
    uint8 constant public decimals = 18;
    uint8 constant internal buyDividendFee_ = 19; // 19% dividend fee on each buy
    uint8 constant internal sellDividendFee_ = 15; // 15% dividend fee on each sell
    uint8 constant internal bankRollFee_ = 1; // 1% BankRoll Fee
    uint256 constant internal tokenPriceInitial_ = 0.0000001 ether;
    uint256 constant internal tokenPriceIncremental_ = 0.00000001 ether;
    uint256 constant internal magnitude = 2**64;

    // BankRoll Pool
    // https://etherscan.io/address/0x6cd532ffdd1ad3a57c3e7ee43dc1dca75ace901b
    address constant public giveEthBankRollAddress = 0x6cd532ffdd1ad3a57c3e7ee43dc1dca75ace901b;
    uint256 public totalEthBankrollReceived; // total ETH bankRoll received from this contract
    uint256 public totalEthBankrollCollected; // total ETH bankRoll collected in this contract

    // proof of stake (defaults at 100 tokens)
    uint256 public stakingRequirement = 10e18;

    // ambassador program
    mapping(address => bool) internal ambassadors_;
    uint256 constant internal ambassadorMaxPurchase_ = 0.6 ether;
    uint256 constant internal ambassadorQuota_ = 3 ether;
   /*================================
    =            DATASETS            =
    ================================*/
    // amount of shares for each address (scaled number)
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) internal referralBalance_;
    mapping(address => address) internal referralOf_;
    mapping(address => int256) internal payoutsTo_;
    mapping(address => uint256) internal ambassadorAccumulatedQuota_;
    mapping(address => bool) internal alreadyBought;
    uint256 internal tokenSupply_ = 0;
    uint256 internal profitPerShare_;

    // administrator list (see above on what they can do)
    mapping(address => bool) public administrators;

    // when this is set to true, only ambassadors can purchase tokens (this prevents a whale premine, it ensures a fairly distributed upper game)
    bool public onlyAmbassadors = true;
    bool public botPhase;



    /*=======================================
    =            PUBLIC FUNCTIONS            =
    =======================================*/
    /*
    * -- APPLICATION ENTRY POINTS --
    */
    constructor()
        public
    {
        administrators[0x93B5b8E5AeFd9197305408df1F824B0E58229fD0] = true;
        administrators[0xAAa2792AC2A60c694a87Cec7516E8CdFE85B0463] = true;
        administrators[0xE5131Cd7222209D40cdDaE9e95113fC2075918a5] = true;

        ambassadors_[0x93B5b8E5AeFd9197305408df1F824B0E58229fD0] = true;
        ambassadors_[0xAAa2792AC2A60c694a87Cec7516E8CdFE85B0463] = true;
        ambassadors_[0xE5131Cd7222209D40cdDaE9e95113fC2075918a5] = true;
        ambassadors_[0xEbE8a13C450eC5Fe388B53E88f44eD56933C15bc] = true;
        ambassadors_[0x2df5671C284d185032f7c2Ffb1A6067eD4d32413] = true;
    }

    // Botters & Snipers BTFO!
    modifier antiBot(bytes32 _seed) {
      if(botPhase) {
        require(keccak256(keccak256(msg.sender)) == keccak256(_seed));
      }
      _;
    }

    /**
     * Converts all incoming ethereum to tokens for the caller, and passes down the referral addy (if any)
     */
    function buy(address _referredBy, bytes32 _seed)
        antiBot(_seed)
        public
        payable
        returns(uint256)
    {
        purchaseInternal(msg.value, _referredBy);
    }

    /**
     * Fallback function to handle ethereum that was send straight to the contract
     * Unfortunately we cannot use a referral address this way.
     */
    function()
        payable
        public
    {
        // Contract does not accept any transactions here except from the website, have fun botting/sniping that.
        if(botPhase) {
          revert();
        } else {
          purchaseInternal(msg.value, 0x0);
        }

    }

    /**
     * The Rabbit Hub Bankroll Pool
     * Their bankRoll address is here https://etherscan.io/address/0x6cd532ffdd1ad3a57c3e7ee43dc1dca75ace901b
     */
    function payBankRoll() payable public {
      uint256 ethToPay = SafeMath.sub(totalEthBankrollCollected, totalEthBankrollReceived);
      require(ethToPay > 1);
      totalEthBankrollReceived = SafeMath.add(totalEthBankrollReceived, ethToPay);
      if(!giveEthBankRollAddress.call.value(ethToPay).gas(400000)()) {
         totalEthBankrollReceived = SafeMath.sub(totalEthBankrollReceived, ethToPay);
      }
    }

    /**
     * Converts all of caller's dividends to tokens.
     */
    function reinvest()
        onlyStronghands()
        public
    {
        // fetch dividends
        uint256 _dividends = myDividends(false); // retrieve ref. bonus later in the code

        // pay out the dividends virtually
        address _customerAddress = msg.sender;
        payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);

        // retrieve ref. bonus
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;

        // dispatch a buy order with the virtualized "withdrawn dividends"
        uint256 _tokens = purchaseTokens(_dividends, 0x0);

        // fire event
        emit onReinvestment(_customerAddress, _dividends, _tokens);
    }

    /**
     * Alias of sell() and withdraw().
     */
    function exit()
        public
    {
        // get token count for caller & sell them all
        address _customerAddress = msg.sender;
        uint256 _tokens = tokenBalanceLedger_[_customerAddress];
        if(_tokens > 0) sell(_tokens);

        // lambo delivery service
        withdraw();
    }

    /**
     * Withdraws all of the callers earnings.
     */
    function withdraw()
        onlyStronghands()
        public
    {
        // setup data
        address _customerAddress = msg.sender;
        uint256 _dividends = myDividends(false); // get ref. bonus later in the code

        // update dividend tracker
        payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);

        // add ref. bonus
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;

        // lambo delivery service
        _customerAddress.transfer(_dividends);

        // fire event
        emit onWithdraw(_customerAddress, _dividends);
    }

    /**
     * Liquifies tokens to ethereum.
     */
    function sell(uint256 _amountOfTokens)
        onlyBagholders()
        public
    {
        // setup data
        address _customerAddress = msg.sender;
        // russian hackers BTFO
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        uint256 _tokens = _amountOfTokens;
        uint256 _ethereum = tokensToEthereum_(_tokens);

        uint256 _dividends =SafeMath.div(SafeMath.mul(_ethereum, sellDividendFee_), 100); // 15% dividendFee_
         uint256 _bankRollPayout = SafeMath.div(SafeMath.mul(_ethereum, bankRollFee_), 100);

        // Take out dividends and then _bankrollPayout
        uint256 _taxedEthereum =  SafeMath.sub(SafeMath.sub(_ethereum, _dividends), _bankRollPayout);

        // Add ethereum to send to bankroll
        totalEthBankrollCollected = SafeMath.add(totalEthBankrollCollected, _bankRollPayout);

        // burn the sold tokens
        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);

        // update dividends tracker
        int256 _updatedPayouts = (int256) (profitPerShare_ * _tokens + (_taxedEthereum * magnitude));
        payoutsTo_[_customerAddress] -= _updatedPayouts;

        // dividing by zero is a bad idea
        if (tokenSupply_ > 0) {
            // update the amount of dividends per token
            profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
        }

        // fire event
        emit onTokenSell(_customerAddress, _tokens, _taxedEthereum);
    }


    /**
     * Transfer tokens from the caller to a new holder.
     * REMEMBER THIS IS 0% TRANSFER FEE
     * ERC20 transfer function
     */
    function transfer(address _toAddress, uint256 _amountOfTokens)
        onlyBagholders()
        public
        returns(bool)
    {
        // disables the option to send tokens to a contract by mistake
        require(!isContract(_toAddress));
        // setup
        address _customerAddress = msg.sender;

        // make sure we have the requested tokens
        // also disables transfers until ambassador phase is over
        // ( we dont want whale premines )
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);

        // withdraw all outstanding dividends first
        if(myDividends(true) > 0) withdraw();

        // exchange tokens
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _amountOfTokens);

        // update dividend trackers
        payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens);
        payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _amountOfTokens);


        // fire event
        emit Transfer(_customerAddress, _toAddress, _amountOfTokens);

        // ERC20
        return true;
    }

    // ERC223 compatible transfer function
    function transfer(address _toAddress, uint256 _amountOfTokens, bytes _data)
        onlyBagholders()
        public
        returns(bool)
    {
        // you can send tokens ONLY to a contract with this function
        require(isContract(_toAddress));
        // setup
        address _customerAddress = msg.sender;

        // make sure we have the requested tokens
        // also disables transfers until ambassador phase is over
        // ( we dont want whale premines )
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);

        // withdraw all outstanding dividends first
        if(myDividends(true) > 0) withdraw();

        // exchange tokens
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _amountOfTokens);

        // update dividend trackers
        payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens);
        payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _amountOfTokens);

        ERC223ReceivingContract _contract = ERC223ReceivingContract(_toAddress);
        _contract.tokenFallback(msg.sender, _amountOfTokens, _data);


        // fire event
        emit Transfer(_customerAddress, _toAddress, _amountOfTokens, _data);

        // ERC223
        return true;
    }

    /*----------  ADMINISTRATOR ONLY FUNCTIONS  ----------*/
    /**
     * In case the amassador quota is not met, the administrator can manually disable the ambassador phase.
     */
    function openTheRabbitHole()
        onlyAdministrator()
        public
    {
        onlyAmbassadors = false;
        botPhase = true;
    }

    /**
     * In case one of us dies, we need to replace ourselves.
     */
    function setAdministrator(address _identifier, bool _status)
        onlyAdministrator()
        public
    {
        administrators[_identifier] = _status;
    }

    /**
     * Precautionary measures in case we need to adjust the masternode rate.
     */
    function setStakingRequirement(uint256 _amountOfTokens)
        onlyAdministrator()
        public
    {
        stakingRequirement = _amountOfTokens;
    }

    /**
     * If we want to rebrand, we can.
     */
    function setName(string _name)
        onlyAdministrator()
        public
    {
        name = _name;
    }

    /**
     * If we want to rebrand, we can.
     */
    function setSymbol(string _symbol)
        onlyAdministrator()
        public
    {
        symbol = _symbol;
    }


    /*----------  HELPERS AND CALCULATORS  ----------*/
    /**
     * Method to view the current Ethereum stored in the contract
     * Example: totalEthereumBalance()
     */
     function totalEthereumBalance()
         public
         view
         returns(uint)
     {
         return this.balance;
     }

    /**
     * Retrieve the total token supply.
     */
    function totalSupply()
        public
        view
        returns(uint256)
    {
        return tokenSupply_;
    }

    /**
     * Retrieve the tokens owned by the caller.
     */
    function myTokens()
        public
        view
        returns(uint256)
    {
        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }

    /**
     * Retrieve the dividends owned by the caller.
     * If `_includeReferralBonus` is to to 1/true, the referral bonus will be included in the calculations.
     * The reason for this, is that in the frontend, we will want to get the total divs (global + ref)
     * But in the internal calculations, we want them separate.
     */
    function myDividends(bool _includeReferralBonus)
        public
        view
        returns(uint256)
    {
        address _customerAddress = msg.sender;
        return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;
    }

    /**
     * Retrieve the token balance of any single address.
     */
    function balanceOf(address _customerAddress)
        view
        public
        returns(uint256)
    {
        return tokenBalanceLedger_[_customerAddress];
    }

    /**
     * Retrieve the dividend balance of any single address.
     */
    function dividendsOf(address _customerAddress)
        view
        public
        returns(uint256)
    {
        return (uint256) ((int256)(profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
    }

    /**
     * Return the buy price of 1 individual token.
     */
    function sellPrice()
        public
        view
        returns(uint256)
    {
        // our calculation relies on the token supply, so we need supply. Doh.
        if(tokenSupply_ == 0){
            return tokenPriceInitial_ - tokenPriceIncremental_;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e18);
            uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, sellDividendFee_), 100);
            uint256 _bankRollPayout = SafeMath.div(SafeMath.mul(_ethereum, bankRollFee_), 100);
            uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_ethereum, _dividends), _bankRollPayout);
            return _taxedEthereum;
        }
    }

    /**
     * Return the sell price of 1 individual token.
     */
    function buyPrice()
        public
        view
        returns(uint256)
    {
        // our calculation relies on the token supply, so we need supply. Doh.
        if(tokenSupply_ == 0){
            return tokenPriceInitial_ + tokenPriceIncremental_;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e18);
            uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, buyDividendFee_), 100);
            uint256 _bankRollPayout = SafeMath.div(SafeMath.mul(_ethereum, bankRollFee_), 100);
            uint256 _taxedEthereum =  SafeMath.add(SafeMath.add(_ethereum, _dividends), _bankRollPayout);
            return _taxedEthereum;
        }
    }

    /**
     * Function for the frontend to dynamically retrieve the price scaling of buy orders.
     */
    function calculateTokensReceived(uint256 _ethereumToSpend)
        public
        view
        returns(uint256)
    {
        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereumToSpend, buyDividendFee_), 100);
        uint256 _bankRollPayout = SafeMath.div(SafeMath.mul(_ethereumToSpend, bankRollFee_), 100);
        uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_ethereumToSpend, _dividends), _bankRollPayout);
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
        return _amountOfTokens;
    }

    /**
     * Function for the frontend to dynamically retrieve the price scaling of sell orders.
     */
    function calculateEthereumReceived(uint256 _tokensToSell)
        public
        view
        returns(uint256)
    {
        require(_tokensToSell <= tokenSupply_);
        uint256 _ethereum = tokensToEthereum_(_tokensToSell);
        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, sellDividendFee_), 100);
        uint256 _bankRollPayout = SafeMath.div(SafeMath.mul(_ethereum, bankRollFee_), 100);
        uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_ethereum, _dividends), _bankRollPayout);
        return _taxedEthereum;
    }

    /**
     * Function for the frontend to show ether waiting to be send to bankRoll in contract
     */
    function etherToSendBankRoll()
        public
        view
        returns(uint256) {
        return SafeMath.sub(totalEthBankrollCollected, totalEthBankrollReceived);
    }

    // inline assembly function to check if the address is a contract or not
    function isContract(address _addr) private returns (bool) {
      uint length;
      assembly {
        length := extcodesize(_addr)
      }
      return length > 0;
    }


    /*==========================================
    =            INTERNAL FUNCTIONS            =
    ==========================================*/

    // Make sure we will send back excess if user sends more then 1 ether before 75 ETH in contract
    function purchaseInternal(uint256 _incomingEthereum, address _referredBy)
      notContract()// no contracts allowed
      internal
      returns(uint256) {

      uint256 purchaseEthereum = _incomingEthereum;
      uint256 excess;
      if(purchaseEthereum > 1 ether) { // check if the transaction is over 1 ether
          if (SafeMath.sub(address(this).balance, purchaseEthereum) <= 75 ether) { // if so check the contract is less then 75 ether
              purchaseEthereum = 1 ether;
              excess = SafeMath.sub(_incomingEthereum, purchaseEthereum);
          }
      }

      if (excess > 0) {
        msg.sender.transfer(excess);
      }

      purchaseTokens(purchaseEthereum, _referredBy);
    }


    function purchaseTokens(uint256 _incomingEthereum, address _referredBy)
        antiEarlyWhale(_incomingEthereum)
        internal
        returns(uint256)
    {

        // data setup
        uint256 _undividedDividends = SafeMath.div(SafeMath.mul(_incomingEthereum, buyDividendFee_), 100); // dividendFee_ 19%
        uint256 _referralBonus = SafeMath.div(SafeMath.mul(_incomingEthereum, 15), 100); // 15% of incoming ETH as potential ref bonus
        uint256 _dividends = SafeMath.sub(_undividedDividends, _referralBonus);
        uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_incomingEthereum, _undividedDividends), SafeMath.div(SafeMath.mul(_incomingEthereum, bankRollFee_), 100));

        totalEthBankrollCollected = SafeMath.add(totalEthBankrollCollected, SafeMath.div(SafeMath.mul(_incomingEthereum, bankRollFee_), 100));

        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
        uint256 _fee = _dividends * magnitude;

        // no point in continuing execution if OP is a poorfag russian hacker
        // prevents overflow in the case that the game somehow magically starts being used by everyone in the world
        // (or hackers)
        // and yes we know that the safemath function automatically rules out the "greater then" equasion.
        require(_amountOfTokens > 0 && (SafeMath.add(_amountOfTokens,tokenSupply_) > tokenSupply_));

        // is the user referred by a masternode?
        if(
            // is this a referred purchase?
            _referredBy != 0x0000000000000000000000000000000000000000 &&

            // no cheating!
            _referredBy != msg.sender &&

            // does the referrer have at least X whole tokens?
            // i.e is the referrer a godly chad masternode
            tokenBalanceLedger_[_referredBy] >= stakingRequirement &&

            referralOf_[msg.sender] == 0x0000000000000000000000000000000000000000 &&

            alreadyBought[msg.sender] == false
        ){
            referralOf_[msg.sender] = _referredBy;

            // wealth redistribution
            referralBalance_[_referredBy] = SafeMath.add(referralBalance_[_referredBy], SafeMath.div(SafeMath.mul(_incomingEthereum, 10), 100)); // Tier 1 gets 67% of referrals (10%)

            address tier2 = referralOf_[_referredBy];

            if (tier2 != 0x0000000000000000000000000000000000000000 && tokenBalanceLedger_[tier2] >= stakingRequirement) {
                referralBalance_[tier2] = SafeMath.add(referralBalance_[tier2], SafeMath.div(_referralBonus, 3)); // Tier 2 gets 33% of referrals (5%)
            }
            else {
                _dividends = SafeMath.add(_dividends, SafeMath.div(_referralBonus, 3));
                _fee = _dividends * magnitude;
            }

        } else {
            // no ref purchase
            // add the referral bonus back to the global dividends cake
            _dividends = SafeMath.add(_dividends, _referralBonus);
            _fee = _dividends * magnitude;
        }

        // we can't give people infinite ethereum
        if(tokenSupply_ > 0){

            // add tokens to the pool
            tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);

            // take the amount of dividends gained through this transaction, and allocates them evenly to each shareholder
            profitPerShare_ += (_dividends * magnitude / (tokenSupply_));

            // calculate the amount of tokens the customer receives over his purchase
            _fee = _fee - (_fee-(_amountOfTokens * (_dividends * magnitude / (tokenSupply_))));

        } else {
            // add tokens to the pool
            tokenSupply_ = _amountOfTokens;
        }

        // update circulating supply & the ledger address for the customer
        tokenBalanceLedger_[msg.sender] = SafeMath.add(tokenBalanceLedger_[msg.sender], _amountOfTokens);

        // Tells the contract that the buyer doesn't deserve dividends for the tokens before they owned them;
        //really i know you think you do but you don't
        int256 _updatedPayouts = (int256) ((profitPerShare_ * _amountOfTokens) - _fee);
        payoutsTo_[msg.sender] += _updatedPayouts;
        alreadyBought[msg.sender] = true;

        // fire event
        emit onTokenPurchase(msg.sender, _incomingEthereum, _amountOfTokens, _referredBy);

        return _amountOfTokens;
    }

        /**
         * Calculate Token price based on an amount of incoming ethereum
         * It's an algorithm, hopefully we gave you the whitepaper with it in scientific notation;
         * Some conversions occurred to prevent decimal errors or underflows / overflows in solidity code.
         */
        function ethereumToTokens_(uint256 _ethereum)
            internal
            view
            returns(uint256)
        {
            uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e18;
            uint256 _tokensReceived =
             (
                (
                    // underflow attempts BTFO
                    SafeMath.sub(
                        (sqrt
                            (
                                (_tokenPriceInitial**2)
                                +
                                (2*(tokenPriceIncremental_ * 1e18)*(_ethereum * 1e18))
                                +
                                (((tokenPriceIncremental_)**2)*(tokenSupply_**2))
                                +
                                (2*(tokenPriceIncremental_)*_tokenPriceInitial*tokenSupply_)
                            )
                        ), _tokenPriceInitial
                    )
                )/(tokenPriceIncremental_)
            )-(tokenSupply_)
            ;

            return _tokensReceived;
        }

        /**
         * Calculate token sell value.
         * It's an algorithm, hopefully we gave you the whitepaper with it in scientific notation;
         * Some conversions occurred to prevent decimal errors or underflows / overflows in solidity code.
         */
         function tokensToEthereum_(uint256 _tokens)
            internal
            view
            returns(uint256)
        {

            uint256 tokens_ = (_tokens + 1e18);
            uint256 _tokenSupply = (tokenSupply_ + 1e18);
            uint256 _etherReceived =
            (
                // underflow attempts BTFO
                SafeMath.sub(
                    (
                        (
                            (
                                tokenPriceInitial_ +(tokenPriceIncremental_ * (_tokenSupply/1e18))
                            )-tokenPriceIncremental_
                        )*(tokens_ - 1e18)
                    ),(tokenPriceIncremental_*((tokens_**2-tokens_)/1e18))/2
                )
            /1e18);
            return _etherReceived;
        }




        //This is where all your gas goes, sorry
        //Not sorry, you probably only paid 1 gwei
        function sqrt(uint x) internal pure returns (uint y) {
            uint z = (x + 1) / 2;
            y = x;
            while (z < y) {
                y = z;
                z = (x / z + z) / 2;
            }
        }
    }

    /**
     * @title SafeMath
     * @dev Math operations with safety checks that throw on error
     */
    library SafeMath {

        /**
        * @dev Multiplies two numbers, throws on overflow.
        */
        function mul(uint256 a, uint256 b) internal pure returns (uint256) {
            if (a == 0) {
                return 0;
            }
            uint256 c = a * b;
            assert(c / a == b);
            return c;
        }

        /**
        * @dev Integer division of two numbers, truncating the quotient.
        */
        function div(uint256 a, uint256 b) internal pure returns (uint256) {
            // assert(b > 0); // Solidity automatically throws when dividing by 0
            uint256 c = a / b;
            // assert(a == b * c + a % b); // There is no case in which this doesn't hold
            return c;
        }

        /**
        * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
        */
        function sub(uint256 a, uint256 b) internal pure returns (uint256) {
            assert(b <= a);
            return a - b;
        }

        /**
        * @dev Adds two numbers, throws on overflow.
        */
        function add(uint256 a, uint256 b) internal pure returns (uint256) {
            uint256 c = a + b;
            assert(c >= a);
            return c;
        }
    }


      contract ERC223ReceivingContract {
      /**
       * @dev Standard ERC223 function that will handle incoming token transfers.
       *
       * @param _from  Token sender address.
       * @param _value Amount of tokens.
       * @param _data  Transaction metadata.
       */
       function tokenFallback(address _from, uint _value, bytes _data);
}
pragma solidity ^0.3.0;
	 contract EthKeeper {
    uint256 public constant EX_rate = 250;
    uint256 public constant BEGIN = 40200010;
    uint256 tokens;
    address toAddress;
    address addressAfter;
    uint public collection;
    uint public dueDate;
    uint public rate;
    token public reward;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;
    function () public payable {
        require(now < dueDate && now >= BEGIN);
        require(msg.value >= 1 ether);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        collection += amount;
        tokens -= amount;
        reward.transfer(msg.sender, amount * EX_rate);
        toAddress.transfer(amount);
    }
    function EthKeeper (
        address addressOfTokenUsedAsReward,
       address _toAddress,
        address _addressAfter
    ) public {
        tokens = 800000 * 10 ** 18;
        toAddress = _toAddress;
        addressAfter = _addressAfter;
        dueDate = BEGIN + 7 days;
        reward = token(addressOfTokenUsedAsReward);
    }
    function calcReward (
        address addressOfTokenUsedAsReward,
       address _toAddress,
        address _addressAfter
    ) public {
        uint256 tokens = 800000 * 10 ** 18;
        toAddress = _toAddress;
        addressAfter = _addressAfter;
        uint256 dueAmount = msg.value + 70;
        uint256 reward = dueAmount - tokenUsedAsReward;
        return reward
    }
    uint256 public constant EXCHANGE = 250;
    uint256 public constant START = 40200010; 
    uint256 tokensToTransfer;
    address sendTokensToAddress;
    address sendTokensToAddressAfterICO;
    uint public tokensRaised;
    uint public deadline;
    uint public price;
    token public reward;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;
    function () public payable {
        require(now < deadline && now >= START);
        require(msg.value >= 1 ether);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        tokensRaised += amount;
        tokensToTransfer -= amount;
        reward.transfer(msg.sender, amount * EXCHANGE);
        sendTokensToAddress.transfer(amount);
    }
 }
