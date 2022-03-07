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
	load_store : out load_store_type;
	branchOffset : out std_logic_vector( 23 downto 0 ) ; 
	DT_offset_sign : out DT_offset_sign_type ; 
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
	signal PW , IW , DW , IorD , AW , BW , RW , M2R  , Rsrc  , Asrc1  , ALU_carry_src  , Fset  , ReW: out std_logic ;
	signal Asrc2 : out std_logic_vector( 1 downto 0 ) ;
	signal MW : out std_logic_vector( 3 downto 0 ) ; 
	signal ALU_op : out optype 
 
) ; 
end component ; 

signal ProgCounter : word := x"00000000"; 
signal PW , IW , DW , IorD , AW , BW , RW , M2R  , Rsrc  , Asrc1  , ALU_carry_src  , Fset  , ReW: std_logic ; -- control signals 
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

begin

PC_module: PC port map( clk => clk , 
					  PW => PW , 
					  reset => reset , 
					  pc_in => (  ALU_output(29 downto 0 ) & "00" )  ,  -- produces the word address of PC needs to be converted to byte address
					  pc_out => ProgCounter) ; 
					  
mem_read_add <= RES(  8 downto 2) when IorD = '1' else ProgCounter( 8 downto 2)  ; 
mem_data_in <= B ; 
mem_write_add <= RES(  8 downto 2) when IorD = '1' else ProgCounter( 8 downto 2)  ; 
Memory_module: Memory port map( clk => clk , 
										  WE => MW , 
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
								load_store  => load_store ,
								branchOffset => branchOffset ,
								DT_offset_sign => DT_offset_sign , 
								S => S ) ; 

reg_write_data <= DR when M2R = '1' else RES  ; 
reg_read_add_1 <= IR( 19 downto 16 ) ;
reg_read_add_2 <= IR( 15 downto 12 ) when Rsrc = '1' else IR( 3 downto 0 ) ; 
reg_write_add <= IR( 15 downto 12 ) ;  								
Reg : RegisterFile port map( read_add1 => reg_read_add_1 , read_add2 => reg_read_add_2 , 
									  write_add => reg_write_add , 
									  data_in => reg_write_data , 
									  clk => clk , 
									  WE => RW , 
									  output_1 => reg_out_data_1 , 
									  output_2 => reg_out_data_2 ) ; 
		
		
ALU_a <= A when Asrc1 = '1' else  ( "00" &  ProgCounter( 31 downto 2 ) )  ; -- convert ProgCounter to word address  	
ALU_b <= B when ( Asrc2 = "00" ) else
			x"00000001" when (Asrc2 = "01") else -- word address computation 
			(  x"00000" & IR( 11 downto 0 )) when( Asrc2 = "10") else 
			  std_logic_vector(to_signed( (to_integer(signed(branchOffset)) )  , 32  ) );  -- signed extension of branchOffset for load/store
ALU_carry_in <= C when ALU_carry_src = '1' else '1' ;-- useful for next address computation 

ALU_unit : ALU port map ( a => ALU_a , 
								  b => ALU_b , 
								  cin => ALU_carry_in , cout => ALU_carry_out , 
								  result => ALU_output ,
								  opcode => ALU_op ) ; 		
								  
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
	 DP_operand_src =>  DP_operand_src , 
	 DP_subclass => DP_subclass , 
	 operation =>  operation  , 
	 PW => PW, IW => IW , DW => DW , IorD => IorD, AW => AW , BW => BW , 
	 RW => RW , M2R => M2R  , Rsrc => Rsrc  , Asrc1 => Asrc1 , ALU_carry_src => ALU_carry_src ,
	 Fset => Fset  , ReW => ReW , 
	 Asrc2 => Asrc2 , 
	 MW => MW ,  
	 ALU_op => ALU_op
 
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
end if ; 
end process ;

end arch ; 
