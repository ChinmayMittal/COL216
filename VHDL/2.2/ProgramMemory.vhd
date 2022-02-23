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
	signal ProgMem : MemoryType := ( 0 => X"E3A0000C",
1 => X"E3A01005",
2 => X"E5801000",
3 => X"E2811002",
4 => X"E5801004",
5 => X"E5902000",
6 => X"E5903004",
7 => X"E0434002",
others => X"00000000"


); 
begin
process(address)
begin
	data_out <= ProgMem(to_integer(unsigned(address))) ; 

end process ; 
end ProgramMemoryArch ; 