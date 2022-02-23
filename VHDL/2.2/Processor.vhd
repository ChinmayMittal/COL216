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

component ProgramMemory is 
port(
	address: in std_logic_vector( 5 downto 0 ) ; 
	data_out : out std_logic_vector( 31 downto 0 ) 
) ; 
end component ; 

component PC is
port(
	instr_class : in instr_class_type;
	condTrue : in std_logic ; 
	branchOffset : in std_logic_vector( 23 downto 0 ) ; 
	pc_in : in std_logic_vector( 31 downto 0 ) ; 
	pc_out : out std_logic_vector( 31 downto 0 )  
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

component DataMemory is 
port(
	CLK : in std_logic ;
	WE : in std_logic_vector( 3 downto 0 ) ; 
	data_in  : in std_logic_vector( 31 downto 0 ) ; 
	data_out : out std_logic_vector( 31 downto 0 ) ; 
	read_add , write_add : in std_logic_vector( 5 downto 0) 
);
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
	S : in std_logic ; 
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

signal instruction : word ; 
signal ProgCounter , pc_out : word := x"00000000"; 
signal instr_class : instr_class_type ; 
signal operation , ALU_op : optype ; 
signal cond : condtype ; 
signal DP_subclass : DP_subclass_type ; 
signal DP_operand_src : DP_operand_src_type ; 
signal load_store : load_store_type ; 
signal branchOffset : std_logic_vector( 23 downto 0 );
signal DT_offset_sign : DT_offset_sign_type ; 
signal predicate : std_logic ; 
signal C,Z,N,V , S , ALU_carry , Shift_carry : std_logic ; 
signal ALU_a , ALU_b , ALU_output : std_logic_vector( 31 downto 0 ) ; 
signal isShift : std_logic := '0' ; 
signal reg_read_add_1 , reg_read_add_2 , reg_write_add : std_logic_vector( 3 downto 0 ) ;  
signal reg_write_data , reg_out_1 , reg_out_2 , data_in , data_out : std_logic_vector( 31 downto 0 ) ;
signal reg_WE : std_logic ; 
signal data_WE : std_logic_vector( 3 downto 0 ) ; 
signal data_read_add , data_write_add : std_logic_vector( 5 downto 0 );
signal Rsrc , Asrc , M2R: std_logic ; -- control signals   

begin


process(clk,reset)
begin
if(reset = '1') then 
ProgCounter <= x"00000000" ; 
elsif(rising_edge(clk)) then 
ProgCounter <= pc_out ; 
end if ; 
end process; 

PM : ProgramMemory port map ( address => ProgCounter( 7 downto 2 ) , data_out => instruction ) ; 

PrgCnt : PC port map(instr_class => instr_class , branchOffset => branchOffset , condTrue => predicate , pc_in => ProgCounter , pc_out => pc_out ) ; 

Dcd : Decoder port map( instruction => instruction , 
								instr_class => instr_class ,
								operation => operation , 
								condition => cond ,  
								DP_subclass => DP_subclass , 
								DP_operand_src => DP_operand_src , 
								load_store  => load_store ,
								branchOffset => branchOffset ,
								DT_offset_sign => DT_offset_sign , 
								S => S ) ; 

CondCheck : ConditionChecker port map( C => C , Z => Z , N => N , V => V ,
													condition => cond ,
													isTrue => predicate) ;
													
Asrc <= '1' when ( instr_class = DT  or ( instr_class = DP and  DP_operand_src = imm )) else '0'	;												
ALU_a <= reg_out_1 ;  
ALU_b <= reg_out_2 when Asrc = '0' else (  x"00000" & instruction(11 downto 0)) ; 
ALU_op <= operation when ( instr_class = DP ) else add when ( instr_class = DT and DT_offset_sign = plus ) else sub when( instr_class = DT and DT_offset_sign = minus) else add ;  												
ALU_unit : ALU port map ( a => ALU_a , 
								  b => ALU_b , 
								  cin => C , cout => ALU_carry , 
								  result => ALU_output ,
								  opcode => ALU_op ) ; 
								  
Flag_unit : Flag port map ( S => S ,
					  ALU_result => ALU_output , 
					  ALU_carry => ALU_carry , 
					  Shift_carry => Shift_carry , 
					  MSB_a => ALU_a(31) , MSB_b => ALU_b(31) , 
					  isShift => isShift , 
					  instr_class => instr_class , 
					  DP_subclass => DP_subclass , 
					  operation => operation , 
					  Z => Z , C => C , N =>N , V => V , 
					  clk => clk) ;  

Rsrc <= '1' when ( instr_class = DT and load_store = store ) else '0' ; 					  
reg_read_add_1 <= instruction( 19 downto 16);	
reg_read_add_2 <= instruction( 3 downto 0 ) when Rsrc = '0' else instruction( 15 downto 12) ; 
reg_write_add <= instruction( 15 downto 12 ) ; 	
reg_write_data <= data_out when M2R = '1' else ALU_output ; 
reg_WE <= '1' when ( instr_class = DP or ( instr_class = DT and load_store = load )) else '0' ; 			  
Reg : RegisterFile port map( read_add1 => reg_read_add_1 , read_add2 => reg_read_add_2 , 
									  write_add => reg_write_add , 
									  data_in => reg_write_data , 
									  clk => clk , 
									  WE => reg_WE , 
									  output_1 => reg_out_1 , 
									  output_2 => reg_out_2 ) ; 
									  
data_WE <= "1111" when ( instr_class = DT and load_store = store ) else "0000" ; 
M2R <= '1' when ( instr_class = DT and load_store = load ) else '0' ; 			data_write_add <= ALU_output(  7 downto 2) ; 		-- converting byte address to word address
data_read_add <= ALU_output( 7 downto 2) ;
data_in <= reg_out_2 ;  					  
Data : DataMemory port map(   CLK => clk , 
										WE => data_WE , 
										data_in => data_in , data_out => data_out , 
										read_add => data_read_add , 
										write_add => data_write_add ); 
end arch ; 
