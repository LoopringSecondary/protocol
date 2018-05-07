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


/// @title An Implementation of IOrderbook.
/// @author Daniel Wang - <daniel@loopring.org>.
library Data {

    struct Order {
        // required fields
        address owner;
        address tokenS;
        address tokenB;
        uint    amountS;
        uint    amountB;
        uint    lrcFee;

        // optional fields
        address authAddr;
        address broker;
        address interceptor;
        address wallet;
        uint    validSince;
        uint    validUntil;
        bool    optCapByAmountB;
        bool    allOrNone;
        bytes   sig;

        // computed fields
        bytes32 orderHash;
    }

    struct MiningParam {
        // required fields
        address feeRecipient;
        address miner;

        // optional fields
        address broker;
        address interceptor;
        address sig;
    }

    struct State {
        // required fields
        bool marginSplitAsFee;
        uint rateS;
        uint rateB;
        // computed fields
        uint splitS;
        uint splitB;
        uint lrcFee;
        uint lrcReward;
        uint fillAmountS;
    }


    struct Participation{uint x;}
    struct Ring{
        Participation[] participations;
    }
}