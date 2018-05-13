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


import "./Data.sol";
import "./lib/ERC20.sol";
import "./lib/MathUint.sol";
import "./lib/MultihashUtil.sol";
import "./IBrokerInterceptor.sol";

/// @title An Implementation of IOrderbook.
/// @author Daniel Wang - <daniel@loopring.org>.
library OrderUtil {

    using MathUint      for uint;

    function updateHash(Data.Order order)
        public
        pure
    {
        order.hash = keccak256(
            order.owner,
            order.tokenS,
            order.tokenB,
            order.amountS,
            order.amountB,
            order.lrcFee,
            order.dualAuthAddr,
            order.broker,
            order.orderInterceptor,
            order.wallet,
            order.validSince,
            order.validUntil,
            order.capByAmountB,
            order.allOrNone
        );
    }

    function updateBrokerAndInterceptor(
        Data.Order order,
        Data.Context ctx
        )
        public
        view
    {
        if (order.broker == address(0x0)) {
            order.broker = order.owner;
        } else {
            bool registered;
            (registered, order.brokerInterceptor) = ctx.orderBrokerRegistry.getBroker(
                order.owner,
                order.broker
            );
             require(registered, "broker unregistered");
        }
    }

    function updateStates(
        Data.Order order,
        Data.Context ctx
        )
        public
        view
    {
        order.spendableS =  getSpendable(
            ctx.delegate,
            order.tokenS,
            order.owner,
            order.broker,
            order.brokerInterceptor
        );

        order.spendableLRC =  getSpendable(
            ctx.delegate,
            ctx.lrcTokenAddress,
            order.owner,
            order.broker,
            order.brokerInterceptor
        );

        order.filledAmount = ctx.delegate.filled(order.hash);
    }

    function adjust(
        Data.Order order,
        Data.Context ctx,
        uint spendableDelta,
        uint spendableLRCDelta,
        uint filledAmountDelta
        )
        public
        view
    {
        order.spendableS = order.spendableS.sub(spendableDelta);
        order.spendableLRC = order.spendableLRC.sub(spendableLRCDelta);
        order.filledAmount = order.filledAmount.add(filledAmountDelta);

        if (order.capByAmountB) {
            order.actualAmountB = order.amountB.tolerantSub(order.filledAmount);
            order.actualAmountS = order.amountS.mul(order.actualAmountB) / order.amountB;
            if (order.actualAmountS > order.spendableS) {
                order.actualAmountS = order.spendableS;
                order.actualAmountB = order.amountB.mul(order.actualAmountS) / order.amountS;
            }
        } else {
            order.actualAmountS = order.amountS.tolerantSub(order.filledAmount);
            if (order.actualAmountS > order.spendableS) {
                order.actualAmountS = order.spendableS;
            }
        }
    }

    function scale(
        Data.Order order,
        Data.Context ctx
        )
        public
        view
    {
        if (order.capByAmountB) {
            order.actualAmountS = order.amountS.mul(order.actualAmountB) / order.amountB;
            order.actualLRCFee  =  order.lrcFee.mul(order.actualAmountB) / order.amountB;
        } else {
            order.actualAmountB = order.amountB.mul(order.actualAmountS) / order.amountS;
            order.actualLRCFee  =  order.lrcFee.mul(order.actualAmountS) / order.amountS;
        }
    }

    function checkBrokerSignature(
        Data.Order order,
        Data.Context ctx
        )
        public
        view
    {
        if (order.sig.length == 0) {
            require(
                ctx.orderRegistry.isOrderHashRegistered(
                    order.broker,
                    order.hash
                ),
                "order unauthorized"
            );
        } else {
            MultihashUtil.verifySignature(
                order.broker,
                order.hash,
                order.sig
            );
        }
    }

    function checkDualAuthSignature(
        Data.Order order,
        bytes32  miningHash
        )
        public
        view
    {
        if (order.dualAuthSig.length != 0) {
            MultihashUtil.verifySignature(
                order.dualAuthAddr,
                miningHash,
                order.dualAuthSig
            );
        }
    }

       /// @return Amount of ERC20 token that can be spent by this contract.
    function getSpendable(
        ITradeDelegate delegate,
        address tokenAddress,
        address tokenOwner,
        address broker,
        address brokerInterceptor
        )
        private
        view
        returns (uint spendable)
    {
        ERC20 token = ERC20(tokenAddress);
        spendable = token.allowance(
            tokenOwner,
            address(delegate)
        );
        if (spendable == 0) {
            return;
        }
        uint amount = token.balanceOf(tokenOwner);
        if (amount < spendable) {
            spendable = amount;
            if (spendable == 0) {
                return;
            }
        }

        if (brokerInterceptor != tokenOwner) {
            amount = IBrokerInterceptor(brokerInterceptor).getAllowance(
                tokenOwner,
                broker,
                tokenAddress
            );
            if (amount < spendable) {
                spendable = amount;
            }
        }
    }
}