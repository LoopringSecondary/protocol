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
import "./lib/MathUint.sol";
import "./lib/MultihashUtil.sol";

/// @title An Implementation of IOrderbook.
/// @author Daniel Wang - <daniel@loopring.org>.

    // struct Participation {
    //     // required fields
    //     Order order;
    //     bool marginSplitAsFee;
    //     uint rateS;
    //     uint rateB;

    //     // computed fields
    //     uint splitS;
    //     uint splitB;
    //     uint lrcFee;
    //     uint lrcReward;
    //     uint fillAmountS;
    // }

    // struct Ring{
    //     uint size;
    //     Participation[] participations;
    //     bytes32 hash;
    // }


library RingUtil {
    using MathUint      for uint;

    function updateHash(
        Data.Ring ring
        )
        public
        pure
    {
        for (uint i = 0; i < ring.size; i++) {
            Data.Participation memory p = ring.participations[i];
            ring.hash = keccak256(
                ring.hash,
                p.order.hash,
                p.marginSplitAsFee
            );
        }
    }

    function calculateFillAmountAndFee(
        Data.Ring ring
        )
        public
        pure
    {
        uint smallestIdx = 0;

        for (uint i = 0; i < ring.size; i++) {
            uint j = (i + 1) % ring.size;
            smallestIdx = calculateOrderFillAmount(ring, i, j, smallestIdx);
        }

        for (uint i = 0; i < smallestIdx; i++) {
            uint j = (i + 1) % ring.size;
            calculateOrderFillAmount(ring, i, j, smallestIdx);
        }
    }

    function calculateOrderFillAmount(
        Data.Ring ring,
        uint i,
        uint j,
        uint smallestIdx
        )
        internal
        pure
        returns (uint newSmallestIdx)
    {
        // Default to the same smallest index
        newSmallestIdx = smallestIdx;

        Data.Participation memory p1 = ring.participations[i];
        Data.Participation memory p2 = ring.participations[j];

        Data.Order memory order1 = p1.order;
        Data.Order memory order2 = p2.order;

        uint fillAmountB = order1.actualAmountS.mul(
            p1.rateB
        ) / p1.rateS;

        // if (order.capByAmountB) {
        //     if (fillAmountB > order.amountB) {
        //         fillAmountB = order.amountB;

        //         order.fillAmountS = fillAmountB.mul(
        //             order.rateS
        //         ) / order.rateB;
        //         require(order.fillAmountS > 0, "fillAmountS is 0");

        //         newSmallestIdx = i;
        //     }
        //     order.lrcFeeState = order.lrcFee.mul(
        //         fillAmountB
        //     ) / order.amountB;
        // } else {
        //     order.lrcFeeState = order.lrcFee.mul(
        //         order.fillAmountS
        //     ) / order.amountS;
        // }

        // // Check All-or-None orders
        // if (order.optAllOrNone){
        //     if (order.optCapByAmountB) {
        //         require(
        //             fillAmountB >= order.amountB,
        //             "AON failed on amountB"
        //         );
        //     } else {
        //         require(
        //             order.fillAmountS >= order.amountS,
        //              "AON failed on amountS"
        //         );
        //     }
        // }

        // if (fillAmountB <= next.fillAmountS) {
        //     next.fillAmountS = fillAmountB;
        // } else {
        //     newSmallestIdx = j;
        // }
    }
}