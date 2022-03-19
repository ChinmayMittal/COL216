-- Testbench for Shifter
library IEEE;
use IEEE.std_logic_1164.all;

entity testbenchShifter is
    -- empty
end testbenchShifter ; 
    
architecture tb of testbenchShifter is

component Shifter is
port(
	data_in : in std_logic_vector( 31 downto 0) ; 
	shiftType: in std_logic_vector( 1 downto 0 ) ;  
	shiftAmount: in std_logic_vector( 4 downto 0 ) ;
	data_out: out std_logic_vector( 31 downto 0 ) ; 
	carry : out std_logic 
);
end component ; 

signal data_in_tb, data_out_tb : std_logic_vector( 31 downto 0 ) ; 
signal shiftType_tb :  std_logic_vector( 1 downto 0 ) ; 
signal shiftAmount_tb :  std_logic_vector( 4 downto 0 ) ; 
signal carry_tb : std_logic  ; 

begin 

DUT: Shifter port map(
		data_in_tb , 
		shiftType_tb,   
		shiftAmount_tb , 
		data_out_tb, 
		carry_tb 
);

 process
  begin
  
  	data_in_tb <= x"f0000000" ; 
    shiftType_tb <= "00" ; 
    shiftAmount_tb <= "00010" ; 
  	wait for 1ns ; 
    
    data_in_tb <= x"f0000000" ; 
    shiftType_tb <= "01" ; 
    shiftAmount_tb <= "00010" ; 
  	wait for 1ns ; 
    
    data_in_tb <= x"f0000000" ; 
    shiftType_tb <= "10" ; 
    shiftAmount_tb <= "00010" ; 
  	wait for 1ns ;
    
    data_in_tb <= x"f0000001" ; 
    shiftType_tb <= "11" ; 
    shiftAmount_tb <= "00010" ; 
    wait for 1ns ;
    
    data_in_tb <= x"f0000001" ; 
    shiftType_tb <= "11" ; 
    shiftAmount_tb <= "00011" ; 
  	wait for 1ns ; 
    
    data_in_tb <= x"f0000001" ; 
    shiftType_tb <= "10" ; 
    shiftAmount_tb <= "00101" ; 
    wait for 1 ns ; 
    
    assert false report "Test done." severity note;
    wait;
 end process;

end tb ; 