# Aurum 
## Pre-processor goodness for Solidity 

Aurum is a small tool to simplify Solidity programming. 

## Overview and Usage

Aurum adds #include and #require in Solidity code to reference inherited contracts and external contracts.


Turn monolithic contract files like this:

```
contract ExternalContract{function someFunction();}

contract Foobarbaz {
  address owner;
  uint somevalue;

  function Foobarbaz() {
    owner = msg.sender;
    somevalue = 31337;
  }
}


contract Foobar is Foobarbaz {

   function callExternal(address eca) {

     ExternalContract ec = ExternalContract(eca);
     ec.someFunction();
   }
}

contract Foobarfizz is Foobarbaz {

}
```

Into this:

**Foobar.aur**

```
#include [Foobarbaz]
#require [ExternalContract]

contract Foobar is Foobarbaz {

   function callExternal(address eca) {

     ExternalContract ec = ExternalContract(eca);
     ec.someFunction();
   }
}
```

**Foobarbaz.lau**
```
contract Foobarbaz {
  address owner;
  uint somevalue;

  function Foobarbaz() {
    owner = msg.sender;
    somevalue = 31337;
  }
}
```

**ExternalContract.aur**

```
contract ExternalContract {
  function someFunction() {

  }
}
```

## Processing

Run the following to generate the Solidity output

```
aurum source_dir  target_dir
```




