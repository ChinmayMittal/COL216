library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.MyTypes.all;
use IEEE.NUMERIC_STD.ALL;

entity FSM is port(
signal clk , predicate  , reset : in std_logic ; 
signal instr_class : in instr_class_type ; 
signal load_store : in load_store_type ;  
signal DT_offset_sign : in DT_offset_sign_type ; 
signal DP_operand_src : in DP_operand_src_type;
signal DP_subclass : in DP_subclass_type;
signal operation : in optype ;
signal DT_operand_src : in DT_operand_src_type ; -- new 
signal DP_shift_src : in DP_shift_src_type ; -- new 
signal PW , IW , DW , IorD , AW , BW , RW , M2R  , Rsrc1 , Rsrc2  , RsW , DT_offsetW , shifterW ,  Asrc1  , ALU_carry_src  , Fset  , ReW: out std_logic ;
signal Asrc2 : out std_logic_vector( 1 downto 0 ) ;
signal MW : out std_logic_vector( 3 downto 0 ) ; 
signal ALU_op : out optype ; 
signal ShifterAmtSrc, shift_data_in_src: out std_logic_vector( 1 downto 0 ) ; -- new 
signal shiftTypesrc : out std_logic -- new 
) ; 
end FSM ; 

architecture FSMarch of FSM is 
signal state : state_type := s0 ; 
begin 

process(clk , reset )

begin
if(reset = '1' ) then 
state <= s0 ;  
elsif( rising_edge(clk)) then

	if( state = s0 ) then 
	state <= s1 ; 
	elsif( state  = s1 and instr_class = DP ) then 
	state <= A ;
	elsif( state = s1 and instr_class = DT ) then 
	state <= C ; 
	elsif( state = s1 and instr_class = BRN ) then
	state <= s5 ; 
	elsif( state = s2 ) then
	state <= s3 ; 
	elsif( state = s3 or state = s6 or state = s5 or state = s8 ) then 
	state <= s0 ; 
	elsif( state = s7 ) then
	state <= s8 ; 
	elsif(state = s4 and load_store = load ) then 
	state <= s7 ; 
	elsif( state = C ) then 
	state <= D ; 
	elsif ( state = D ) then 
	state <= s4 ; 
	elsif( state = A ) then 
	state <= B ; 
	elsif( state = B ) then 
	state <= s2 ;  
	else
	state <= s6 ; 
	end if ;
	
end if ;  
end process ;

process(state , instr_class  , predicate , instr_class , load_store , DP_operand_src ,  DP_subclass , DT_offset_sign  , operation   , DT_operand_src , DP_shift_src ) 
begin 
case state is 
when s0 => 
	--old signals
	 MW <= "0000" ;
	 RW <= '0' ;  
	 ReW <= '0' ; 
	 RsW <= '0' ; 
	 DT_offsetW <= '0' ; 
	 ALU_carry_src <= '1' ; 
	 AW <= '0' ; 
	 BW <= '0' ; 
	 DW <= '0' ; 
	 shifterW <= '0' ; 
	 -- new signals 
	 Iord <= '0' ; 
	 Asrc1 <= '0' ; 
	 Asrc2 <= "01" ;
	 ALU_op <= add ; 
	 Fset <= '0' ; -- this operation is not expected to set flags
	 PW <= '1' ;  
	 IW <= '1' ; 
 when s1 => 
	 --old signals to 0 
	  PW <= '0' ;
	  IW <= '0' ; 
	  -- new signals 
	  AW <= '1' ; 
	  BW <= '1' ; 
	  Rsrc1 <= '1' ; 
	  if( ( instr_class = DT and load_store = store ) ) then 
	  Rsrc2 <= '1' ; 
	  else Rsrc2 <= '0' ; 
	  end if ; 
 when s2 => 
	  -- old signals 
	 AW <= '0' ;
	 BW <= '0' ; 
	 shifterW <= '0' ; 
	 -- new signals 
	 Fset <= predicate  ; -- fixed error  
	 ALU_op <= operation ; 
	 ReW <= predicate ; 
	 Asrc1 <= '1' ; 
