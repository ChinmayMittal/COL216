-- Testbench for Data Memory 
library IEEE;
use IEEE.std_logic_1164.all;
 
entity testbenchDataMem is
-- empty
end testbenchDataMem; 

architecture tb of testbenchDataMem is

-- DUT component
component DataMemory is
port(
	CLK : in std_logic ;
	WE : in std_logic_vector( 3 downto 0 ) ; 
	data_in  : in std_logic_vector( 31 downto 0 ) ; 
	data_out : out std_logic_vector( 31 downto 0 ) ; 
	read_add , write_add : in std_logic_vector( 5 downto 0) 
);
end component;

signal CLK_tb : std_logic := '0' ; 
signal data_in_tb , data_out_tb : std_logic_vector( 31 downto 0 ) ; 
signal WE_TB : std_logic_vector( 3 downto 0 ) ; 
signal read_add_tb , write_add_tb : std_logic_vector( 5 downto 0 ) ; 

begin

  -- Connect DUT
  DUT: DataMemory port map(CLK_tb ,WE_TB , data_in_TB , data_out_TB ,read_add_tb , write_add_tb );

  process
  begin
	WE_TB <= "1111" ; 
    write_add_tb <= "000000";
    data_in_tb <= x"11111111" ;
    read_add_tb <= "000000" ; 
    wait for 0.1 ns ; 
    
    CLK_TB <= '1' ; 
    wait for 0.1 ns ; 

    
    CLK_TB <= '0' ; 
    WE_TB <= "1010" ; 
    data_in_tb <= x"00000000" ;
    wait for 0.1 ns ; 
    
    CLK_TB <= '1' ; 
    wait for 0.1 ns ; 

    assert false report "Test done." severity note;
    wait;
  end process;
end tb;