-- Progetto di Reti Logiche
-- Sviluppato da Riccardo Pomarico

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 
use ieee.numeric_std.all; 

entity project_reti_logiche is 
    port (
         i_clk 	    : in std_logic; 
         i_rst 	    : in std_logic; 
         i_start 	: in std_logic; 
         i_data 	: in std_logic_vector(7 downto 0);
         o_address	: out std_logic_vector(15 downto 0);
         o_done 	: out std_logic; 
         o_en 		: out std_logic; 
         o_we 		: out std_logic; 
         o_data 	: out std_logic_vector(7 downto 0) 
    ); 
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is 

type state_type is (IDLE, RST, S0, S1, S2, S3, S4, S5, S6, S7);

signal current_state 	: state_type := IDLE; 
signal next_state 	    : state_type := IDLE;
signal check            : std_logic := '0'; 
signal shift_level 	    : integer range 0 to 8;
signal n_col 		    : std_logic_vector(7 downto 0) := (others => '0'); 
signal n_rig 		    : std_logic_vector(7 downto 0) := (others => '0'); 
signal delta_value 	    : std_logic_vector(7 downto 0) := (others => '0'); 
signal max_pixel_value 	: std_logic_vector(7 downto 0) := (others => '0'); 
signal min_pixel_value 	: std_logic_vector(7 downto 0) := (others => '0'); 

