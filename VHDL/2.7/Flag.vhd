library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.MyTypes.all;
use IEEE.NUMERIC_STD.ALL;

entity Flag is 
port(
	S , Fset: in std_logic ; 
	ALU_result : in std_logic_vector( 31 downto 0 ) ; 
	ALU_carry : in std_logic ; 
	Shift_carry : in std_logic ; 
	MSB_a : in std_logic ; 
	MSB_b : in std_logic ; 
	isShift : in std_logic ; 
	instr_class : in instr_class_type;
	DP_subclass : in DP_subclass_type;
	operation : in optype;
	clk : in std_logic ; 
	Z, C , N , V : out std_logic 
);
end Flag ; 


architecture arch of Flag is 
signal MSB_ALU : std_logic := '0' ; 
constant allZeros : std_logic_vector( 31 downto 0 ) := x"00000000" ; 
begin 
MSB_ALU <= ALU_result(31) ; 

process(clk)
begin
if(rising_edge(clk) and ( instr_class = DP) and (Fset = '1')) then

	if( S = '0' ) then 
		if(DP_subclass = test) then
			if( ALU_result = allZeros ) then Z<='1' ;  else Z <= '0' ;  end if ; 
			N <= (ALU_result(31) ) ; 
		elsif( DP_subclass = comp) then
			C <= ALU_carry ; 
			if( ALU_result = allZeros ) then Z<='1' ;  else Z <= '0' ;  end if ; 
			N <= (ALU_result(31)) ; 
			-- handle v -- 
			if(  ( operation = cmp )  ) then V <= (   MSB_a and not MSB_b and  not MSB_ALU) or ( not MSB_a and  MSB_b and MSB_ALU) ;  elsif( operation = cmn ) then V <= (  MSB_a and MSB_b and  not MSB_ALU) or ( not MSB_a and not MSB_b and MSB_ALU) ; end if ; 
		end if ; 
	elsif ( S = '1' ) then 
		if( isShift = '1' ) then  
			if(DP_subclass = arith ) then
				C <= ALU_carry ; 
				if( ALU_result = allZeros ) then Z<='1' ;  else Z <= '0' ;  end if ; 
				N <= (ALU_result(31) ) ; 
				-- Handle V 
				if(  ( operation = sub ) or ( operation = sbc)  ) then V <= (   MSB_a and not MSB_b and  not MSB_ALU) or ( not MSB_a and  MSB_b and MSB_ALU) ;  elsif( (operation = add) or (operation = adc ) ) then V <= (  MSB_a and MSB_b and  not MSB_ALU) or ( not MSB_a and not MSB_b and MSB_ALU) ; elsif ( (operation = rsb) or (operation = rsc )) then  V <= ( ( not MSB_a and MSB_b and not MSB_ALU) or ( MSB_a and not MSB_b and MSB_ALU)) ; end if ; 				
			elsif(DP_subclass = comp ) then 
				C <= ALU_carry ; 
				if( ALU_result = allZeros ) then Z<='1' ;  else Z <= '0' ;  end if ; 
				N <= (ALU_result(31)  ) ; 
				-- Handle V --	
				if(  ( operation = cmp )  ) then V <= (   MSB_a and not MSB_b and  not MSB_ALU) or ( not MSB_a and  MSB_b and MSB_ALU) ;  elsif( operation = cmn ) then V <= (  MSB_a and MSB_b and  not MSB_ALU) or ( not MSB_a and not MSB_b and MSB_ALU) ; end if ; 		
			elsif(DP_subclass = logic) then 
				C <= Shift_carry ; 
				if( ALU_result = allZeros ) then Z<='1' ;  else Z <= '0' ;  end if ; 
				N<= (ALU_result(31) ) ; 			
			elsif(DP_subclass = test ) then 
				C <= Shift_carry ; 
				if( ALU_result = allZeros ) then Z<='1' ;  else Z <= '0' ;  end if ; 
				N <= (ALU_result(31) ) ; 			
			end if ; 
		elsif( isShift = '0' ) then
			if(DP_subclass = arith ) then
				C <= ALU_carry ; 
				if( ALU_result = allZeros ) then Z<='1' ;  else Z <= '0' ;  end if ;  
				N<= (ALU_result(31)) ; 
				-- Handle V 	-- 
				if(  ( operation = sub ) or ( operation = sbc)  ) then V <= (   MSB_a and not MSB_b and  not MSB_ALU) or ( not MSB_a and  MSB_b and MSB_ALU) ;  elsif( (operation = add) or (operation = adc ) ) then V <= (  MSB_a and MSB_b and  not MSB_ALU) or ( not MSB_a and not MSB_b and MSB_ALU) ; elsif ( (operation = rsb) or (operation = rsc )) then  V <= ( ( not MSB_a and MSB_b and not MSB_ALU) or ( MSB_a and not MSB_b and MSB_ALU)) ; end if ; 		
			elsif(DP_subclass = comp ) then 
				C <= ALU_carry ; 
				if( ALU_result = allZeros ) then Z<='1' ;  else Z <= '0' ;  end if ; 
				N <= (ALU_result(31)) ; 
				-- Handle V -- 
				if(  ( operation = cmp )  ) then V <= (   MSB_a and not MSB_b and  not MSB_ALU) or ( not MSB_a and  MSB_b and MSB_ALU) ;  elsif( operation = cmn ) then V <= (  MSB_a and MSB_b and  not MSB_ALU) or ( not MSB_a and not MSB_b and MSB_ALU) ; end if ; 
			elsif(DP_subclass = logic) then 
				if( ALU_result = allZeros ) then Z<='1' ;  else Z <= '0' ;  end if ;  
				N <= (ALU_result(31) ) ; 				
			elsif(DP_subclass = test ) then 
				if( ALU_result = allZeros ) then Z<='1' ;  else Z <= '0' ;  end if ;  
				N <= (ALU_result(31) ) ; 				
			end if ; 		
		end if ; 
	end if ; 	
end if ; 	
end process ;  


end arch ; 