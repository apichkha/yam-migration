pragma solidity ^0.6.0;

import "./lib/SafeERC20.sol";
import "./lib/Context.sol";
import "./lib/SafeMath.sol";

interface YAM {
  function balanceOfUnderlying(address owner) external view returns (uint256);
  function yamsScalingFactor() external view returns (uint256);
}

interface YAMv2 {
  function mint(address owner, uint256 amount) external;
}


/**
 * @title YAMv2 Token
 * @dev YAMv2 Mintable Token with migration from legacy contract. Used to signal
 *      for protocol changes in v3.
 */
contract YAMv2Migration is Context {

    using SafeMath for uint256;

    address public constant yam = address(0x0e2298E3B3390e3b945a5456fBf59eCc3f55DA16);

    address public yamV2;

    bool public token_initialized;

    uint256 public constant migrationDuration = 3 days;

    uint256 public constant startTime = 1597568400; // TBD!

    uint256 public constant BASE = 10**18;

    uint256 public constant internalDecimals = 10**24;

    constructor () public {
    }

    /**
     * @dev Sets yamV2 token address
     *
     * Not permissioned. One way function. Set in deployment scripts
     */
    function setV2Address(address yamV2_) public {
      require(!token_initialized, "already set");
      token_initialized = true;
      yamV2 = yamV2_;
    }


    /**
     * @dev Migrate a users' entire balance
     *
     * One way function. YAMv1 tokens are BURNED. YAMv2 tokens are minted.
     */
    function migrate() public virtual {
        require(block.timestamp >= startTime, "!started");
        require(block.timestamp < startTime + migrationDuration, "migration ended");

        // current scalingFactor
        uint256 scalingFactor = YAM(yam).yamsScalingFactor();

        // gets the yamValue for a user.
        uint256 yamValue = YAM(yam).balanceOfUnderlying(_msgSender());

        require(yamValue > 0, "No yams");

        // gets transferFrom amount by multiplying by scaling factor / 10**24
        // equivalent to balanceOf, but we need underlyingAmount later
        uint256 transferAmount = yamValue.mul(scalingFactor).div(internalDecimals);

        // BURN YAM - UNRECOVERABLE.
        SafeERC20.safeTransferFrom(
            IERC20(yam),
            _msgSender(), address(0x000000000000000000000000000000000000dEaD), transferAmount
        );

        // mint new YAMv2, using yamValue (1e24 decimal token, to match internalDecimals)
        YAMv2(yamV2).mint(_msgSender(), yamValue);
    }
}