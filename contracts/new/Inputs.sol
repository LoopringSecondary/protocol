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


contract Inputs {
    address[] private addressList;
    uint[]    private uintList;
    bytes[]   private bytesList;

    uint private i = 0;  // current index of addressList
    uint private j = 0;  // current index of uintList
    uint private k = 0;  // current index of bytesList

    constructor(
        address[] addressList_,
        uint[] uintList_,
        bytes[] bytesList_
        )
        public
    {
      addressList = addressList_;
      uintList = uintList_;
      bytesList = bytesList_;
    }

    function nextAddress()
        public
        returns (address)
    {
        return addressList[i++];
    }

    function nextUint()
        public
        returns (uint)
    {
        return uintList[j++];
    }

    function nextBytes()
        public
        returns (bytes)
    {
        return bytesList[k++];
    }
}