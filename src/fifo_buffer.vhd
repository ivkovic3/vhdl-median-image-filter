library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity fifo_buffer is
    generic(
        C_IMG_WIDTH : integer := 253
    );
    port (
        data_in  : in std_logic_vector(7 downto 0);
        data_out : out std_logic_vector(7 downto 0);
        valid    : out std_logic;
        enable   : in std_logic;
        reset    : in std_logic;
        clk      : in std_logic
    );
end fifo_buffer;

architecture Behavioral of fifo_buffer is

    type t_fifo_buffer is array (0 to C_IMG_WIDTH) of std_logic_vector(7 downto 0);
    signal s_fifo_buffer : t_fifo_buffer;

    signal wr_ptr : integer range 0 to C_IMG_WIDTH - 1 := 0; 
    signal rd_ptr : integer range 0 to C_IMG_WIDTH - 1 := 0; 

    signal fifo_full:std_logic:='0';
    signal fifo_full_flag: std_logic;
   
        component flag_generator is
  port (
        input: in std_logic;
        reset: in std_logic;
        output: out std_logic;
        clk: in std_logic 
  );
end component flag_generator;
 
begin


     MAPPING: flag_generator  port map (
        input => fifo_full,
        reset => reset,
        output => fifo_full_flag,
        clk => clk

  );
   
    POINTERS_LOGIC: process(clk) is
    begin
        if (rising_edge(clk)) then
            if (reset='1') then
                wr_ptr <=0;
                rd_ptr<=0;
            elsif (enable ='1') then
                if (fifo_full_flag='0') then
                    wr_ptr <= wr_ptr+1;
                    rd_ptr<=0;
                else
                    if (wr_ptr = C_IMG_WIDTH - 1) then
                        wr_ptr <= 0;
                    else
                        wr_ptr <= wr_ptr + 1;
                    end if;
                    if (rd_ptr = C_IMG_WIDTH - 1) then
                        rd_ptr <= 0;
                    else
                        rd_ptr <= rd_ptr + 1;
                    end if;
                   
                end if;
            end if;
        end if;
    end process POINTERS_LOGIC;
   
    SHIFT_LOGIC: process(clk) is
    begin
        if (rising_edge(clk)) then
            if (enable ='1') then
                s_fifo_buffer(wr_ptr) <= data_in;
                data_out <= s_fifo_buffer(rd_ptr);
           end if;    
        end if;
    end process SHIFT_LOGIC;
   
    VALID_LOGIC: process(clk) is
    begin
        if (rising_edge(clk)) then
            if (fifo_full_flag ='1' and enable='1') then
                valid<='1';
            else
                valid <='0';
            end if;
        end if;
    end process VALID_LOGIC;
   
   

   
    fifo_full<= '1' when (wr_ptr = C_IMG_WIDTH - 2 ) else '0';



end Behavioral;