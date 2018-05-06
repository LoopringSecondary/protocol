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
import "./IBrokerRegistry.sol";
import "./IBrokerInterceptor.sol";
import "./ITokenRegistry.sol";
import "./ITradeDelegate.sol";

/// @title RingAssembler
/// @author Daniel Wang - <daniel@loopring.org>.

library OrderSpec {
    function isLastInDeck(uint16 spec)
        public
        pure
        returns (bool)
    {
        return spec & 0x1 != 0;
    }

    function capByAmountB(uint16 spec)
        public
        pure
        returns (bool)
    {
        return spec & 0x2 != 0;
    }

    function allOrNone(uint16 spec)
        public
        pure
        returns (bool)
    {
        return spec & 0x4 != 0;
    }

    function splitAsFee(uint16 spec)
        public
        pure
        returns (bool)
    {
        return spec & 0x8 != 0;
    }

    function participation(uint16 spec)
        public
        pure
        returns (uint16 p)
    {
        p = (spec >> 4) & 0xF;
        require(p > 0);
    }
}

contract RingAssembler {
  using OrderSpec for uint16;

   struct Ring {
        uint ringIndex;
        uint ringSize;
        uint ringDepth;
        bytes32 ringHash;
        Data.OrderDeck[] decks;
        Data.MiningParam miningParam;
        ITradeDelegate delegate;
        IBrokerRegistry brokerRegistry;
    }

    function assembleRing(
        uint16[]    specs,
        address[]   addressList,
        uint[]      uintList,
        uint8[]     uint8List,
        bytes[]     bytesList
        )
        private
        view
        returns (Ring ring)
    {
        Data.OrderDeck[] memory decks = new Data.OrderDeck[](0);


   // // struct OrderDeck {
   // //      NewOrderState[] orders;
   // //  }
        for (uint i = 1; i < specs.length; i++) {
          // bit-0 = 1 iff this order is the last order of a deck.
          if (specs[i].isLastInDeck()) {
              // not the last order of the deck;
     
          }
        }

        

        uint j = 0;  // index of addressList
        uint k = 0;  // index of uintList
        uint l = 0;  // index of uint8List
        uint m = 0;  // index of bytesList

  

    }
}