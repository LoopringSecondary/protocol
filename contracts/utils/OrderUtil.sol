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
import "../ITradeDelegate.sol";
import "../lib/MathUint.sol";

/// @title OrderUtil
/// @author Daniel Wang - <daniel@loopring.org>.

library OrderUtil {
    using MathUint      for uint;
    function getHash(Data.Order order)
        public
        pure
        returns (bytes32 )
    {
        return bytes32(0x0);
    }

    function getSpendable(
        Data.Order order,
        ITradeDelegate delegate,
        address token
        )
        public
        view
        returns (uint)
    {
        return 0;
    }

    function getFilledAmount(
        Data.Order order,
        ITradeDelegate delegate
        )
        public
        view
        returns (uint)
    {
        return 0;
    }

    function scale(
        Data.Order order,
        ITradeDelegate delegate
        )
        public
    {
        if (order.capByAmountB) {
            order.actualAmountB = order.amountB.tolerantSub(order.filledAmount);
            order.actualAmountS = order.amountS.mul(order.actualAmountB) / order.amountB;
            order.actualLRCFee  = order.lrcFee.mul(order.actualAmountB) / order.amountB;
        } else {
            order.actualAmountS = order.amountS.tolerantSub(order.filledAmount);
            order.actualAmountB = order.amountB.mul(order.actualAmountS) / order.amountS;
            order.actualLRCFee  = order.lrcFee.mul(order.actualAmountS) / order.amountS;
        }

        if (order.spendableS < order.actualAmountS) {
            order.actualAmountS = order.spendableS;
        }
    }
}