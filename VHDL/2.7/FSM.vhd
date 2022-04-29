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
signal DT_operand_src : in DT_operand_src_type ; 
signal DP_shift_src : in DP_shift_src_type ; 
signal DT_instr : in  DT_instr_type  ; 
signal WriteBack, PreIndexing  : in std_logic ;
signal isMultiplication : in std_logic ; -- new   
signal mul_instr : in mul_instr_type ; -- new 
signal RegisterWriteSrc : out std_logic ;  
signal RdLoW : out std_logic ; -- new 
signal M2R : out std_logic_vector( 1 downto 0 )  ; 
signal PW , IW , DW , IorD , AW , BW , RW , Rsrc1 , Rsrc2  , RsW , DT_offsetW , shifterW ,  Asrc1  , ALU_carry_src  , Fset  , ReW: out std_logic ;
signal Asrc2 : out std_logic_vector( 1 downto 0 ) ;
signal MW : out std_logic_vector( 3 downto 0 ) ; 
signal ALU_op : out optype ; 
signal ShifterAmtSrc, shift_data_in_src: out std_logic_vector( 1 downto 0 ) ; 
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
elsif( state  = s1 and ( instr_class = DP or ( isMultiplication = '1' ) ) ) then 
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

process(state , instr_class  , predicate , instr_class , load_store , DP_operand_src ,  DP_subclass , DT_offset_sign  , operation   , DT_operand_src , DP_shift_src , WriteBack , isMultiplication  ) 
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
 RegisterWriteSrc <= '0' ; -- reset after write back in state s6 
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
  if( ( instr_class = DT and load_store = store  and isMultiplication = '0') ) then -- store instruction and multiplication not happening 
  Rsrc2 <= '1' ; 
  else Rsrc2 <= '0' ; 
  end if ; 
when s2 => 
 -- this state will do ALU operation for DP instructions or will write answer of multiply instruction to register specified by IR( 19 to 16 )
  -- old signals 
 AW <= '0' ;
 BW <= '0' ; 
 shifterW <= '0' ; 
 -- new signals 
 Fset <= predicate and ( not isMultiplication ) ; 
 ALU_op <= operation ; 
 ReW <= predicate ; 
 Asrc1 <= '1' ; 
 Asrc2 <= "00" ; -- output of shifter is fed into the ALU 
 -- write to register file for Multiply operations
 if(  ( predicate = '1' and isMultiplication = '1' )  ) then 
	RW <= '1' ; 
 else 
	RW <= '0' ;
 end if ; 	
 RegisterWriteSrc <= '1' ; -- write to register specified by instruction( 19 to 16 )
  -- for long multiply instructions write upper half for mla or mul write lower half 
 if( ( mul_instr = mul or mul_instr = mla ) ) then 
	M2R <= "10" ; 
 else 
  M2R <= "11" ; 
 end if ; 
--	 M2R <=  "10" when ( mul_instr = mul or mul_instr = mla ) else "11" ; -- for long multiply instructions write upper half for mla or mul write lower half 
when s3 => 
 -- old signals 
 Fset <= '0' ; 
 ReW <= '0' ; 
 -- new signals
 -- write ALU output to register or if long mulitplication then write the lower part of the result 
 if(  (predicate = '1' ) and ( ( instr_class = DP and (DP_subclass = arith or DP_subclass = logic) and isMultiplication = '0' )  or ( isMultiplication = '1' and ( mul_instr /= mul and mul_instr /= mla )) ) ) then -- error here 
 RW <= '1' ; -- test and compare instructions should not write to register file 
 else 
 RW <= '0' ; 
 end if ; 
 RegisterWriteSrc <= '0' ; 
  -- either we write result of ALU or lower half of long multiplication instructions
 if( isMultiplication = '0'  ) then 
	 M2R <= "00" ; 
 else 
	M2R <= "10"; 
 end if ; 
--	 M2R <= "00" when ( isMultiplication = '0' ) else "10" ; -- either we write result of ALU or lower half of long multiplication instructions 
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
 Rsrc2 <= '1' ; -- read register specified by IR( 15 downto 12) for multiply instructions 
 RdLoW <= '1' ; 
 RsW <= '1' ; -- Rs contains value specified by shift register 
when B => 
 -- this state prepares the value for the second operand 
  --old signals 
  RsW <= '0' ; 
  RdLoW <= '0' ; 
  Rsrc2 <= '0' ; 
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
  RW <= WriteBack ; -- update base register if required 
  M2R <= "00" ; -- write data for register is in RES 
  RegisterWriteSrc <= '1' ; -- base register is to be updated 
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
  -- handle write back 
  RW <= WriteBack ; -- update base register if required 
  M2R <= "00" ; -- write data for register is in RES 
  RegisterWriteSrc <= '1' ; -- base register is to be updated 		
when others => -- s8 
 --old signals 
 DW <= '0' ; 
 -- new signals 
 RegisterWriteSrc <= '0' ; -- destination register is to be updated 
 RW <= predicate ; 
 M2R <= "01" ; -- write data read from memory 

end case ; 

end process ;  



end FSMarch ; 