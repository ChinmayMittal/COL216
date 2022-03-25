library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.MyTypes.all;
use IEEE.NUMERIC_STD.ALL;


entity Decoder is
 Port (
	instruction : in word;
	instr_class : out instr_class_type;
	operation : out optype;
	condition : out condtype ; 
	DP_subclass : out DP_subclass_type;
	DP_operand_src : out DP_operand_src_type;
	DT_operand_src : out DT_operand_src_type ; -- new 
	DP_shift_src : out DP_shift_src_type ; 
	load_store : out load_store_type;
	branchOffset : out std_logic_vector( 23 downto 0 ) ; 
	DT_offset_sign : out DT_offset_sign_type ; 
	DT_instr : out DT_instr_type ; 
	S : out std_logic 
);
end Decoder;

architecture Behavioral of Decoder is

type oparraytype is array (0 to 15) of optype;
constant oparray : oparraytype :=
	(andop, eor, sub, rsb, add, adc, sbc, rsc,
	tst, teq, cmp, cmn, orr, mov, bic, mvn);
type condarraytype is array ( 0 to 15 ) of  condtype ; 
constant condarray : condarraytype := (EQ , NE , CS , CC , MI , PL , VS , VC , HI , LS , GE , LT , GT , LE , AL , NA) ; 

begin
-- additional logic added for instr_class being DP 
instr_class <= BRN when ( instruction( 27 downto 26 ) = "10") else 
					DT when ( (instruction( 27 downto 26) = "01" ) or ( (instruction( 27 downto 25) = "000" ) and ( instruction(4) = '1') and ( instruction(7) = '1' ) ) )  else
					DP when ( instruction( 27 downto 26) = "00" ) else 
					none ; 
operation <= oparray (to_integer(unsigned (instruction (24 downto 21))));
condition <= condarray( to_integer( unsigned(instruction(31 downto 28)))) ; 
branchOffset <= instruction( 23 downto 0 ) ; 

with instruction (24 downto 22) select
	DP_subclass <= arith when "001" | "010" | "011",
	logic when "000" | "110" | "111",
	comp when "101",
test when others;
DP_operand_src <= reg when instruction (25) = '0' else imm;
DT_operand_src <= imm when instruction(25) = '0' else reg ; -- opposite for DP 
DP_shift_src <= reg when instruction(4) = '1' else imm ; 
load_store <= load when instruction (20) = '1' else store;
DT_offset_sign <= plus when instruction (23) = '1' else
minus;
S <= instruction(20) ; 

DT_instr <= ldr when ( instruction( 27 downto 26) = "01" and instruction(20) = '1' and instruction(22) = '0' ) else
				str when ( instruction( 27 downto 26) = "01" and instruction(20) = '0' and instruction(22) = '0') else 
				ldrb when ( instruction( 27 downto 26) = "01" and instruction(20) = '1' and instruction(22) = '1' ) else
				strb when ( instruction( 27 downto 26) = "01" and instruction(20) = '0' and instruction(22) = '1' ) else 
			   ldrh when ( instruction( 27 downto 25 ) = "000" and instruction(20) = '1' and instruction( 7 downto 4 ) = "1011" ) else
			   strh when ( instruction( 27 downto 25 ) = "000" and instruction(20) = '0' and instruction( 7 downto 4 ) = "1011") else 
				ldrsh when ( instruction( 27 downto 25 ) = "000" and instruction(20) = '1' and instruction( 7 downto 4 ) = "1111") else 
				ldrsb ; 
end Behavioral;