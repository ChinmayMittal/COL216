-- Testbench for ALU 
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all ;
use work.types.all  ; 

entity testbenchALU is
-- empty
end testbenchALU; 

architecture tb of testbenchALU is

-- DUT component
component ALU is
port(
	a : in std_logic_vector(31 downto 0) ; 
	b : in std_logic_vector( 31 downto 0 ) ; 
	opcode:  in optype ; 
	cin : in std_logic ; 
	cout : out std_logic ; 
	result : out std_logic_vector ( 31 downto 0) 
) ; 
end component ; 
signal a_in, b_in, q_out: std_logic_vector(31 downto 0 );
signal opcode_in : optype  ; 
signal cin_in , cout_out : std_logic ; 

begin

  -- Connect DUT
  DUT: ALU port map(a_in, b_in, opcode_in , cin_in , cout_out , q_out);
 
  process
  begin
    a_in <= x"00000000";
    b_in <= x"00000001";
    cin_in <= '1' ; 
    opcode_in <= addc ; 
    wait for 0.1 ns;
    assert(q_out=x"00000002") report "Fail 1" severity error;
    
    a_in <= x"00000000";
    b_in <= x"00000001";
    cin_in <= '1' ; 
    opcode_in <= tst ; 
    wait for 0.1 ns;
    assert(q_out=x"00000000") report "Fail 2" severity error;
    
    a_in <= x"00000000";
    b_in <= x"00000001";
    cin_in <= '1' ; 
    opcode_in <= orr ; 
    wait for 0.1 ns;
    assert(q_out=x"00000001") report "Fail 3" severity error;
    
    a_in <= x"00000000";
    b_in <= x"00000001";
    cin_in <= '1' ; 
    opcode_in <= eor ;
    wait for 0.1 ns;
    assert(q_out=x"00000001") report "Fail 4" severity error;
    
    a_in <= x"00000000";
    b_in <= x"00000001";
    cin_in <= '1' ; 
    opcode_in <= mov ; 
    wait for 0.1 ns;
    assert(q_out=x"00000001") report "Fail 5" severity error;
  
    a_in <= x"00000000";
    b_in <= x"00000001";
    cin_in <= '1' ; 
    opcode_in <= mvn ; 
    wait for 0.1 ns;
    assert(q_out=x"fffffffe") report "Fail 6" severity error;
    
    a_in <= x"00000000";
    b_in <= x"00000001";
    cin_in <= '1' ; 
    opcode_in <= bic ; 
    wait for 0.1 ns;
    assert(q_out=x"00000000") report "Fail 7" severity error;
    
    a_in <= x"00000000";
    b_in <= x"1111111f";
    cin_in <= '1' ; 
    opcode_in <= sbc ; 
    wait for 0.1 ns;
    assert(q_out=x"eeeeeee1") report "Fail 8" severity error;

    a_in <= x"00020500";
    b_in <= x"11111111";
    cin_in <= '1' ; 
    opcode_in <= add ; 
    wait for 0.1 ns;
    assert(q_out=x"11131611") report "Fail 9" severity error;

    a_in <= x"f0020500";
    b_in <= x"11111111";
    cin_in <= '1' ; 
    opcode_in <= add ; 
    wait for 0.1 ns;
    assert(q_out=x"01131611") report "Fail 9" severity error;
    assert( cout_out = '1') report "Fail 9 part 2" severity error ; 
    
    assert false report "Test done." severity note;
    wait;
  end process;
end tb;