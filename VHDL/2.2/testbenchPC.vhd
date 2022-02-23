-- Testbench for PC 
library IEEE;
use IEEE.std_logic_1164.all;
use work.MyTypes.all;

entity testbenchPC is
-- empty
end testbenchPC ; 

architecture tb of testbenchPC is

-- DUT component
component PC is 
port(
	instr_class : in instr_class_type;
	branchOffset : in std_logic_vector( 23 downto 0 ) ; 
    condTrue : in std_logic ; 
	pc_in : in std_logic_vector( 31 downto 0 ) ; 
	pc_out : out std_logic_vector( 31 downto 0 ) 
);
end component ; 

signal	instr_class_tb :  instr_class_type;
signal	condTrue_tb :  std_logic := '0' ; 
signal	branchOffset_tb :  std_logic_vector( 23 downto 0 ) ; 
signal	pc_in_tb , pc_out_tb : std_logic_vector( 31 downto 0 ) := x"00000008";

begin

  -- Cnnect DUT
  DUT: PC port map( instr_class_tb,  branchOffset_tb ,condTrue_tb,   pc_in_tb , pc_out_tb ) ;

  process
  begin
        
    instr_class_tb <= DP ; 
    wait for 1 ns;
 

    instr_class_tb <= BRN ; 
    branchOffset_tb <= x"000002" ;
    condTrue_tb <= '1' ;
    wait for 1 ns ; 
    

    condTrue_tb <= '0' ; 
    wait for 1 ns ; 
    
	condTrue_tb <= '1' ; 
    branchOffset_tb <= x"fffffc"; 
    wait for 1 ns ; 
   
    assert false report "Test done." severity note;
    wait;
  end process;
end tb;