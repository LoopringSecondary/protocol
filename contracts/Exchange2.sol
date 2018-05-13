/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
pragma solidity 0.4.23;
pragma experimental "v0.5.0";
pragma experimental "ABIEncoderV2";

import "./lib/AddressUtil.sol";
import "./lib/BytesUtil.sol";
import "./lib/ERC20.sol";
import "./lib/MathUint.sol";
import "./lib/MultihashUtil.sol";
import "./lib/NoDefaultFunc.sol";
import "./IBrokerRegistry.sol";
import "./IBrokerInterceptor.sol";
import "./IExchange.sol";
import "./IOrderRegistry.sol";
import "./ITokenRegistry.sol";
import "./ITradeDelegate.sol";
import "./IMinerRegistry.sol";
import "./Data.sol";
import "./OrderUtil.sol";
import "./OrderSpecs.sol";
import "./RingUtil.sol";
import "./RingSpecs.sol";
import "./MiningSpec.sol";
import "./MiningUtil.sol";
import "./InputsUtil.sol";


/// @title An Implementation of IExchange.
/// @author Daniel Wang - <daniel@loopring.org>,
/// @author Kongliang Zhong - <kongliang@loopring.org>
///
/// Recognized contributing developers from the community:
///     https://github.com/Brechtpd
///     https://github.com/rainydio
///     https://github.com/BenjaminPrice
///     https://github.com/jonasshen
///     https://github.com/Hephyrius
contract Exchange is IExchange, NoDefaultFunc {
    using AddressUtil   for address;
    using MathUint      for uint;
    using MiningSpec    for uint16;
    using OrderSpecs    for uint16[];
    using RingSpecs     for uint8[][];
    using OrderUtil     for Data.Order;
    using RingUtil      for Data.Ring;
    using InputsUtil    for Data.Inputs;
    using MiningUtil    for Data.Mining;

    address public  lrcTokenAddress             = 0x0;
    address public  tokenRegistryAddress        = 0x0;
    address public  delegateAddress             = 0x0;
    address public  orderBrokerRegistryAddress  = 0x0;
    address public  minerBrokerRegistryAddress  = 0x0;
    address public  orderRegistryAddress        = 0x0;
    address public  minerRegistryAddress        = 0x0;

    uint64  public  ringIndex                   = 0;

    // Exchange rate (rate) is the amount to sell or sold divided by the amount
    // to buy or bought.
    //
    // Rate ratio is the ratio between executed rate and an order's original
    // rate.
    //
    // To require all orders' rate ratios to have coefficient ofvariation (CV)
    // smaller than 2.5%, for an example , rateRatioCVSThreshold should be:
    //     `(0.025 * RATE_RATIO_SCALE)^2` or 62500.
    uint    public rateRatioCVSThreshold        = 0;

    uint    public constant MAX_RING_SIZE       = 8;

    uint    public constant RATE_RATIO_SCALE    = 10000;

    function submitRings(
        uint16 miningSpec,
        uint16[] orderSpecs,
        uint8[][] ringSpecs,
        address[] addressLists,
        uint[] uintList,
        bytes[] bytesList
        )
        public
    {
        Data.Context memory ctx = Data.Context(
            lrcTokenAddress,
            ITokenRegistry(tokenRegistryAddress),
            ITradeDelegate(delegateAddress),
            IBrokerRegistry(orderBrokerRegistryAddress),
            IBrokerRegistry(minerBrokerRegistryAddress),
            IOrderRegistry(orderRegistryAddress),
            IMinerRegistry(minerRegistryAddress)
        );

        Data.Inputs memory inputs = Data.Inputs(
            addressLists,
            uintList,
            bytesList,
            0, 0, 0  // current indices of addressLists, uintList, and bytesList.
        );

        Data.Mining memory mining = Data.Mining(
            inputs.nextAddress(),
            miningSpec.hasMiner() ? inputs.nextAddress() : address(0x0),
            miningSpec.hasSignature() ? inputs.nextBytes() : new bytes(0),
            bytes32(0x0), // hash
            address(0x0)  // interceptor
        );

        Data.Order[] memory orders = orderSpecs.assembleOrders(inputs);
        Data.Ring[] memory rings = ringSpecs.assembleRings(orders, inputs);

        for (uint i = 0; i < orders.length; i++) {
            orders[i].updateHash();
            orders[i].updateBrokerAndInterceptor(ctx);
            orders[i].checkBrokerSignature(ctx);
        }

        for (uint i = 0; i < rings.length; i++) {
            rings[i].updateHash();
            mining.hash ^= rings[i].hash;
        }

        mining.updateHash();
        mining.updateMinerAndInterceptor(ctx);
        mining.checkMinerSignature(ctx);

        for (uint i = 0; i < orders.length; i++) {
            orders[i].checkDualAuthSignature(mining.hash);
        }

        for (uint i = 0; i < orders.length; i++) {
            orders[i].updateStates(ctx);
            orders[i].adjust(ctx, 0, 0, 0);
            orders[i].scale(ctx);
        }

        for (uint i = 0; i < rings.length; i++){
            rings[i].calculateFillAmountAndFee();
        }
    }
}
