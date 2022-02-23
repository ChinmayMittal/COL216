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


begin

  -- Cnnect DUT
  DUT: Processor port map( clk_tb ,  reset_tb) ;

  process
  begin
  	reset_tb <= '1' ;
    wait for 1 ns ; 
    
    clk_tb <= '1' ;  
    wait for 1ns ; 
    
    clk_tb <= '0' ; 
    reset_tb <= '0' ; 
    wait for 1 ns ; 
    
    clk_tb <= '1' ; 
    wait for 1 ns;
        
    clk_tb <= '0' ; 
    wait for 1 ns ; 
    
    clk_tb <= '1' ; 
    wait for 1 ns;
    
    clk_tb <= '0' ; 
    wait for 1 ns ; 
    
    clk_tb <= '1' ; 
    wait for 1 ns;
    
    clk_tb <= '0' ; 
    wait for 1 ns ; 
    
    clk_tb <= '1' ; 
    wait for 1 ns;
    
    clk_tb <= '0' ; 
    wait for 1 ns ; 
    
    clk_tb <= '1' ; 
    wait for 1 ns;
    
    clk_tb <= '0' ; 
    wait for 1 ns ; 
    
    clk_tb <= '1' ; 
    wait for 1 ns;
    
    clk_tb <= '0' ; 
    wait for 1 ns ; 
    
    clk_tb <= '1' ; 
    wait for 1 ns;
  
    assert false report "Test done." severity note;
    wait;
  end process;
end tb;