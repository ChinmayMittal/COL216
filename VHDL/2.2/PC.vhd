library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.MyTypes.all;
use IEEE.NUMERIC_STD.ALL;

entity PC is 
port(
	instr_class : in instr_class_type;
	branchOffset : in std_logic_vector( 23 downto 0 ) ; 
    condTrue : in std_logic ; 
	pc_in : in std_logic_vector( 31 downto 0 ) ; 
	pc_out : out std_logic_vector( 31 downto 0 ) 
);
end PC ; 



architecture arch of PC is
	signal pcPlusEight : std_logic_vector( 31 downto  0 ) ; 
begin 

pcPlusEight <=   std_logic_vector(to_unsigned( (to_integer(unsigned(pc_in)) + 8 )  , 32  ) ); 

process(pc_in , branchOffset , condTrue , instr_class  )
begin 

   if( (condTrue='1') and (instr_class = BRN)) then 
    pc_out <=  std_logic_vector(to_unsigned( (to_integer(unsigned(pcPlusEight)) + to_integer(signed(branchOffset & "00")) )  , 32  ) ); 
      else 
    pc_out <=   std_logic_vector(to_unsigned( (to_integer(unsigned(pc_in)) + 4 )  , 32  ) ); 
   end if ; 
   
end process ; 
end arch ; 