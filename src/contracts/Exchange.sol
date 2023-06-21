// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./Token.sol";

contract Exchange {
    using SafeMath for uint256;
    address public feeaccount;
    uint256 public feepercent;
    uint256 public id;
    address constant ETHER = address(0);
    mapping(address => mapping(address => uint256)) public tokens;
    mapping(uint256 => _Order) public orders;
    mapping(uint256 => bool) public cancelOrder;
    mapping(uint256 => bool) public orderFilled;
    event Deposit(
        address token,
        address sender,
        uint256 amount,
        uint256 balance
    );
    event Order(
        uint256 id,
        address user,
        address tokenGet,
        uint256 amountGet,
        address tokenGive,
        uint256 amountGive,
        uint256 timestamp
    );
    event Cancel(
        uint256 id,
        address user,
        address tokenGet,
        uint256 amountGet,
        address tokenGive,
        uint256 amountGive,
        uint256 timestamp
    );
    event Trade(
        uint256 id,
        address user,
        address tokenGet,
        uint256 amountGet,
        address tokenGive,
        uint256 amountGive,
        address userFill,
        uint256 timestamp
    );

    struct _Order {
        uint id;
        address user;
        address tokenGet;
        uint amountGet;
        address tokenGive;
        uint amountGive;
        uint timestamp;
    }

    constructor(address _feeaccount, uint256 _feepercent) public {
        feeaccount = _feeaccount;
        feepercent = _feepercent;
    }

    //  _token depicts my created specific ERC20 Token

    function depositToken(address _token, uint _amount) public {
        require(_token != ETHER);
        // having address of a particular ERC20 token and accesssing it
        require(Token(_token).transferfrom(msg.sender, address(this), _amount));
        tokens[_token][msg.sender] = tokens[_token][msg.sender].add(_amount);
        emit Deposit(_token, msg.sender, _amount, tokens[_token][msg.sender]);
    }

    function depositETHER() public payable {
        tokens[ETHER][msg.sender] = tokens[ETHER][msg.sender].add(msg.value);
        emit Deposit(ETHER, msg.sender, msg.value, tokens[ETHER][msg.sender]);
    }

    function withdrawETHER(uint256 amount) public {
        require(amount <= tokens[ ETHER][msg.sender]);
        tokens[ETHER][msg.sender] = tokens[ETHER][msg.sender].sub(amount);
        msg.sender.transfer(amount);
        //   emit Deposit(ETHER,msg.sender,_amount, tokens[ETHER][msg.sender]);
    }

    function withdrawToken(address token, uint256 amount) public {
        require(token != ETHER);
        require(amount <= tokens[ETHER][msg.sender]);

        tokens[token][msg.sender] = tokens[token][msg.sender].sub(amount);
        require(Token(token).transfer(msg.sender, amount));
        //   emit Deposit(ETHER,msg.sender,_amount, tokens[ETHER][msg.sender]);
    }

    function balance_of(
        address _token,
        address _user
    ) public view returns (uint256) {
        return (tokens[_token][_user]);
    }

    function makeOrder(
        address _tokenget,
        uint256 _amountget,
        address _tokengive,
        uint256 _amountgive
    ) public {
        id = id.add(1);
        orders[id] = _Order(
            id,
            msg.sender,
            _tokenget,
            _amountget,
            _tokengive,
            _amountgive,
            now
        );
        emit Order(
            id,
            msg.sender,
            _tokenget,
            _amountget,
            _tokengive,
            _amountgive,
            now
        );
    }

    function cancelOrder2(uint256 _id) public {
        _Order storage order = orders[_id];
        require(address(order.user) == msg.sender);
        require(order.id == id);
        cancelOrder[_id] = true;
        emit Cancel(
            order.id,
            msg.sender,
            order.tokenGet,
            order.amountGet,
            order.tokenGive,
            order.amountGive,
            now
        );
    }

    function fillOrder(uint256 _id) public {
        require(_id > 0 && _id <= id, "Error, wrong id");
        require(!orderFilled[_id], "Error, order already filled");
        require(!cancelOrder[_id], "Error, order already cancelled");
        _Order storage _order = orders[_id];
        _trade(
            _order.id,
            _order.user,
            _order.tokenGet,
            _order.amountGet,
            _order.tokenGive,
            _order.amountGive
        );
        orderFilled[_order.id] = true;
    }

    function _trade(
        uint256 _orderId,
        address _user,
        address _tokenGet,
        uint256 _amountGet,
        address _tokenGive,
        uint256 _amountGive
    ) internal {
        uint256 _feeAmount = _amountGet.mul(feepercent).div(100);

        tokens[_tokenGet][msg.sender] = tokens[_tokenGet][msg.sender].sub(
            _amountGet.add(_feeAmount)
        );
        tokens[_tokenGet][_user] = tokens[_tokenGet][_user].add(_amountGet);
        tokens[_tokenGet][feeaccount] = tokens[_tokenGet][feeaccount].add(
            _feeAmount
        );
        tokens[_tokenGive][_user] = tokens[_tokenGive][_user].sub(_amountGive);
        tokens[_tokenGive][msg.sender] = tokens[_tokenGive][msg.sender].add(
            _amountGive
        );

        emit Trade(
            _orderId,
            _user,
            _tokenGet,
            _amountGet,
            _tokenGive,
            _amountGive,
            msg.sender,
            now
        );
    }
}
