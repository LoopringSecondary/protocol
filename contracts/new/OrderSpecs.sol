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


contract OrderSpecs {
    uint16[] private  specs;

    constructor(
        uint16[] specs_
        )
        public
    {
        specs = specs_;
    }

    function size()
        public
        returns (uint)
    {
        return specs.length;
    }

    // function assemblyOrder(Inputs inputs, uint i) {
    //         uint16 spec = specs[i];
    //         ctx.orders[i] = Data.Order(
    //             ctx.inputs.nextAddress(),  // owner
    //             ctx.inputs.nextAddress(),  // amountS
    //             0x0, // tokenB need to be filled with the previous order's tokenS;
    //             ctx.inputs.nextUint(), // amountS
    //             ctx.inputs.nextUint(), // amountB
    //             ctx.inputs.nextUint(), // lrcFee
    //             spec.hasAuthAddr() ? ctx.inputs.nextAddress() : 0x0, // authAddr
    //             spec.hasBroker() ? ctx.inputs.nextAddress() : 0x0, // broker
    //             spec.hasOrderInterceptor() ? ctx.inputs.nextAddress() : 0x0, // interceptor
    //             spec.hasWallet() ? ctx.inputs.nextAddress() : 0x0, // wallet
    //             spec.hasValidSince() ? ctx.inputs.nextUint() : 0, // validSince
    //             spec.hasValidUntil() ? ctx.inputs.nextUint() : uint(0) - 1, // validUntil
    //             spec.hasSignature() ? ctx.inputs.nextBytes() : new bytes(0), // sig
    //             spec.capByAmountB(),
    //             spec.allOrNone(),
    //             bytes32(0x0), // orderHash
    //             address(0x0), // brokerInterceptor
    //             0, // spendableS,
    //             0, // spendableLRC
    //             0, // filledAmount
    //             0, // actualAmountS
    //             0, // actualAmountB,
    //             0  // actualLRCFee
    //         );
    // }
}