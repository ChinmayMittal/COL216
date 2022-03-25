library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.MyTypes.all;
use IEEE.NUMERIC_STD.ALL;

entity PMconnect is
port(
Rout, Mout: in std_logic_vector( 31 downto 0 ) ; 
AD : in std_logic_vector( 1 downto 0 ) ; 
DT_instruction : in DT_instr_type ; 
Rin, Min : out std_logic_vector( 31 downto 0 ) ; 
MW : out std_logic_vector( 3 downto 0 )   

);
end PMconnect ; 


architecture arch of PMconnect is 
signal allOnes : std_logic_vector( 7 downto 0 ) := x"ff" ;
signal allZeros : std_logic_vector( 7 downto 0 ) := x"00" ; 
signal allA , allB , allC , allD : std_logic_vector( 7 downto 0 ) ; 
signal DTTYPE : std_logic_vector( 2 downto 0 ) ; 
begin 

allA <= allOnes when ( Mout(7) = '1' ) else allZeros ; 
allB <= allOnes when ( Mout(15) = '1' ) else allZeros ; 
allC <= allOnes when ( Mout(23) = '1' ) else allZeros ; 
allD <= allOnes when ( Mout(31) = '1' ) else allZeros ; 
 
process( Rout, Mout, AD, DT_instruction , allA , allB , allC , allD  )
begin 
case DT_instruction is 

when str => 
	MW <= "1111" ; 
	Min <= Rout ; 
	DTTYPE <= "001" ; 
when strh => 

	case AD is 
			 when   "00"   => MW <= "0011"  ; 
			 when   "10"   => MW <= "1100"  ; 
			 when others => MW <= "0000" ;  
	end case ; 
	Min <= Rout( 15 downto 0 ) & Rout( 15 downto 0 ) ; 	
	DTTYPE <= "110" ; 
when strb => 
	case AD is 
			  when "00"   => MW <=   "0001" ;   
			  when  "01"  => MW <=  "0010" ; 
			  when  "10"  => MW <=  "0100" ; 
			  when  "11"  => MW <=  "1000" ;  	 
			  when others => MW <=  "0000" ;   
	end case ; 
	Min <= Rout( 7 downto 0 ) & Rout( 7 downto 0 ) & Rout( 7 downto 0 ) & Rout( 7 downto 0 ) ; 	
	DTTYPE <= "010" ; 
when ldr => 
	Rin <= Mout ;
	DTTYPE <= "000" ; 
when ldrh => 

	case AD is 
			 when   "00"   =>  Rin <=allZeros & allZeros &  Mout( 15 downto 0 ); 
			 when   "10"   =>  Rin <= allZeros & allZeros & Mout( 31 downto 16 ) ; 
			 when others =>    Rin <= allZeros & allZeros & allZeros &  allZeros;     
	end case ; 
	DTTYPE <= "101" ; 
when ldrsh => 
	case AD is 
			 when   "00"   =>  Rin <= allB & allB &  Mout( 15 downto 0 ); 
			 when   "10"   =>  Rin <= allD & allD & Mout( 31 downto 16 ) ; 
			 when others =>    Rin <= allZeros & allZeros & allZeros &  allZeros;     
	end case ; 
	DTTYPE <= "111" ; 
when ldrb => 
	case AD is 
			 when "00"   => Rin <=  allZeros & allZeros & allZeros &  Mout( 7 downto 0 );   
			 when  "01"  => Rin <=   allZeros & allZeros & allZeros &  Mout( 15 downto 8 );
			 when  "10"  => Rin <=   allZeros & allZeros & allZeros &  Mout( 23 downto 16 );
			 when  "11"  => Rin <=   allZeros & allZeros & allZeros &  Mout( 31 downto 24 ); 
			 when others => Rin <=   allZeros & allZeros & allZeros &  allZeros;  
	end case ; 
	DTTYPE <= "011" ; 	 		 
when ldrsb => 
	case AD is 
			 when "00"   => Rin <=   allA & allA & allA &  Mout( 7 downto 0 );   
			 when  "01"  => Rin <=   allB & allB & allB &  Mout( 15 downto 8 );
			 when  "10"  => Rin <=   allC & allC & allC &  Mout( 23 downto 16 );
			 when  "11"  => Rin <=   allD & allD & allD &  Mout( 31 downto 24 ); 
			 when others => Rin <=   allZeros & allZeros & allZeros &  allZeros;  
	end case ; 
	DTTYPE <= "100" ; 
when others => 
Rin <= x"00000000" ;
Min <= x"00000000" ;  
MW <= "1111" ; 
end case ; 
end process ; 
end arch ; 