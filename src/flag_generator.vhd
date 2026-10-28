library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity flag_generator is
  port (
        input: in std_logic;
        reset: in std_logic;
        output: out std_logic;
        clk: in std_logic
 
 
  );
end flag_generator;

architecture Behavioral of flag_generator is

type state is (idle, generateFlag);
signal fsm_state, fsm_next_state: state;

begin
    process(clk) is
    begin
        if (rising_edge(clk)) then
            if (reset='1') then
                fsm_state <= idle;
            else
                fsm_state <= fsm_next_state;    
               
            end if;
        end if;
    end process;
   
   
    process(fsm_state, input) is
    begin
        case (fsm_state) is
            when idle =>
                if (input = '1') then
                    fsm_next_state <= generateFlag;
                else
                    fsm_next_state <= idle;
                end if;
            when generateFlag =>
                    fsm_next_state <= generateFlag;
        end case;
    end process;
   
    output <= '1' when fsm_state= generateFlag else '0';


end Behavioral;