library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.MyTypes.all;
use IEEE.NUMERIC_STD.ALL;


entity Multiplier is
port(
 mul_instr : in mul_instr_type ;
 op1 , op2 : in std_logic_vector( 31 downto 0 ) ;
 op3 : in std_logic_vector( 63 downto 0 ) ; --  add operand , least significant 32 bits are important for mla and actual operand needs to be zero extended to 64 bits 
 res : out std_logic_vector( 63 downto 0 ) -- in case of mul or mla least significant 32 bits need to be extracted out in glue logic 
);
end Multiplier ;

architecture arch of Multiplier is 
signal p_s : signed( 65 downto 0 ) ; 
signal add : std_logic_vector( 63 downto 0 ) ; 
signal x1, x2 : std_logic ; 
begin 
x1 <= op1( 31 ) when ( mul_instr = smull or mul_instr = smlal ) else '0' ; 
x2 <= op2( 31 ) when ( mul_instr = smull or mul_instr = smlal ) else '0' ; 
p_s <= signed( x1 & op1 ) * signed( x2 & op2 ) ; 
add <= op3 when ( mul_instr = mla or mul_instr = smlal or mul_instr = umlal ) else x"0000000000000000" ; -- add operand is kept zero for non accumlate operations 
res <= std_logic_vector( p_s(63 downto 0 ) + signed(add) ); 
-- for mul or mla the least significant 32 bits contain the answer and can be extracted by glue logic in the processor 
end arch ; 
