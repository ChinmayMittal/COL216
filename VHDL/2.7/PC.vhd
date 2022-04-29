library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.MyTypes.all;
use IEEE.NUMERIC_STD.ALL;

entity PC is 
port(
   clk , PW , reset  : in std_logic ;  
	pc_in : in std_logic_vector( 31 downto 0 ) ; 
	pc_out : out std_logic_vector( 31 downto 0 ) 
);
end PC ; 

architecture arch of PC is
begin 

    process( clk  , reset )
    begin 
	 if( reset = '1' ) then 
		pc_out <= x"00000000" ; 
    elsif( rising_edge(clk) and (PW = '1')) then 
      pc_out <= pc_in ; 
    end if ; 
    end process ; 

end arch ; 