library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Shifter2 is
port(
		data_in : in std_logic_vector( 31 downto 0) ; 
		shiftType: in std_logic_vector( 1 downto 0 ) ;  
		select1 : in std_logic ;
		carry_in : in std_logic ; 		
		data_out: out std_logic_vector( 31 downto 0 ) ;
		carry_out : out std_logic 
);
end Shifter2 ;


architecture arch of Shifter2 is 

begin
process( carry_in , select1, shiftType, data_in )
begin
if( (select1 = '0')) then 
data_out <= data_in ; 
carry_out <= carry_in ; 
elsif( select1 = '1'  and shiftType = "00") then 
-- Logical left shift 
carry_out <= data_in(30) ; 
data_out <= std_logic_vector(shift_left(unsigned(data_in), 2));
elsif( select1 = '1' and shiftType = "01" ) then 
-- Logical right shift 
carry_out <= data_in(1) ; 
data_out <= std_logic_vector(shift_right(unsigned(data_in), 2));
elsif( select1 = '1' and shiftType = "10" ) then 
-- arithmetic right shift 
carry_out <= data_in(1) ; 
data_out <= std_logic_vector(shift_right(signed(data_in), 2));
elsif( select1 = '1' and shiftType = "11" ) then 
-- rotate right 
carry_out <= data_in(1) ; 
data_out <= ( data_in( 1 downto 0 ) & data_in( 31 downto 2 )) ; 
else 
carry_out <= carry_in ; 
data_out <= data_in ; 
end if ; 

end process ; 
end arch ; 