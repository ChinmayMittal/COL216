-- Libraries
library IEEE ; 
use IEEE.std_logic_1164.all ; 
use IEEE.numeric_std.all ; 
--use IEEE.std_logic_unsigned.all ; 

entity RegisterFile is 
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
end RegisterFile ; 

architecture RegisterArch of RegisterFile is 
	type REGISTER_type is array( 0 to 15 ) of std_logic_vector(31 downto 0) ; 
	signal REG : REGISTER_type ;	
begin 

output_1 <= REG(to_integer(unsigned(read_add1)))  ; 
output_2 <= REG( to_integer(unsigned(read_add2))) ; 

process(clk)
begin
	if(rising_edge(clk)) then 
		if(WE='1') then
		REG(to_integer(unsigned(write_add))) <=  data_in ; 
		end if ; 
	end if ; 
end process ; 



end RegisterArch ; 