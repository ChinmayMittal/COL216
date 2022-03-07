--Librarires
library IEEE ; 
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all ;

entity ProgramMemory is 

port(
	address: in std_logic_vector( 5 downto 0 ) ; 
	data_out : out std_logic_vector( 31 downto 0 ) 
) ; 

end ProgramMemory ; 

-- only read put, without clock
architecture ProgramMemoryArch of ProgramMemory is 
	type MemoryType is array( 0 to 63 ) of std_logic_vector( 31 downto 0 ) ; 
	-- INITIALIZING PROGRAM MEMORY WITH RANDOM VALUES FOR TESTING 
	signal ProgMem : MemoryType := ( 0 => x"11111111" , 1 => x"11110000" , 2 => x"10101010" , others => x"00000000"); 
begin
process(address)
begin
	data_out <= ProgMem(to_integer(unsigned(address))) ; 
end process ; 
end ProgramMemoryArch ; 