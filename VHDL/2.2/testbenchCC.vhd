-- Testbench for ConditionChecker
library IEEE;
use IEEE.std_logic_1164.all;
use work.MyTypes.all;

entity testbenchCC is
-- empty
end testbenchCC ; 

architecture tb of testbenchCC is

-- DUT component
component ConditionChecker is 
port(
	C, Z, N, V : in std_logic ;
	condition : in condtype ; 
	isTrue : out std_logic
);
end ConditionChecker ; 

signal C_tb , Z_tb , N_tb , V_tb , isTrue_tb : std_logic := '0' ; 
signal condition_tb : condtype ;

begin

  -- Cnnect DUT
  DUT: ConditionChecker port map(  C_tb , Z_tb , N_tb , V_tb , condition_tb , isTrue_tb ) ;

  process
  begin
  	   
  	Z_tb <= '1' ; 
    condition_tb <= EQ ; 
    wait for 1 ns ; 

    condition_tb <= NE ; 
    wait for 1 ns ; 
 
    condition_tb <= AL ; 
    wait for 1 ns ; 

    assert false report "Test done." severity note;
    wait;
  end process;
end tb;