--	 if( DP_operand_src = reg) then 
--	 Asrc2 <= "00" ; 
--	 else Asrc2 <= "10" ; 
    Asrc2 <= "00" ; -- output of shifter is fed into the ALU 
 when s3 => 
	 -- old signals 
	 Fset <= '0' ; 
	 ReW <= '0' ; 
	 -- new signals
	 if(  (predicate = '1' ) and ( DP_subclass = arith or DP_subclass = logic ) ) then 
	 RW <= '1' ; -- test and compare instructions should not write to register file 
	 else 
	 RW <= '0' ; 
	 end if ; 
	 M2R <= '0' ; 
 when C => 
	 -- old signals 
	 AW <= '0' ;
	 BW <= '0' ; 
	 -- new signals read register specified by 3 to 0 
	 Rsrc2 <= '0' ; -- read register specifying offset 
	 DT_offsetW <= '1' ; 
 when D => 
  -- old signals 
    DT_offsetW <= '0' ;   
  -- new signals 
     shifterW <= '1' ; 
	  if( DT_operand_src = imm  ) then 
	  ShifterAmtSrc <= "01" ; 
	  shift_data_in_src <= "00" ; 
	  shiftTypesrc <= '0' ; -- redundant no rotation as amount is 0 
	  else 
	  -- DT operand from register 
	  ShifterAmtSrc <= "10" ; 
	  shift_data_in_src <= "11" ; 
	  shiftTypesrc <= '1' ;
	  end if ; 
	  
 when A => 
 	 -- old signals 
	 AW <= '0' ;
	 BW <= '0' ;
	-- new signals read the registers specifying the shift for the second operand of DP 
    Rsrc1 <= '0' ; -- read file specifying register 
	 RsW <= '1' ; -- Rs contains value specified by shift register 
when B => 
    -- this state prepares the value for the second operand 
     --old signals 
     RsW <= '0' ; 
     -- new signaLS 
     shifterW <= '1' ; 
  	 if( DP_operand_src = imm ) then 
	  ShifterAmtSrc <= "00" ; 
	  shift_data_in_src <= "10" ; 
	  shiftTypesrc <= '0' ; -- ROR rotation 
	  else 
	  -- DP source register 
	  ShifterAmtSrc <= "11" ; 
	  shift_data_in_src <= "01"; 
	  shiftTypesrc <= '1' ; 
	  end if ; 
 when s4 =>  
	  -- old signals 
	 AW <= '0' ;
	 BW <= '0' ; 
	 shifterW <= '0' ; 
	 -- new signals ? fset ? 
	 ReW <= '1' ; 
	 Asrc1 <= '1' ; -- base
	 Asrc2 <= "00" ; --offset 
	 if( ( DT_offset_sign = plus )  ) then 
	 ALU_op <= add ;
	 else ALU_op <= sub ; 
	 end if ; 									
 when s5 => 
	  -- old signals 
	 AW <= '0' ;
	 BW <= '0' ; 
	 -- new signals 
	 PW <= predicate ; 
	 Asrc1 <= '0' ; 
	 Asrc2 <= "11" ;
	 ALU_carry_src <= '0' ; 
	 ALU_op <= adc ;  
	 Fset <= '0' ; 
 when s6 => 
	 --old signals 
	  ReW <= '0' ; 
	  IorD <= '1' ; 
	 if( predicate = '1') then 
	 MW <= "1111" ; 
	 else MW <= "0000" ; 
	 end if ; 
 when s7 =>
	 --old signals 
	  ReW <= '0' ; 
	  -- new signals
	  DW <= '1' ; 
	  IorD <= '1' ; 
 
 when others => 
	 --old signals 
	 DW <= '0' ; 
	 -- new signals 
	 RW <= predicate ; 
	 M2R <= '1' ; 

 end case ; 

end process ;  



end FSMarch ; 
