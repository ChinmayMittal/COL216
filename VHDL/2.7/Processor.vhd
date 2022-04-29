library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.MyTypes.all;
use IEEE.NUMERIC_STD.ALL;

entity Processor is
port(
 clk , reset : in std_logic 
);
end Processor ; 


architecture arch of Processor is 

component PC is 
port(
   clk , PW , reset  : in std_logic ;  
	pc_in : in std_logic_vector( 31 downto 0 ) ; 
	pc_out : out std_logic_vector( 31 downto 0 ) 
);
end component ; 


component Memory is 

port(
	clk : in std_logic ;
	WE : in std_logic_vector( 3 downto 0 ) ; 
	data_in  : in std_logic_vector( 31 downto 0 ) ; 
	data_out : out std_logic_vector( 31 downto 0 ) ; 
	read_add , write_add : in std_logic_vector( 6 downto 0) 
);

end component ; 

component Decoder is 
port(
	instruction : in word;
	instr_class : out instr_class_type;
	operation : out optype;
	condition : out condtype ; 
	DP_subclass : out DP_subclass_type;
	DP_operand_src : out DP_operand_src_type;
	DT_operand_src : out DT_operand_src_type ;  
	DP_shift_src : out DP_shift_src_type ;   
	mul_instr : out mul_instr_type ; -- new 
	load_store : out load_store_type;
	branchOffset : out std_logic_vector( 23 downto 0 ) ; 
	DT_offset_sign : out DT_offset_sign_type ; 
	DT_instr : out DT_instr_type ; 
	S : out std_logic
) ; 
end component ; 

component ALU is 
port(
	a : in std_logic_vector(31 downto 0) ; 
	b : in std_logic_vector( 31 downto 0 ) ; 
	opcode:  in optype ; 
	cin : in std_logic ; 
	cout : out std_logic ; 
	result : out std_logic_vector ( 31 downto 0) 
) ; 
end component ; 

component RegisterFile is 
port(
		read_add1 : in std_logic_vector( 3 downto 0) ; 
		read_add2 : in std_logic_vector( 3 downto 0 ); 
		write_add : in std_logic_vector( 3 downto 0 ) ;
		data_in : in std_logic_vector( 31 downto 0 ) ; 
		clk:  in std_logic ; 
		WE : in std_logic ; 
		output_1 : out std_logic_vector(31 downto 0) ; 
		output_2 : out std_logic_vector( 31 downto 0 )   
);
end component ; 

