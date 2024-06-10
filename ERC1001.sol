// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract ERC1001 {
    mapping(address account => uint256) private _balances;
    mapping(address account => mapping(address spender => uint256)) private _allowances;
    mapping(uint256 id => mapping(address account => uint256)) private _balancesNFT;
    mapping(address account => mapping(address operator => bool)) private _operatorApprovals;

    uint256 public totalSupply = 0;
    string public name;
    string public symbol;
    uint8 public decimals;
    string public uri;

    // events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);
    event URI(string value, uint256 indexed id);

    constructor(string memory name_, string memory symbol_, uint8 decimals_, string memory uri_) {
        name = name_;
        symbol = symbol_;
        decimals = decimals_;
        uri = uri_;
    }

    function _setURI(string memory newuri) internal {
        uri = newuri;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function balanceOf(address account, uint256 id) public view virtual returns (uint256) {
        return _balancesNFT[id][account];
    }

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids) public view virtual returns (uint256[] memory) {
        require(accounts.length == ids.length, "ERC1001: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function transfer(address to, uint256 value) public virtual returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function isApprovedForAll(address account, address operator) public view virtual returns (bool) {
        return _operatorApprovals[account][operator];
    }

    function approve(address spender, uint256 value) public virtual returns (bool) {
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        require(operator != address(0), "ERC1001: approve to the zero address");

        _operatorApprovals[msg.sender][operator] = approved;
        _allowances[msg.sender][operator] = approved ? type(uint256).max : 0;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(address from, address to, uint256 value) public {
        uint256 allowed = _allowances[from][msg.sender]; // Saves gas for limited approvals.
        if (allowed != type(uint256).max) _allowances[from][msg.sender] = allowed - value;
        _transfer(from, to, value);
    }

    function safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes memory data) public virtual {
        if (from != msg.sender) {
            require(isApprovedForAll(from, msg.sender), "ERC1001: missing approval for all");
        }

        _safeTransferFrom(from, to, id, value, data);
    }

    function _safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes memory data) internal {
        require(to != address(0), "ERC1001: _safeTransferFrom to the zero address");
        require(from != address(0), "ERC1001: _safeTransferFrom from the zero address");
        (uint256[] memory ids, uint256[] memory values) = _asSingletonArrays(id, value);
        _updateNFT(from, to, ids, values);
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(from != address(0), "ERC1001: transfer from the zero address");
        require(to != address(0), "ERC1001: transfer to the zero address");
        _update(from, to, value);
    }

    function _mint(address account, uint256 value) internal {
        require(account != address(0), "ERC1001: mint to the zero address");
        _update(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC1001: burn from the zero address");
        _update(account, address(0), value);
    }

    function _safeMint(address to, uint256 id, uint256 value) internal {
        require(to != address(0), "ERC1001: mint to the zero address");
        (uint256[] memory ids, uint256[] memory values) = _asSingletonArrays(id, value);
        _updateNFT(address(0), to, ids, values);
    }

    function _safeMints(address to, uint256[] memory ids, uint256[] memory values) internal {
        require(to != address(0), "ERC1001: mint to the zero address");
        _updateNFT(address(0), to, ids, values);
    }

    function _safeBurn(address from, uint256 id, uint256 value) internal {
        require(from != address(0), "ERC1001: burn from the zero address");
        (uint256[] memory ids, uint256[] memory values) = _asSingletonArrays(id, value);
        _updateNFT(from, address(0), ids, values);
    }

    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            require(fromBalance >= value, "ERC1001: transfer amount exceeds balance");
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    function _updateNFT(address from, address to, uint256[] memory ids, uint256[] memory values) internal virtual {
        require(ids.length == values.length, "ERC1001: ids and values length mismatch");
        address operator = msg.sender;

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 value = values[i];

            if (from != address(0)) {
                uint256 fromBalance = _balancesNFT[id][from];
                require(fromBalance >= value, "ERC1001: transfer amount exceeds balance");
                unchecked {
                    // Overflow not possible: value <= fromBalance
                    _balancesNFT[id][from] = fromBalance - value;
                }
            } else {
                totalSupply += value * 10 ** decimals;
            }

            if (to != address(0)) {
                _balancesNFT[id][to] += value;
            } else {
                totalSupply -= value * 10 ** decimals;
            }
        }

        if (ids.length == 1) {
            uint256 id = ids[0];
            uint256 value = values[0];
            emit TransferSingle(operator, from, to, id, value);
        } else {
            emit TransferBatch(operator, from, to, ids, values);
        }
    }

    function _asSingletonArrays(uint256 element1, uint256 element2) private pure returns (uint256[] memory array1, uint256[] memory array2) {
        /// @solidity memory-safe-assembly
        assembly {
            // Load the free memory pointer
            array1 := mload(0x40)
            // Set array length to 1
            mstore(array1, 1)
            // Store the single element at the next word after the length (where content starts)
            mstore(add(array1, 0x20), element1)

            // Repeat for next array locating it right after the first array
            array2 := add(array1, 0x40)
            mstore(array2, 1)
            mstore(add(array2, 0x20), element2)

            // Update the free memory pointer by pointing after the second array
            mstore(0x40, add(array2, 0x40))
        }
    }
}
