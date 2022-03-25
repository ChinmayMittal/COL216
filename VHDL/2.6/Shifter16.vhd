library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Shifter16 is
port(
		data_in : in std_logic_vector( 31 downto 0) ; 
		shiftType: in std_logic_vector( 1 downto 0 ) ;  
		select4 : in std_logic ;
		carry_in : in std_logic ; 		
		data_out: out std_logic_vector( 31 downto 0 ) ;
		carry_out : out std_logic 
);
end Shifter16 ;


architecture arch of Shifter16 is 

begin
process( carry_in , select4, shiftType, data_in )
begin
if( (select4 = '0')) then 
data_out <= data_in ; 
carry_out <= carry_in ; 
elsif( select4 = '1'  and shiftType = "00") then 
-- Logical left shift 
carry_out <= data_in(16) ; 
data_out <= std_logic_vector(shift_left(unsigned(data_in), 16));
elsif( select4 = '1' and shiftType = "01" ) then 
-- Logical right shift 
carry_out <= data_in(15) ; 
data_out <= std_logic_vector(shift_right(unsigned(data_in), 16));
elsif( select4 = '1' and shiftType = "10" ) then 
-- arithmetic right shift 
carry_out <= data_in(15) ; 
data_out <= std_logic_vector(shift_right(signed(data_in),16));
elsif( select4 = '1' and shiftType = "11" ) then 
-- rotate right 
carry_out <= data_in(15) ; 
data_out <= ( data_in( 15 downto 0 ) & data_in( 31 downto 16 )) ; 
else 
carry_out <= carry_in ; 
data_out <= data_in ; 
end if ; 

end process ; 
end arch ; 