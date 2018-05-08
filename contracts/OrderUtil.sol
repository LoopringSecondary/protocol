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
import "./lib/MultihashUtil.sol";

/// @title An Implementation of IOrderbook.
/// @author Daniel Wang - <daniel@loopring.org>.
library OrderUtil {
    function updateHash(Data.Order order)
        public
        pure
    {
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
}