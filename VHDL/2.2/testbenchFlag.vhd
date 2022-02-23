-- Testbench for Flag
library IEEE;
use IEEE.std_logic_1164.all;
use work.MyTypes.all;
entity testbenchFlag is
-- empty
end testbenchFlag; 

architecture tb of testbenchFlag is

-- DUT component
component Flag is 
port(
	S : in std_logic ; 
	ALU_result : in std_logic_vector( 31 downto 0 ) ; 
	ALU_carry : in std_logic ; 
	Shift_carry : in std_logic ; 
	MSB_a : in std_logic ; 
	MSB_b : in std_logic ; 
	isShift : in std_logic ; 
	instr_class : in instr_class_type;
	DP_subclass : in DP_subclass_type;
	operation : in optype;
	clk : in std_logic ; 
	Z, C , N , V : out std_logic 
);
end component ;

signal	S :  std_logic ; 
signal	ALU_result :  std_logic_vector( 31 downto 0 ) ; 
signal	ALU_carry :  std_logic ; 
signal	Shift_carry :  std_logic ; 
signal	MSB_a :  std_logic ; 
signal	MSB_b :  std_logic ; 
signal	isShift :  std_logic := '0' ; 
signal	instr_class :  instr_class_type;
signal	DP_subclass :  DP_subclass_type;
signal	operation :  optype;
signal	clk :  std_logic ; 
signal	Z, C , N , V :  std_logic ; 

begin

  -- Connect DUT
  DUT: Flag port map(S , ALU_result , ALU_carry , Shift_carry , MSB_a , MSB_b , isShift , instr_class , DP_subclass , operation , clk  );

  process
  begin
  	-- cmp 0 , 0 
	S <= '1' ; 
  	MSB_a <= '0' ; 
    MSB_b <= '0' ; 
    operation <= cmp ; 
    DP_subclass <= comp ; 
    instr_class <= DP ; 
    ALU_result <= x"00000000" ; 
    ALU_carry <= '0' ; 
    clk <= '0' ; 
    wait for 1 ns;

	clk <= '1' ; 
    wait for 1 ns ; 
	
    -- cmp 1 , 2 
	S <= '1' ; 
  	MSB_a <= '0' ; 
    MSB_b <= '0' ; 
    operation <= cmp ; 
    DP_subclass <= comp ; 
    instr_class <= DP ; 
    ALU_result <= x"ffffffff" ; 
    ALU_carry <= '0' ; 
    clk <= '0' ; 
    wait for 1 ns;

	clk <= '1' ; 
    wait for 1 ns ;     
    assert false report "Test done." severity note;
    wait;
  end process;
end tb;
