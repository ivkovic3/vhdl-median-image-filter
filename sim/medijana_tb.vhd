library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_medijana is

end entity;

architecture sim of tb_medijana is
    component medijana is
        Port (
            clk: in std_logic;
            reset: in std_logic;
            a0: in std_logic_vector(7 downto 0);
            a1: in std_logic_vector(7 downto 0);
            a2: in std_logic_vector(7 downto 0);
            a3: in std_logic_vector(7 downto 0);
            a4: in std_logic_vector(7 downto 0);
            a5: in std_logic_vector(7 downto 0);
            a6: in std_logic_vector(7 downto 0);
            a7: in std_logic_vector(7 downto 0);
            a8: in std_logic_vector(7 downto 0);
            medijan: out std_logic_vector(7 downto 0)
        );
    end component;

    signal clk: std_logic := '0';
    signal reset: std_logic := '0';
    signal a0, a1, a2, a3, a4, a5, a6, a7, a8: std_logic_vector(7 downto 0);
    signal medijan: std_logic_vector(7 downto 0);

    constant clk_period: time := 10 ns;

begin

    uut: medijana
        port map (
            clk => clk,
            reset => reset,
            a0 => a0,
            a1 => a1,
            a2 => a2,
            a3 => a3,
            a4 => a4,
            a5 => a5,
            a6 => a6,
            a7 => a7,
            a8 => a8,
            medijan => medijan
        );

    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    stim_proc: process
    begin
        reset <= '1';
        wait for clk_period;
        reset <= '0';

        a0 <= "00000001"; -- 1
        a1 <= "00000010"; -- 2
        a2 <= "00000100"; -- 4
        a3 <= "00000011"; -- 3
        a4 <= "00001000"; -- 8
        a5 <= "00000111"; -- 7
        a6 <= "00000101"; -- 5
        a7 <= "00000000"; -- 0
        a8 <= "00000110"; -- 6
        wait for 20 * clk_period;

        a0 <= "00001111"; -- 15
        a1 <= "00010000"; -- 16
        a2 <= "00010001"; -- 17
        a3 <= "00001010"; -- 10
        a4 <= "00001011"; -- 11
        a5 <= "00000001"; -- 1
        a6 <= "00000010"; -- 2
        a7 <= "00000011"; -- 3
        a8 <= "00000100"; -- 4
        wait for 20 * clk_period;
        
        a8 <= "00000001"; -- 1
        a7 <= "00000010"; -- 2
        a6 <= "00000100"; -- 4
        a5 <= "00000011"; -- 3
        a2 <= "00001000"; -- 8
        a4 <= "00000111"; -- 7
        a3 <= "00000101"; -- 5
        a1 <= "00000000"; -- 0
        a0 <= "00000110"; -- 6
        wait for 20 * clk_period;

        wait;
    end process;

end architecture;
