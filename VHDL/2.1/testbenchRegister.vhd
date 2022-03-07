-- Testbench for Register File 
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all ;
entity testbenchRegister is
-- empty
end testbenchRegister; 

architecture tb of testbenchRegister is

-- DUT component
component RegisterFile is
port(
		read_add1 : in std_logic_vector( 3 downto 0) ; 
		read_add2 : in std_logic_vector( 3 downto 0 ); 
		write_add : in std_logic_vector( 3 downto 0 ) ;
		data_in : in std_logic_vector( 31 downto 0 ) ; 
		clk:  in std_logic ; 
		WE : in std_logic ; 
		output_1 : out std_logic_vector(31 downto 0) ; 
		output_2 : out std_logic_vector( 31 downto 0 )   
); 
end component ; 
signal read_add1_tb,read_add2_tb, write_add_tb : std_logic_vector(3 downto 0 );
signal data_in_tb , output_1_tb , output_2_tb : std_logic_vector( 31 downto 0 ) ; 
signal  WE_tb : std_logic := '0' ; 
signal clk_tb: std_logic := '0';
begin

  -- Connect DUT design under test 
  DUT: RegisterFile port map(read_add1_tb , read_add2_tb, write_add_tb , data_in_tb , clk_tb , WE_tb , output_1_tb , output_2_tb) ;

  process
  begin 
    WE_tb <= '1' ; 
    data_in_tb  <= x"01010001" ;
    write_add_tb <= x"0" ; 
    wait for 0.1 ns ;
    
    clk_tb <= '1'; 
    wait for 0.1 ns ; 
	
    read_add1_tb <= x"0" ; 
    read_add2_tb <= x"0";
    clk_tb <= '0' ; 
    wait for 0.1 ns ; 
    
    WE_tb <= '1' ; 
    data_in_tb  <= x"11111111" ; 
    write_add_tb <= x"2" ; 
    wait for 0.1 ns ; 
    
    clk_tb <='1' ; 
    wait for 0.1 ns ;
    
    read_add1_tb <= x"2" ; 
    read_add2_tb <= x"0";
    clk_tb <= '0' ; 
    WE_tb <= '0' ; 
    write_add_tb <= x"9" ; 
    wait for 0.1 ns ; 
    
    
    clk_tb <= '1' ; 
    wait for 0.1 ns ; 
	
    read_add2_tb <= x"9" ; 
    wait for 0.1 ns ; 
    

    assert false report "Test done." severity note;
    wait;
  end process;
end tb;