component Flag is
port(
	S , Fset : in std_logic ; 
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
end component ; 

component ConditionChecker is 
port(
	C, Z, N, V : in std_logic ;
	condition : in condtype ; 
	isTrue : out std_logic
);
end component ; 


component FSM is port(
	signal clk , predicate , reset : in std_logic ; 
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
	signal PW , IW , DW , IorD , AW , BW , RW , Rsrc1 , Rsrc2  , RsW , DT_offsetW  , shifterW ,  Asrc1  , ALU_carry_src  , Fset  , ReW: out std_logic ;
	signal Asrc2 : out std_logic_vector( 1 downto 0 ) ;
	signal MW : out std_logic_vector( 3 downto 0 ) ; 
	signal ALU_op : out optype ; 
   signal ShifterAmtSrc, shift_data_in_src: out std_logic_vector( 1 downto 0 ) ; 
   signal shiftTypesrc : out std_logic 
) ; 
end component ; 

component Shifter is
port(
		data_in : in std_logic_vector( 31 downto 0) ; 
		shiftType: in std_logic_vector( 1 downto 0 ) ;  
		shiftAmount: in std_logic_vector( 4 downto 0 ) ;
		data_out: out std_logic_vector( 31 downto 0 ) ; 
		carry : out std_logic 
);

end component ;

component PMconnect is
port(
Rout, Mout: in std_logic_vector( 31 downto 0 ) ; 
AD : in std_logic_vector( 1 downto 0 ) ; 
DT_instruction : in DT_instr_type ; 
Rin, Min : out std_logic_vector( 31 downto 0 ) ; 
MW : out std_logic_vector( 3 downto 0 )   
);
end component ; 

component Multiplier is
port(
 mul_instr : in mul_instr_type ;
 op1 , op2 : in std_logic_vector( 31 downto 0 ) ;
 op3 : in std_logic_vector( 63 downto 0 ) ; --  add operand , least significant 32 bits are important for mla and actual operand needs to be zero extended to 64 bits 
 res : out std_logic_vector( 63 downto 0 ) -- in case of mul or mla least significant 32 bits need to be extracted out in glue logic 
);
end component ;

signal ProgCounter : word := x"00000000"; 
signal M2R : std_logic_vector( 1 downto 0 ) ;  
signal PW , IW , DW , IorD , AW , BW , RW  , Rsrc  , Asrc1  , ALU_carry_src  , Fset  , ReW: std_logic ; -- control signals 
signal Asrc2 : std_logic_vector( 1 downto 0 ) ; 

signal MW : std_logic_vector( 3 downto 0 ) ; 

signal ALU_a , ALU_b  ,  ALU_output , mem_data_in , mem_data_out : std_logic_vector( 31 downto 0 ) ; 
signal mem_read_add , mem_write_add : std_logic_vector( 6 downto 0 ) ; 


signal instr_class : instr_class_type ; 
signal operation , ALU_op : optype ; 
signal cond : condtype ; 
signal DP_subclass : DP_subclass_type ; 
signal DP_operand_src : DP_operand_src_type ;  
signal load_store : load_store_type ; 
signal branchOffset : std_logic_vector( 23 downto 0 );
signal DT_offset_sign : DT_offset_sign_type ; 


signal IR , DR  , RES , A , B   : std_logic_vector( 31 downto 0 ) ; 

signal predicate : std_logic ; 
signal C,Z,N,V , S , ALU_carry_in , ALU_carry_out , Shift_carry : std_logic ; 
signal isShift : std_logic := '0' ; 
signal reg_read_add_1 , reg_read_add_2 , reg_write_add : std_logic_vector( 3 downto 0 ) ;  
signal reg_write_data , reg_out_data_1 , reg_out_data_2 : std_logic_vector( 31 downto 0 ) ;


signal DP_shift_src : DP_shift_src_type ; 
signal DT_operand_src : DT_operand_src_type ;
signal shift_data_in :  std_logic_vector( 31 downto 0) ; 
signal shiftType:  std_logic_vector( 1 downto 0 ) ; 
signal shiftAmount:  std_logic_vector( 4 downto 0 ) ;
signal shift_data_out:  std_logic_vector( 31 downto 0 ) ; 
signal shifterOutputRegister : std_logic_vector( 31 downto 0 ) ; 
signal shifterW, RsW , DT_offsetW : std_logic ;
signal Rs, DT_offsetReg : std_logic_vector( 31 downto 0 ) ; -- stores the shift amount specified by registers for DP instructions 
signal Rsrc1 , Rsrc2 : std_logic ; 
signal ShifterAmtSrc, shift_data_in_src: std_logic_vector( 1 downto 0 ) ; 
signal shiftTypesrc : std_logic ; 

signal DT_instr :  DT_instr_type ; 
signal WriteBack, PreIndexing : std_logic ; 
signal AddressForDT : std_logic_vector( 31 downto 0 ) ; 
signal RegisterWriteSrc : std_logic := '0' ; 
signal Min , Rin : std_logic_vector( 31 downto 0 ) ; 
signal PmconnectMW : std_logic_vector( 3 downto 0 ) ;
signal HalfWordOrSignedTransfer : std_logic ;  
signal HlfWdOrSgnedTrnsferSrc : std_logic ; -- 0 for register 1 for offset 


-- new additions 
signal mul_instr :  mul_instr_type ; 
signal isMultiplication : std_logic ; 
signal RdLo : std_logic_vector( 31 downto 0 ) ; -- additional register which stores the value read from register specified by instruction ( 15 to 12 ) for multiply instructions 
signal RdLoW : std_logic ; -- write signal for RdLo
signal mul_res  : std_logic_vector( 63 downto 0 ) ; 
signal op3mulhigh : std_logic_vector( 31 downto 0 ) ; 

begin

PC_module: PC port map( clk => clk , 
					  PW => PW , 
					  reset => reset , 
					  pc_in => (  ALU_output(29 downto 0 ) & "00" )  ,  -- produces the word address of PC needs to be converted to byte address
					  pc_out => ProgCounter) ; 

--	AddressForDT either stores only base or base + offset in case of post / pre indexing respectively 				  
mem_read_add <= AddressForDT(  8 downto 2) when IorD = '1' else ProgCounter( 8 downto 2)  ; -- changed to accomodate pre/post indexing 
mem_data_in <=  Min ; -- from Pmconnect   
mem_write_add <= AddressForDT(  8 downto 2) when IorD = '1' else ProgCounter( 8 downto 2)  ; -- changed to accomodate pre/post indexing 
Memory_module: Memory port map( clk => clk , 
										  WE => MW and PmconnectMW, -- memory write is affected both by FSM signal and Pmconnect output 
										  data_in => mem_data_in , 
										  data_out => mem_data_out , 
										  read_add => mem_read_add , 
										  write_add => mem_write_add);
										  
										  
Decoder_module : Decoder port map( instruction => IR , 
								instr_class => instr_class ,
								operation => operation , 
								condition => cond ,  
								DP_subclass => DP_subclass , 
								DP_operand_src => DP_operand_src ,
								DT_operand_src => DT_operand_src ,
								DP_shift_src => DP_shift_src , 
								mul_instr => mul_instr , 
								load_store  => load_store ,
								branchOffset => branchOffset ,
								DT_offset_sign => DT_offset_sign , 
								DT_instr => DT_instr , 
								S => S ) ; 

-- additional logic added to write output of multiplier to registers 
reg_write_data <= Rin when M2R = "01" else -- Rin comes from Pmconnect  
						RES when M2R = "00" else 
						mul_res( 31 downto 0 ) when M2R = "10" else
						mul_res( 63 downto 32 ) when M2R = "11"  else 
						x"00000000" ; 
						
reg_read_add_1 <= IR( 19 downto 16 ) when Rsrc1 = '1' else IR( 11 downto 8 ) ; -- more multiplexing added 
reg_read_add_2 <= IR( 15 downto 12 ) when Rsrc2 = '1' else IR( 3 downto 0 ) ; 
reg_write_add <= IR( 15 downto 12 ) when RegisterWriteSrc = '0' else IR( 19 downto 16 ) ;  								
Reg : RegisterFile port map( read_add1 => reg_read_add_1 , read_add2 => reg_read_add_2 , 
									  write_add => reg_write_add , 
									  data_in => reg_write_data , 
									  clk => clk , 
									  WE => RW , 
									  output_1 => reg_out_data_1 , 
									  output_2 => reg_out_data_2 ) ; 
		
		
ALU_a <= A when Asrc1 = '1' else  ( "00" &  ProgCounter( 31 downto 2 ) )  ; -- convert ProgCounter to word address  	
ALU_b <= shifterOutputRegister when ( Asrc2 = "00" ) else
			x"00000001" when (Asrc2 = "01") else -- word address computation 
			std_logic_vector(to_signed( (to_integer(signed(branchOffset)) )  , 32  ) );  -- signed extension of branchOffset for load/store
-- offset for DT will now be present in shifterOutputRegister 

			
ALU_carry_in <= C when ALU_carry_src = '1' else '1' ;-- useful for next address computation 

ALU_unit : ALU port map ( a => ALU_a , 
								  b => ALU_b , 
								  cin => ALU_carry_in , cout => ALU_carry_out , 
								  result => ALU_output ,
								  opcode => ALU_op ) ; 		
isShift <= '0' when shiftAmount = "00000" else '1' ; 							  
Flag_unit : Flag port map ( S => S , Fset => Fset , 
					  ALU_result => ALU_output , 
					  ALU_carry => ALU_carry_out , 
					  Shift_carry => Shift_carry , 
					  MSB_a => ALU_a(31) , MSB_b => ALU_b(31) , 
					  isShift => isShift , 
					  instr_class => instr_class , 
					  DP_subclass => DP_subclass , 
					  operation => operation , 
					  Z => Z , C => C , N =>N , V => V , 
					  clk => clk) ;  
					  
CondCheck : ConditionChecker port map( C => C , Z => Z , N => N , V => V ,
													condition => cond ,
													isTrue => predicate) ;

FSM_module: FSM port map(
	 clk => clk , predicate => predicate , reset => reset , 
	 instr_class => instr_class , 
	 load_store =>  load_store ,   
	 DT_offset_sign =>  DT_offset_sign , 
	 DP_operand_src =>  DP_operand_src , -- new 
	 DP_subclass => DP_subclass , 
	 operation =>  operation  , 
	 DT_operand_src => DT_operand_src , 
	 DP_shift_src => DP_shift_src , 
	 DT_instr => DT_instr , 
	 WriteBack => WriteBack , PreIndexing => PreIndexing ,
	 isMultiplication => isMultiplication , 
	 mul_instr => mul_instr , 
	 RegisterWriteSrc => RegisterWriteSrc , 
	 RdLoW => RdLoW , 
	 M2R => M2R , 
	 PW => PW, IW => IW , DW => DW , IorD => IorD, AW => AW , BW => BW , 
	 RW => RW  ,  Rsrc1 => Rsrc1 , Rsrc2 => Rsrc2,  RsW => RsW ,  DT_offsetW  =>  DT_offsetW , shifterW => shifterW ,  
	 Asrc1 => Asrc1 , ALU_carry_src => ALU_carry_src ,
	 Fset => Fset  , ReW => ReW , 
	 Asrc2 => Asrc2 , 
	 MW => MW ,  
	 ALU_op => ALU_op , 
	 ShifterAmtSrc => ShifterAmtSrc , 
	 shift_data_in_src => shift_data_in_src , 
	 shiftTypesrc => shiftTypesrc
 
) ; 

shiftAmount <= IR( 11 downto 8 ) & "0" when ShifterAmtSrc = "00" else -- DP immediate 
					"00000" when  ( ShifterAmtSrc = "01" and HalfWordOrSignedTransfer = '0')  else -- DT ( ldr or str or ldrb or strb ) immediate 
					IR( 11 downto 7 ) when (ShifterAmtSrc = "10" and HalfWordOrSignedTransfer = '0') else -- DT ( ldr or str or ldrb or strb ) register specifies shift 
					Rs( 4 downto 0 ) when ( ShifterAmtSrc = "11" and ( IR(4) = '1')  ) else -- DP register specifies shift 
					IR( 11 downto 7 ) when ( ShifterAmtSrc = "11" and ( IR(4) = '0')  ) else -- DP immediate specifies shift 
					"00000" ; -- no shift for HalfWordOrSignedTransfer
					
shiftType <=  "11" when shiftTypesrc = '0' else -- ROR for immediate DP operand 
					IR( 6 downto 5 ) ; -- DP shift or DT shift 
					
shift_data_in <= 	 (  x"00000" & IR( 11 downto 0 ))  when shift_data_in_src = "00" and HalfWordOrSignedTransfer = '0' else  -- DT offset immediate 
						 B when shift_data_in_src = "01" else -- DP second register 
						 ( x"000000" & IR(7 downto 0 )) when  shift_data_in_src = "10" else -- DP immediate operand 
						 DT_offsetReg when shift_data_in_src = "11" and HalfWordOrSignedTransfer = '0' else -- DT offset as a register 
						 B when (HalfWordOrSignedTransfer = '1' and HlfWdOrSgnedTrnsferSrc = '0' ) else -- Signed or Half word transfer with offset from register  
						  x"000000" & IR( 11 downto 8) & IR( 3 downto 0 ) ; -- signed or half word DT with offset as immediate constant 
						 
Shifter_module : Shifter port map (
		data_in => shift_data_in , 
		shiftType => shiftType , 
		shiftAmount => shiftAmount , 
		data_out => shift_data_out , 
		carry => Shift_carry 
) ;

-- new component 
-- WriteBack is always true when postindexing 
WriteBack <= '1' when ( IR(21) = '1' or (PreIndexing = '0' ) ) else '0' ; -- 1 implies write back , 0 implies no write back 
PreIndexing <= IR(24) ; -- 1 implies pre-indexing , 0 implies post indexing  
HalfWordOrSignedTransfer <= '0' when ( DT_instr = ldr or DT_instr = str or DT_instr = ldrb or DT_instr = strb ) else '1' ;  
HlfWdOrSgnedTrnsferSrc <= IR(22) ; -- 1 when offset is immediate else 0 when offset is specified by register 


PMconnectModule : PMconnect port map (
Rout => B , -- B stores the data read from register file  
Mout => DR , -- DR stores the data read from memory  
AD =>  AddressForDT( 1 downto 0 ), 
DT_instruction => DT_instr , 
Rin => Rin , 
Min => Min , 
MW => PmconnectMW 
); 
 
-- Multiplier and related glue logic 
isMultiplication <= '0' when mul_instr = nomul else '1' ; 
op3mulhigh <= x"00000000" when ( mul_instr = mla or mul_instr = mul or mul_instr = umull or mul_instr = smull ) else A ; 
Muliplier_module : Multiplier port map ( 
	mul_instr => mul_instr , 
	op1 => B , -- register specified by IR( 3 to 0 )
	op2 => Rs , -- register specified by IR( 11 to 8 )
	op3 => op3mulhigh & RdLo ,  -- add operand only least significant 32 bits are important for mla 
	res => mul_res
) ; 

-- registers to store the results to implement multicycle design 
											
process(clk)
begin
if(rising_edge(clk) and (IW = '1'))  then
IR <= mem_data_out ; 
end if ; 
end process ; 

process(clk)
begin
if(rising_edge(clk) and (DW = '1'))  then
DR <= mem_data_out ; 
end if ; 
end process ; 

process(clk)
begin
if(rising_edge(clk) and (AW = '1')) then 
A <= reg_out_data_1 ; 
end if ; 
end process ; 

process(clk)
begin 
if( rising_edge(clk) and BW = '1') then 
B <= reg_out_data_2 ; 
end if ; 
end process ; 

process(clk)
begin 
if( rising_edge(clk) and ReW = '1') then 
RES <= ALU_output ;
   -- to accomodate pre/post indexing 
	if(PreIndexing = '1') then 
	AddressForDT <= ALU_output ; -- base + offset 
	else 
	AddressForDT <= A ; -- base  
	end if ;  
end if ; 

end process ;

process(clk)
begin
if(rising_edge(clk) and (shifterW = '1'))  then
shifterOutputRegister  <= shift_data_out ; 
end if ; 
end process ;

process(clk)
begin
if(rising_edge(clk) and ( RsW = '1'))  then
Rs  <= reg_out_data_1  ; -- reads the register stroing shift amount ( 11 downto 8) 
end if ; 
end process ;

process(clk)
begin
if(rising_edge(clk) and ( DT_offsetW = '1'))  then
DT_offsetReg   <=  reg_out_data_2  ; -- reads the the register storing the DT offset ( 3 to  0 )
end if ;  
end process ;

process(clk)
begin 
if( rising_edge(clk) and ( RdLoW = '1' ) ) then 
RdLo <= reg_out_data_2 ; -- second port gives register specified by IR( 15 downto 12 )
end if ;
end process ; 


end arch ; 
