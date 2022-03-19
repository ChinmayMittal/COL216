library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Shifter is
port(
		data_in : in std_logic_vector( 31 downto 0) ; 
		shiftType: in std_logic_vector( 1 downto 0 ) ;  
		shiftAmount: in std_logic_vector( 4 downto 0 ) ;
		data_out: out std_logic_vector( 31 downto 0 ) ; 
		carry : out std_logic 
);

end Shifter ;

architecture arch of Shifter is 

component Shifter1 is 
port(
		data_in : in std_logic_vector( 31 downto 0) ; 
		shiftType: in std_logic_vector( 1 downto 0 ) ;  
		select0 : in std_logic ;
		carry_in : in std_logic ; 		
		data_out: out std_logic_vector( 31 downto 0 ) ;
		carry_out : out std_logic 
);
end component ; 

component Shifter2 is 
port(
		data_in : in std_logic_vector( 31 downto 0) ; 
		shiftType: in std_logic_vector( 1 downto 0 ) ;  
		select1 : in std_logic ;
		carry_in : in std_logic ; 		
		data_out: out std_logic_vector( 31 downto 0 ) ;
		carry_out : out std_logic 
);
end component ;

component Shifter4 is 
port(
		data_in : in std_logic_vector( 31 downto 0) ; 
		shiftType: in std_logic_vector( 1 downto 0 ) ;  
		select2 : in std_logic ;
		carry_in : in std_logic ; 		
		data_out: out std_logic_vector( 31 downto 0 ) ;
		carry_out : out std_logic 
);
end component ;

component Shifter8 is 
port(
		data_in : in std_logic_vector( 31 downto 0) ; 
		shiftType: in std_logic_vector( 1 downto 0 ) ;  
		select3 : in std_logic ;
		carry_in : in std_logic ; 		
		data_out: out std_logic_vector( 31 downto 0 ) ;
		carry_out : out std_logic 
);
end component ;

component Shifter16 is 
port(
		data_in : in std_logic_vector( 31 downto 0) ; 
		shiftType: in std_logic_vector( 1 downto 0 ) ;  
		select4 : in std_logic ;
		carry_in : in std_logic ; 		
		data_out: out std_logic_vector( 31 downto 0 ) ;
		carry_out : out std_logic 
);
end component ;

signal data_out1, data_out2, data_out3, data_out4 : std_logic_vector( 31 downto 0 ) ; 
signal carry_out1, carry_out2, carry_out3, carry_out4 : std_logic  ; 
signal carry_initial : std_logic := '0' ; 
begin 

Shifter_1 : Shifter1 port map( data_in => data_in , 
					  shiftType => shiftType , 
					  select0 => shiftAmount(0) , 
					  carry_in => carry_initial  , 
					  data_out => data_out1, 
					  carry_out => carry_out1 ) ; 
					  
Shifter_2 : Shifter2 port map( data_in => data_out1 , 
					  shiftType => shiftType , 
					  select1 => shiftAmount(1) , 
					  carry_in => carry_out1  , 
					  data_out => data_out2, 
					  carry_out => carry_out2 ) ; 
					  
Shifter_4 : Shifter4 port map( data_in => data_out2 , 
					  shiftType => shiftType , 
					  select2 => shiftAmount(2) , 
					  carry_in => carry_out2  , 
					  data_out => data_out3, 
					  carry_out => carry_out3 ) ; 

Shifter_8 : Shifter8 port map( data_in => data_out3 , 
					  shiftType => shiftType , 
					  select3 => shiftAmount(3) , 
					  carry_in => carry_out3  , 
					  data_out => data_out4, 
					  carry_out => carry_out4 ) ; 					  

Shifter_16 : Shifter16 port map( data_in => data_out4 , 
					  shiftType => shiftType , 
					  select4 => shiftAmount(4) , 
					  carry_in => carry_out4  , 
					  data_out => data_out, 
					  carry_out => carry ) ; 	

end arch ; 