-- Libraries
library IEEE ; 
use IEEE.std_logic_1164.all ; 
use IEEE.std_logic_unsigned.all ; 
use work.MyTypes.all;  -- Defines type optype 

entity ALU is 
port(
	a : in std_logic_vector(31 downto 0) ; 
	b : in std_logic_vector( 31 downto 0 ) ; 
	opcode:  in optype ; 
	cin : in std_logic ; 
	cout : out std_logic ; 
	result : out std_logic_vector ( 31 downto 0) 
) ; 
end ALU ; 
  
architecture arch of ALU is 

begin
process( a, b , cin , opcode ) 
variable temp : std_logic_vector(32 downto 0 ) := x"00000000" & "0"; 
begin
case opcode is
when andop =>
	result <= a and b ; 
	cout <= '0' ; 
when eor =>
	result <= a xor b ; 
	cout <= '0' ; 
when sub | cmp  => 
	temp := ( ( '0' & a )+ ('0' & (not b))+ '1' ) ; 
	result <=  temp( 31 downto 0 ) ;
	cout <= temp( 32 ) ; 
when rsb => 
	temp := ( ('0' & ( not a )) + ( '0' & b ) + '1' ) ; 
	result <=  temp( 31 downto 0 ) ;
	cout <= temp( 32 ) ; 
when add | cmn => 
	temp := (('0'&a)+('0' & b)) ; 
	result <=  temp( 31 downto 0 ) ;
	cout <= temp( 32 ) ; 
when adc  => 
	temp := ( ('0' & a) + ('0' & b) + cin ) ; 
	result <=  temp( 31 downto 0 ) ;
	cout <= temp( 32 ) ; 
when sbc => 
	temp := ( ('0' & a) + ('0' & ( not b)) + cin ) ; 
	result <=  temp( 31 downto 0 ) ;
	cout <= temp( 32 ) ; 
when rsc => 
	temp := ( ('0' & ( not a)) + ('0' & b) + cin ) ; 
	result <=  temp( 31 downto 0 ) ;
	cout <= temp( 32 ) ; 	
when tst => 
	result <= a and b ; 
	cout <= '0' ; 
when teq => 
	result <= a xor b ;
	cout <= '0' ; 
when orr => 
	result <= a or b ; 
	cout <= '0' ; 
when mov  => 
	result <= b ; 
	cout <= '0' ; 
when bic => 
	result <= a and ( not b )  ; 
	cout <= '0' ; 
when mvn => 
	result <= not b ; 
	cout <= '0' ;
when others => 
		cout <= cin  ;
		result <= a ; 
		
end case ; 
end process ; 
end architecture arch ; 