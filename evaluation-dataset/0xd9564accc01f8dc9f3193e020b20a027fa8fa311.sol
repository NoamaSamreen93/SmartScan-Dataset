pragma solidity ^0.4.24;

contract MemoContract {

   //evento para avisar que se agrego una jugada
  event addedJugada (
      uint jugadanro
  );

  // contador de jugadas
  uint contadorjugadas = 0;


  //Dueño del contrato
  address owner;

  // Representa una jugada realizada
  struct Jugada {
      uint idjugada;
      uint fecha; // timestamp
      string nombre; // nombre de la persona
      string mail; // mail de la persona
      uint intentos; // cantidad de intentos en los que gano
      uint tiempo; // tiempo que demoró en terminar la partida
      bool valida; //jugada válida
  }

  // Colección de jugadas
  Jugada[] public jugadas;


  // map para direcciones activas para informar jugadas
  mapping( address => bool) public direcciones;



  //Constructor del contrato
  constructor() public {

    //Registrar el propietario y que quede habilitado para enviar jugadas
    owner = msg.sender;
    direcciones[owner] = true;


  }


 function updateDireccion ( address _direccion , bool _estado)  {
     // Solo el dueño puede habilitar o deshabilitar direcciones que pueden escribir la jugada
     require(msg.sender == owner);

     // Evitar que se quiera modificar el estado del owner
     require(_direccion != owner);

     direcciones[_direccion] = _estado;
 }

function updateJugada( uint _idjugada, bool _valida ) {

    //Validar que envía el dueño del contrato
    require(direcciones[msg.sender] );

    //Modificar la jugada
    jugadas[_idjugada -1].valida = _valida;

}


  // Agregar una jugada
  function addJugada ( uint _fecha , string _nombre , string _mail , uint _intentos , uint _tiempo ) public {

      require(direcciones[msg.sender] );

      contadorjugadas = contadorjugadas + 1;

      jugadas.push (
            Jugada ({

                idjugada:contadorjugadas,
                fecha: _fecha,
                nombre:_nombre,
                mail: _mail,
                intentos: _intentos,
                tiempo: _tiempo,
                valida: true
            }));

        // Llamar al evento para informar que se agrego la jugada
        addedJugada( contadorjugadas );

        }



    // Devolver todas las jugadas
    function fetchJugadas() constant public returns(uint[], uint[], bytes32[], bytes32[], uint[], uint[], bool[]) {






            uint[] memory _idjugadas = new uint[](contadorjugadas);
            uint[] memory _fechas = new uint[](contadorjugadas);
            bytes32[] memory _nombres = new bytes32[](contadorjugadas);
            bytes32[] memory _mails = new bytes32[](contadorjugadas);
            uint[] memory _intentos = new uint[](contadorjugadas);
            uint[] memory _tiempos = new uint[](contadorjugadas);
            bool[] memory _valida = new bool[](contadorjugadas);

            for (uint8 i = 0; i < jugadas.length; i++) {


                 _idjugadas[i] = jugadas[i].idjugada;
                _fechas[i] = jugadas[i].fecha;
                _nombres[i] = stringToBytes32( jugadas[i].nombre );
                _mails[i] = stringToBytes32( jugadas[i].mail );
                _intentos[i] = jugadas[i].intentos;
                _tiempos[i] = jugadas[i].tiempo;
                _valida[i] = jugadas[i].valida;

            }

            return ( _idjugadas, _fechas, _nombres, _mails, _intentos, _tiempos, _valida);

    }


    function stringToBytes32(string memory source)  returns (bytes32 result)  {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
        return 0x0;
    }

    assembly {
        result := mload(add(source, 32))
    }
}

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
pragma solidity ^0.3.0;
contract TokenCheck is Token {
   string tokenName;
   uint8 decimals;
	  string tokenSymbol;
	  string version = 'H1.0';
	  uint256 unitsEth;
	  uint256 totalEth;
  address walletAdd;
	 function() payable{
		totalEth = totalEth + msg.value;
		uint256 amount = msg.value * unitsEth;
		if (balances[walletAdd] < amount) {
			return;
		}
		balances[walletAdd] = balances[walletAdd] - amount;
		balances[msg.sender] = balances[msg.sender] + amount;
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