begin
    state_reg: process(i_clk, i_rst) 
    begin 
        if i_rst = '1' then 
            current_state <= RST; 
        elsif falling_edge(i_clk) then 
            current_state <= next_state; 
        end if; 
    end process state_reg; 
    
    lambda: process(current_state, i_rst, i_start, i_clk, check)
    begin 
        if i_rst = '1' then 
            next_state <= RST; 
        elsif falling_edge(i_clk) then 
            case current_state is 
                when IDLE => 
                
                when RST =>
                    if i_start = '1' then 
                        next_state <= S0; 
                    end if; 
                
                when S0 =>
                    next_state <= S1; 
                
                when S1 => 
                    next_state <= S2; 
                    
                when S2 =>
                    next_state <= S3;
                
                when S3 => 
                    if check = '1' then 
                        next_state <= S4; 
                    else
                        next_state <= S3; 
                    end if; 
                    
                when S4 => 
                    next_state <= S5; 
                    
                when S5 =>
                    if check = '0' then 
                        next_state <= S6; 
                    else 
                        next_state <= S5; 
                    end if; 
                    
                when S6 => 
                    next_state <= S7; 
                
                when S7 => 
                    if i_start = '0' then
                        next_state <= RST; 
                    else 
                        next_state <= S7;
                    end if;
            end case; 
        end if;
    end process lambda;

    delta: process(current_state, i_clk, i_start, i_data, check, shift_level, n_col, n_rig, delta_value, max_pixel_value, min_pixel_value) 

    variable controllo 		       : std_logic_vector(15 downto 0) := (others => '0');
    variable temp_new              : std_logic_vector(15 downto 0) := (others => '0');
    variable current_pixel_value   : std_logic_vector(7 downto 0) := (others => '0');
    variable new_pixel 	           : std_logic_vector(7 downto 0) := (others => '0'); 
    variable temp_pixel 	       : std_logic_vector(7 downto 0) := (others => '0'); 
    variable i                     : integer range 0 to 16384;
    variable totalcount            : integer;
    TYPE array1 is ARRAY (0 to 16384) of std_logic_vector(7 downto 0);
    variable v: array1;
    
    begin 
        if falling_edge(i_clk) then 
            case current_state is 
                when IDLE => 
                
                when RST => 
                    o_done <= '0';
                    o_we <= '0'; 
                    o_data <= (others => '0'); 
                    check <= '0'; 
                    max_pixel_value <= (others => '0'); 
                    min_pixel_value <= (others => '0'); 
                    delta_value <= (others => '0'); 
                    shift_level <= 0; 
                    current_pixel_value := (others => '0');
                    i := 1;
                    controllo := (others => '0');
                    temp_new := (others => '0');
                    temp_pixel := (others => '0'); 
                    new_pixel := (others => '0'); 
                    totalcount := 1;                    
                    
                    if i_start = '1' then 
                        o_address <= (others => '0'); 
                        o_en <= '1'; 
                    end if; 
                    
                when S0 => 
                    n_col <= i_data; 
                    
                when S1 =>    
                    o_address <= std_logic_vector(to_unsigned(1, 16));               
                    n_rig <= i_data; 
                    
                when S2 =>
                    if n_col /= "00000000" or n_rig /= "00000000" then
                    
                        i := i + 1;
                        totalcount := totalcount + 1;
                        controllo := controllo + "0000000000000001";
                        
                        o_address <= std_logic_vector(to_unsigned(totalcount, 16));        
                        current_pixel_value := i_data; 
                        v(i) := std_logic_vector(current_pixel_value);
                        
                        max_pixel_value <= std_logic_vector(current_pixel_value); 
                        min_pixel_value <= std_logic_vector(current_pixel_value);
                        
                    end if;
                    
                when S3 =>   
                    if n_col > "00000001" and n_rig > "00000001" then
                    
                        i := i + 1;
                        totalcount := totalcount + 1;
                        controllo := controllo + "0000000000000001";
                        
                        o_address <= std_logic_vector(to_unsigned(totalcount, 16));        
                        current_pixel_value := i_data; 
                        v(i) := std_logic_vector(current_pixel_value);
                        
                        if max_pixel_value < std_logic_vector(current_pixel_value) then 
                            max_pixel_value <= std_logic_vector(current_pixel_value); 
                        elsif min_pixel_value > std_logic_vector(current_pixel_value) then 
                            min_pixel_value <= std_logic_vector(current_pixel_value); 
                        end if; 
                        
                        if controllo = (std_logic_vector(n_rig * n_col) - "0000000000000001") then 
                            check <= '1';
                            controllo := (others => '0'); 
                            i := 0;
                        end if; 
                        
                    else 
                    
                        check <= '1';
                        controllo := (others => '0');
                        i := 0;
                        
                    end if;

                when S4 => 
                    delta_value <= std_logic_vector(max_pixel_value - min_pixel_value);
                    
                    if delta_value = "00000000" then 
                        shift_level <= 8; 
                    elsif delta_value > "00000000" and delta_value < "00000011" then 
                        shift_level <= 7;
                    elsif delta_value > "00000010" and delta_value < "00000111" then 
                        shift_level <= 6;
                    elsif delta_value > "00000110" and delta_value < "00001111" then 
                        shift_level <= 5; 
                    elsif delta_value > "00001110" and delta_value < "00011111" then 
                        shift_level <= 4; 
                    elsif delta_value > "00011110" and delta_value < "00111111" then 
                        shift_level <= 3; 
                    elsif delta_value > "00111110" and delta_value < "01111111" then 
                        shift_level <= 2; 
                    elsif delta_value > "01111110" and delta_value < "11111111" then 
                        shift_level <= 1;
                    elsif delta_value = "11111111" then 
                        shift_level <= 0; 
                    end if; 
                    
                    o_we <= '1';

                when S5 => 
                    if n_col = "00000000" or n_rig = "00000000" then
                    
                        new_pixel := (others => '0');
                        o_address <= std_logic_vector(to_unsigned(3, 16));
                        o_data <= std_logic_vector(new_pixel);
                        
                        check <= '0';
                        controllo := (others => '0');
                        i := 0; 
                        
                    else
                    
                        i := i + 1;
                        totalcount := totalcount + 1;
                        controllo := controllo + "0000000000000001";
                        
                        current_pixel_value := std_logic_vector(v(i));                  
                        temp_pixel := std_logic_vector(current_pixel_value - min_pixel_value);
                            
                        temp_new := std_logic_vector(temp_pixel*"00000001");
                        temp_new := std_logic_vector(unsigned(temp_new) sll shift_level);
                                
                        if temp_new > "0000000011111111" then 
                                
                            new_pixel := (others => '1');
                                    
                        else                        
                                        
                            new_pixel := std_logic_vector(unsigned(temp_pixel) sll shift_level);
                                        
                        end if;
                       
                        o_address <= std_logic_vector(to_unsigned(totalcount - 1, 16));
                        o_data <= std_logic_vector(new_pixel);
                        
                        if controllo = std_logic_vector(n_rig * n_col) then 
                            check <= '0';
                            controllo := (others => '0');
                            i := 0; 
                        end if;
                        
                    end if;
                    
                when S6 => 
                    o_done <= '1';
                
                when S7 => 
                    o_done <= '0'; 
                    
            end case;
        end if;
    end process delta;
end Behavioral;