library IEEE ; 
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all ;


entity Memory is 

port(
	clk : in std_logic ;
	WE : in std_logic_vector( 3 downto 0 ) ; 
	data_in  : in std_logic_vector( 31 downto 0 ) ; 
	data_out : out std_logic_vector( 31 downto 0 ) ; 
	read_add , write_add : in std_logic_vector( 6 downto 0) 
);

end Memory ; 


architecture MemoryArch of Memory is 

type MEM is array( 0 to 127) of std_logic_vector( 31 downto 0 ) ;
signal MEMORY : MEM := ( 0 => X"e3a01020",
1 => X"e3a02e12",
2 => X"e1c120b0",
3 => X"e1c120b2",
4 => x"e5913000" , 
5 => x"e5d13001" , 
others => X"00000000"

); 
begin

	data_out <= MEMORY(to_integer(unsigned(read_add))); 

	process(CLK)
	begin 
		if(rising_edge(clk))
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
				MEMORY(to_integer(unsigned(write_add)))( 23 downto 16) <= data_in( 23 downto 16 ) ; 
			end if ;
			if(WE(3) = '1') 
			then
				MEMORY(to_integer(unsigned(write_add)))( 31 downto 24)  <= data_in( 31 downto 24 ) ; 
			end if ; 		  
		end if ; 
	end process ; 

end MemoryArch ;