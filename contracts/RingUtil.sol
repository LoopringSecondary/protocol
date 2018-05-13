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
        
    }
}