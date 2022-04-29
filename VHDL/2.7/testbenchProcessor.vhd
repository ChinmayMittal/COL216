-- Testbench for Processor
library IEEE;
use IEEE.std_logic_1164.all;
use work.MyTypes.all;

entity testbenchProcessor is
-- empty
end testbenchProcessor ; 

architecture tb of testbenchProcessor is

-- DUT component
component Processor is
port(
 clk , reset : in std_logic ;
);
end component ; 

signal reset_tb , clk_tb : std_logic := '0' ; 
constant num_cycles : integer := 50 ; 


begin

  -- Cnnect DUT
  DUT: Processor port map( clk_tb ,  reset_tb) ;

  process
  begin
  	reset_tb <= '1' ;
    wait for 1.5 ns ; 
    
    clk_tb <= '1' ;  
    wait for 1.5 ns ; 
    
    reset_tb <= '0' ; 
    wait for 1.5 ns ; 
	
    for i in 1 to num_cycles loop
    	clk_tb<= '0' ; 
        wait for 1.5 ns ; 
        
        clk_tb <= '1' ; 
        wait for 1.5 ns ; 
	end loop ; 
  


    assert false report "Test done." severity note;
    wait;
  end process;
end tb;