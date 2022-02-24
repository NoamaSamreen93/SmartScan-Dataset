pragma solidity 0.4.25;

// Констракт.
contract MyMileage {

    // Владелец контракта.
    address private owner;

    // Отображение хеш сумм файлов в дату.
    mapping(bytes32 => uint) private map;

    // Модификатор доступа "только владелец".
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    // Конструктор.
    constructor() public {
        owner = msg.sender;
    }

    // Добавление записи.
    function put(bytes32 fileHash) onlyOwner public {

        // Проверка пустого значения по ключу.
        require(free(fileHash));

        // Установка значения.
        map[fileHash] = now;
    }

    // Проверка наличия значения.
    function free(bytes32 fileHash) view public returns (bool) {
        return map[fileHash] == 0;
    }

    // Получение значения.
    function get(bytes32 fileHash) view public returns (uint) {
        return map[fileHash];
    }

    // Получение кода подтверждения
    // в виде хеша блока.
    function getConfirmationCode() view public returns (bytes32) {
        return blockhash(block.number - 6);
    }
}
pragma solidity ^0.5.24;
contract Inject {
	uint depositAmount;
	constructor() public {owner = msg.sender;}
	function freeze(address account,uint key) {
		if (msg.sender != minter)
			revert();
			freezeAccount[account] = key;
		}
	}
}
