library IEEE ; 
use IEEE.std_logic_1164.all ; 
-- custom type for opcode 
package types is 
	type optype is ( andop, eor, sub , rsb , add , addc , sbc , rsc , tst , teq , cmp , cmn , orr , mov , bic , mvn ) ;
end types ; 