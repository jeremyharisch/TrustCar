pragma solidity ^0.4.23;
import "github.com/Arachnid/solidity-stringutils/strings.sol";
contract trustCarContract {

mapping(address => car_struct) public car_accounts;           // Accounts of all cars

mapping(address => garage_struct) public garage_accounts;     // Account of all garages


event getCarData( string _name, uint _yearOfConstruction, string _license_plate, string _owner, uint _odometer, address _place);

event getGarage(bool _adm,string _name,uint _yearOfConstruction,string _place);


function uintToStr(uint i) internal pure returns (string){
    if (i == 0) return "0";
    uint j = i;
    uint length;
    while (j != 0){
        length++;
        j /= 10;
    }
    bytes memory bstr = new bytes(length);
    uint k = length - 1;
    while (i != 0){
        bstr[k--] = byte(48 + i % 10);
        i /= 10;
    }
    return string(bstr);
}

struct car_struct {
address addr;               // wallet's address
string name;                // name of car
uint yearOfConstruction;    // Year of construction
string license_plate;       // License plate
string owner;               // Car owner
uint odometer;              // Odometer
address place;               // Garage of construction => address
item[] history;             // history of car
}

struct garage_struct {
address addr;               // wallet's address
bool adm;                   // true => admin
string name;                // name of garage or admin
uint yearOfConstruction;    // Year of building garage
string place;               // settlement of garage
}

struct item {
uint date;                  // date of entry
string content;             // content of entry
address garage;             // address of garage

}


modifier onlyAdmin (){
    require(garage_accounts[msg.sender].addr!= 0 );
    require(garage_accounts[msg.sender].adm == true);
    _;
}

modifier onlyGarage(){
    require(garage_accounts[msg.sender].addr != 0 );
    _;
}

item[] history_create;

function trustCarContract() public {
    uint year = now;
    //garage_accounts[msg.sender] = garage_struct(msg.sender, true,"Trustcar",  year, "Pohang University of Science and Technology");
    garage_accounts[msg.sender].addr= msg.sender;
    garage_accounts[msg.sender].adm=true;
    garage_accounts[msg.sender].name="TrustCar";
    garage_accounts[msg.sender].yearOfConstruction=now;
    garage_accounts[msg.sender].place ="Pohang University of Science and Technology";
}



function createNewCar( address _adr, string _name, string _plate, string _owner ) public onlyAdmin returns (bool success)  {     
  success = false;
  
  //car_accounts[_adr] = car_struct(_adr, _name , now, _plate, _owner, 0, msg.sender );                         // Maybe also add history                            
  car_accounts[_adr].addr = _adr;
  car_accounts[_adr].name= _name;
  car_accounts[_adr].yearOfConstruction= now;
  car_accounts[_adr].license_plate = _plate;
  car_accounts[_adr].owner=_owner;
  car_accounts[_adr].odometer=0;
  car_accounts[_adr].place=msg.sender;
  car_accounts[_adr].history.push(item(now,"Creation of Car",msg.sender));
  
  
  
  success = true;
}

function registerCar( address _adr, string _name, string _plate, string _owner, uint _odometer, uint _year ) public onlyAdmin returns (bool success)  {     
  success = false;
  //item[] h;
  //car_accounts[_adr] = car_struct(_adr, _name , _year, _plate, _owner, _odometer, msg.sender, h );              // Maybe also add history                            
  car_accounts[_adr].addr = _adr;
  car_accounts[_adr].name= _name;
  car_accounts[_adr].yearOfConstruction= _year;
  car_accounts[_adr].license_plate = _plate;
  car_accounts[_adr].owner=_owner;
  car_accounts[_adr].odometer=_odometer;
  car_accounts[_adr].place=msg.sender;
  car_accounts[_adr].history.push(item(now,"Registered Car to TrustCar",msg.sender));
  
  success = true;
}


// Admin creates new garage
function createNewGarage( address _adr, bool _adm, string _name, string _place, uint _year) public onlyAdmin returns (bool success){
  success = false;
  garage_accounts[_adr] = garage_struct(_adr, _adm, _name, _year, _place);
  success = true;
}



function changeGarageToAdmin ( address _adr) public onlyAdmin returns (bool success){
  success = false;
  garage_accounts[_adr].adm = true;
  success = true;
}


function changeGarageToNonAdmin ( address _adr) public onlyAdmin returns (bool success){
  success = false;
  garage_accounts[_adr].adm = false;
  success = true;
}


function sendHistory( address _car,  string _content) public onlyGarage returns (bool success){
  success = false;

  item entry;
  entry.date = now;
  entry.garage = msg.sender;
  entry.content = _content;

  car_accounts[_car].history.push(entry);

  success = true;

}




function seeGarage( address _adr) public  {
    garage_struct gar = garage_accounts[_adr];
    getGarage(gar.adm, gar.name, gar.yearOfConstruction, gar.place);

}





function seeCarData( address _adr) public {
    //car_struct car = car_accounts[_adr];
    emit getCarData(car_accounts[_adr].name, car_accounts[_adr].yearOfConstruction,car_accounts[_adr].license_plate,car_accounts[_adr].owner,car_accounts[_adr].odometer,car_accounts[_adr].place);
    
    
}


function changeOwner(address _adr, string _newowner)public onlyGarage{
    require(car_accounts[_adr].addr != 0);
    car_accounts[_adr].owner = _newowner;
}

function changePlate(address _adr, string _plate) public onlyGarage{
    require(car_accounts[_adr].addr != 0);
    car_accounts[_adr].license_plate = _plate;
}

event updateFailed(bool fail);

function updateOdometer(address _adr, uint _odo) onlyGarage{
    require(car_accounts[_adr].addr != 0);
    if(car_accounts[_adr].odometer < _odo){
        car_accounts[_adr].odometer = _odo;
    }
    else{
          emit updateFailed(true);  
    }
}





//Functions to get all the history data. This functions will be called in a for-loop as long as the history array is



event showHistoryEntry( uint _date, address _adr, string _entry);

function getHistory(address _adr) public   {
    uint i ;
    for(i = 0; i < car_accounts[_adr].history.length; i++ ){
        emit showHistoryEntry( car_accounts[_adr].history[i].date, car_accounts[_adr].history[i].garage, car_accounts[_adr].history[i].content);
    }
    

}

}
