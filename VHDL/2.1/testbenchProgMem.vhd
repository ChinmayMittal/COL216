-- Testbench for program memory
library IEEE;
use IEEE.std_logic_1164.all;
 
entity testbenchProgMem is
-- empty
end testbenchProgMem; 

architecture tb of testbenchProgMem is

-- DUT component
component ProgramMemory is
port(
	address: in std_logic_vector( 1 downto 0 ) ; 
	data_out : out std_logic_vector( 31 downto 0 ) 
) ; 
end component;

signal address_tb: std_logic_vector( 1 downto 0 ) := "00" ;
signal data_out_tb : std_logic_vector( 31 downto 0 ) ; 

begin

  -- Connect DUT
  DUT: ProgramMemory port map(address_tb , data_out_tb );

  process
  begin
    address_tb <= "01";
    wait for 1 ns;
--     assert(q_out='0') report "Fail 0/0" severity error;
  	address_tb <= "00";
    wait for 1 ns;
    address_tb <= "10";
    wait for 1 ns;
    address_tb <= "11";
    wait for 1 ns;


    assert false report "Test done." severity note;
    wait;
  end process;
end tb;
