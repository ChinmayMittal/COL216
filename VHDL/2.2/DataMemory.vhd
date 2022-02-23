library IEEE ; 
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all ;


entity DataMemory is 

port(
	CLK : in std_logic ;
	WE : in std_logic_vector( 3 downto 0 ) ; 
	data_in  : in std_logic_vector( 31 downto 0 ) ; 
	data_out : out std_logic_vector( 31 downto 0 ) ; 
	read_add , write_add : in std_logic_vector( 5 downto 0) 
);

end DataMemory ; 


architecture DataMemoryArch of DataMemory is 

type MEM is array( 0 to 63) of std_logic_vector( 31 downto 0 ) ;
signal MEMORY : MEM ; 
begin
	data_out <= MEMORY(to_integer(unsigned(read_add))); 
	process(CLK)
	begin 
		if(rising_edge(CLK))
		then
			if(WE(0) = '1') 
			then
				MEMORY(to_integer(unsigned(write_add)))( 7 downto 0 ) <= data_in( 7 downto 0 ) ; 
			end if ; 
			if(WE(1) = '1') 
			then
				MEMORY(to_integer(unsigned(write_add)))( 15 downto 8) <= data_in( 15 downto 8) ; 
			end if ; 
			if(WE(2) = '1') 
			then
				MEMORY(to_integer(unsigned(write_add)))( 23 downto 16) <=data_in( 23 downto 16 ) ; 
			end if ;
			if(WE(3) = '1') 
			then
				MEMORY(to_integer(unsigned(write_add)))( 31 downto 24)  <=data_in( 31 downto 24 ) ; 
			end if ; 		  
		end if ; 
	end process ; 


end DataMemoryArch ; 