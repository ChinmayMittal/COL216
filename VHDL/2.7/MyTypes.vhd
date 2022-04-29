library IEEE;
use IEEE.STD_LOGIC_1164.all;
package MyTypes is
	subtype word is std_logic_vector (31 downto 0);
	subtype hword is std_logic_vector (15 downto 0);
	subtype byte is std_logic_vector (7 downto 0);
	subtype nibble is std_logic_vector (3 downto 0);
	subtype bit_pair is std_logic_vector (1 downto 0);
	type optype is (andop, eor, sub, rsb, add, adc, sbc, rsc,
	tst, teq, cmp, cmn, orr, mov, bic, mvn);
	type condtype is ( EQ , NE , CS , CC , MI , PL , VS , VC , HI , LS , GE , LT , GT , LE , AL , NA );
	type instr_class_type is (DP, DT, MUL, BRN, none);
	type DP_subclass_type is (arith, logic, comp, test, none);
	type DP_operand_src_type is (reg, imm);
	type DT_operand_src_type is (reg, imm); -- two type of operands for Data Transfer instructions 
	type DP_shift_src_type is (reg, imm);
	type load_store_type is (load, store);
	type DT_offset_sign_type is (plus, minus);
	type state_type is ( s0 , s1 , s2 , s3 , s4 , s5 , s6 , s7, s8 , A , B , C , D ) ; 
	type DT_instr_type is ( ldr , str , ldrh , strh , ldrsh , ldrb , ldrsb , strb ) ; 
	type mul_instr_type is ( mul, mla, umull, umlal, smull, smlal , nomul ) ; 
	end MyTypes;

package body MyTypes is
end MyTypes;