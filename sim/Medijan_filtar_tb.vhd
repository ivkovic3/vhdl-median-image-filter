library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.all;

entity tb_Medijan_filtar is
end tb_Medijan_filtar;

architecture behavior of tb_Medijan_filtar is

component Medijan_filtar
 port (
    start_process : in std_logic;
    reset : in std_logic;
    clk : in std_logic;
    output : out std_logic_vector(7 downto 0);
    write_enable : out std_logic
 );
end component;

signal start_process : std_logic := '0';
signal reset : std_logic := '0';
signal clk : std_logic := '0';
signal output : std_logic_vector(7 downto 0) := (others=>'0');
signal write_enable : std_logic;

constant clk_period : time := 10 ns;

begin
uut: Medijan_filtar
 port map (
    start_process => start_process,
    reset => reset,
    clk => clk,
    output => output,
    write_enable => write_enable
 );

clk_process : process
begin
    while true loop
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end loop;
end process;

stim_proc: process
begin
    reset <= '1';
    wait for 20 ns;
    reset <= '0';
    
    wait for 30 ns;
    start_process <= '1';
    wait for 10 ns;
    start_process <= '0';
 
    wait for 5 ms;
    wait;
end process;

file_write_proc: process(clk)
    file my_output : TEXT open WRITE_MODE is "output_signal.txt";
    variable my_output_line : LINE;
    variable pixel_value: integer;
    variable column_counter : integer := 0;
    variable row_counter : integer := 0;
begin
    if falling_edge(clk) then
        if (write_enable = '1') then
            pixel_value := to_integer(unsigned(output));


            write(my_output_line, pixel_value, right, 4);
            write(my_output_line, String'(" "));

            column_counter := column_counter + 1;

            if column_counter = 254 then
                writeline(my_output, my_output_line);
                column_counter := 0;
                row_counter := row_counter + 1;
                my_output_line := null;
            end if;

        end if;
    end if;
end process;

end behavior;