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
        for (uint i = 0; i < ring.size; i++) {
            Data.Participation memory p = ring.participations[i];
            Data.Order memory order = p.order;
            p.fillAmountS = order.maxAmountS;
            p.fillAmountB = order.maxAmountB;
        }

        uint smallest = 0;

        for (uint i = 0; i < ring.size; i++) {
            smallest = calculateOrderFillAmount(ring, i, smallest);
        }

        for (uint i = 0; i < smallest; i++) {
            calculateOrderFillAmount(ring, i, smallest);
        }

        for (uint i = 0; i < ring.size; i++) {
            Data.Participation memory p = ring.participations[i];
            Data.Order memory order = p.order;
            order.maxAmountS   = order.maxAmountS.sub(p.fillAmountS);
            order.maxAmountB   = order.maxAmountB.sub(p.fillAmountB);
            order.maxAmountLRC = order.maxAmountLRC.sub(p.lrcFee);
        }
    }

    function calculateOrderFillAmount(
        Data.Ring ring,
        uint i,
        uint smallest
        )
        internal
        pure
        returns (uint smallest_)
    {
        // Default to the same smallest index
        smallest_ = smallest;

        Data.Participation memory p = ring.participations[i];
        Data.Order memory order = p.order;

        p.fillAmountB = p.fillAmountS.mul(p.rateB) / p.rateS;

        if (order.capByAmountB) {
            if (p.fillAmountB > order.maxAmountB) {
                p.fillAmountB = order.maxAmountB;
                p.fillAmountS = p.fillAmountB.mul(p.rateS) / p.rateB;
                smallest_ = i;
            }
            p.lrcFee = order.lrcFee.mul(p.fillAmountB) / order.amountB;
        } else {
            p.lrcFee = order.lrcFee.mul(p.fillAmountS) / order.amountS;
        }

        uint j = (i + 1) % ring.size;
        Data.Participation memory nextP = ring.participations[j];

        if (p.fillAmountB < nextP.fillAmountS) {
            nextP.fillAmountS = p.fillAmountB;
        } else {
            smallest_ = j;
        }
    }
}