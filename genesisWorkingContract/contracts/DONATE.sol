pragma solidity ^0.4.22;

/// @title Donate

contract Donate {
    
    // This donate asks integer type enquirys
    // There are 4 enquirys and victimPref to each enquiry is an integer

    
    address public beneficiary;
    uint public donateTime;
    address[] public participants;
    uint pFee; // Participation Fee 
    uint tFee; // Total Fee collected by the contract
    uint delay; // Time to start first enquiry

    // This declares a new type for
    // Participants of the donate
    struct participantStruct {
        bool isRegistered;
        bool[4] asked; // if true, that person already asked
        bool[4] submit; // if true, that person not already victimPrefed
        bytes32[4] victimPref;// Holds the victimPref to the enquiry as hash(keccak256 output of the victimPref
        uint[4] victimPrefTime;
    }
    
    struct enquiry{    
        string pref;
        bytes32 ans;
        bool isDisplayed;
    }
        
    enquiry[] pref;
    mapping(address => participantStruct) public participantStructs;    
    
    // Create a simple donate with '_donateTime' as the
    // duration of donate
    constructor() public {
        beneficiary = msg.sender;
    }
    
    function sendParams(uint _donateTime,uint _pFee,uint _d,string _pref1,string _ans1,string _pref2,string _ans2,string _pref3,string _ans3,string _pref4,string _ans4) public returns (bool) {
        pFee = _pFee;
        donateTime = _donateTime;
        delay = _d;
        pref.push(enquiry({
            pref: _pref1,
            ans: keccak256(keccak256(_ans1)),
            isDisplayed: false
        }));
        
        pref.push(enquiry({
            pref: _pref2,
            ans: keccak256(keccak256(_ans2)),
            isDisplayed: false
        }));
        
        pref.push(enquiry({
            pref: _pref3,
            ans: keccak256(keccak256(_ans3)),
            isDisplayed: false
        }));
        
        pref.push(enquiry({
            pref: _pref4,
            ans: keccak256(keccak256(_ans4)),
            isDisplayed: false
        }));
        return true;
    }
    
    function beneficiaryExists() public view returns(address){
        return beneficiary;
    }
    /// Register to play the donate 
    /// Participation fee is pFee
    function register() public payable{
        address doner = msg.sender;
        
        require(
            !participantStructs[doner].isRegistered,
            "not already registerd"
        );
        
        require(
            msg.value >= pFee,
            "pFee is participation fee"
        );
        
    
        participants.push(doner);
        participantStructs[doner].isRegistered = true;
        participantStructs[doner].asked[0] = false;
        participantStructs[doner].asked[1] = false;
        participantStructs[doner].asked[2] = false;
        participantStructs[doner].asked[3] = false;
        participantStructs[doner].submit[0] = true;
        participantStructs[doner].submit[1] = true;
        participantStructs[doner].submit[2] = true;
        participantStructs[doner].submit[3] = true;
        tFee += msg.value;

        
    }

    function listOfVictims(string criteria) public payable returns (address[]){
        
    }
    function donateTo(address victim, uint amount) public payable returns (address[]){
        // transfering the amount to victim's address
        victim.transfer(amount);
        return "Your donation is successfull";
    }
    

    function donerExists(address doner) public view returns(bool){
        return participantStructs[doner].isRegistered;
    }

    function getTfee() public view returns(uint){
        return tFee;
    }

    uint prize = 3*(tFee/16);
    
    uint[4]  startTime;
    uint[4]  endTime;
    
    function startdonate() public{
        
        require(
            msg.sender == beneficiary
        );
        
        startTime[0] = block.number + delay;
        endTime[0] = startTime[0] + donateTime;
        
        for(uint i=1;i<4;i++){
            startTime[i] = endTime[i-1] + delay; 
            endTime[i] = startTime[i] + donateTime; 
        }
    }
    
    // function donateStarted() public view returns(string) {
    //     if(block.number + delay >= startTime[0])
    //         return "The donate will begin in a few minutes";
    //     else
    //         return "not started yet";
    // }

    function increaseBlocks() public payable returns(bool){
        return true;
    }
    // donate enquiry
    // function getenquiry() public view returns (string){
        
    //     require(
    //         participantStructs[msg.sender].isRegistered
    //     );
        
        
        
    //    if (block.number >= startTime[0] && block.number <= endTime[0]){
    //        require(
    //             !participantStructs[msg.sender].asked[0]
    //        );
    //        participantStructs[msg.sender].asked[0] = true;
    //        return pref[0].pref;
    //    }
       
    //    else if (block.number >= startTime[1] && block.number <= endTime[1]){
    //        require(
    //             !participantStructs[msg.sender].asked[1]
    //        );
    //        participantStructs[msg.sender].asked[1] = true;
    //        return pref[1].pref;
    //    }
       
    //    else if (block.number >= startTime[2] && block.number <= endTime[2]){
    //        require(
    //             !participantStructs[msg.sender].asked[2]
    //        );
    //        participantStructs[msg.sender].asked[2] = true;
    //        return pref[2].pref;
    //    }
       
    //    else if (block.number >= startTime[3] && block.number <= endTime[3]){
    //        require(
    //             !participantStructs[msg.sender].asked[3]
    //        );
    //        participantStructs[msg.sender].asked[3] = true;
    //        return pref[3].pref;
    //    }
       
    //    else return "Sorry!! donate ended";
        
    // }
    
    event Payment(
        address _from,
        address _to,
        uint amount
    );

    function hasSubmitted(uint pref) public view returns(bool){
        return !participantStructs[msg.sender].submit[pref-1];
    }
    // u can submit the victimPref only ones so the stakes are block.number really really high play safe
    function submitvictimPref(bytes32 ansHash) public payable returns (string){
        
        require(
            participantStructs[msg.sender].isRegistered
        );
        
       if (block.number >= startTime[0] && block.number <= endTime[0]){
           require(
                participantStructs[msg.sender].submit[0]
           );
           participantStructs[msg.sender].submit[0] = false;
           if(keccak256(abi.encodePacked(ansHash)) == pref[0].ans){
               msg.sender.transfer(prize);
               emit Payment(beneficiary, msg.sender, prize);
               endTime[0] = startTime[0];
               return "Winner Winner Ether Dinner";
           }
       }
       
       else if (block.number >= startTime[1] && block.number <= endTime[1]){
           require(
                participantStructs[msg.sender].submit[1]
           );
           participantStructs[msg.sender].submit[1] = false;
           if(keccak256(abi.encodePacked(ansHash)) == pref[1].ans){
               msg.sender.transfer(prize);
               emit Payment(beneficiary, msg.sender, prize);
               endTime[1] = startTime[1];
               return "Winner Winner Ether Dinner";
           }
       }
       
       else if (block.number >= startTime[2] && block.number <= endTime[2]){
           require(
                participantStructs[msg.sender].submit[2]
           );
           participantStructs[msg.sender].submit[2] = false;
           if(keccak256(abi.encodePacked(ansHash)) == pref[2].ans){
               msg.sender.transfer(prize);
               emit Payment(beneficiary, msg.sender, prize);
               endTime[2] = startTime[2];
               return "Winner Winner Ether Dinner";
           }
       }
       
       else if (block.number >= startTime[3] && block.number <= endTime[3]){
           require(
                participantStructs[msg.sender].submit[3]
           );
           participantStructs[msg.sender].submit[3] = false;
           if(keccak256(abi.encodePacked(ansHash)) == pref[3].ans){
               msg.sender.transfer(prize);
               emit Payment(beneficiary, msg.sender, prize);
               endTime[3] = startTime[3];
               return "Winner Winner Ether Dinner";   
           }
       }
       else{
           return "Thankyou your victimPref will be looked into";
       }    
    }
}