library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.RAM_definitions_PK.all;
use IEEE.NUMERIC_STD.ALL;

entity Medijan_filtar is 
  port ( 
         start_process: in std_logic; 
         reset: in std_logic;
         clk: in std_logic;
         output: out std_logic_vector(7 downto 0);
         write_enable: out std_logic
  );
end Medijan_filtar;

architecture Behavioral of Medijan_filtar is

    type State_t is (idle,read,readwrite,write);
    signal state_reg, next_state: State_t;
    signal read_counter: integer:= 0;
    signal write_counter: integer:= 0;
    signal row: integer:= 0;
    signal col: integer:= 0;
    type matrix_3x3 is array(0 to 2, 0 to 2) of std_logic_vector(7 downto 0);
    signal reg_matrix: matrix_3x3 := (others=>(others=>(others=> '0')));
    signal pixel_out: std_logic_vector(7 downto 0):= (others=>'0');
    signal pixel_in: std_logic_vector(7 downto 0);
    signal fifo1_out: std_logic_vector(7 downto 0);
    signal fifo2_out: std_logic_vector(7 downto 0);
    signal fifo1_valid: std_logic:= '0';
    signal fifo2_valid: std_logic:= '0';
    signal fifo1_enable: std_logic:='0';
    signal fifo2_enable: std_logic:='0';
    signal write_enable_int: std_logic:= '0';
    constant G_RAM_DEPTH: integer:= 256*256;
    signal addra_converted: std_logic_vector((clogb2(G_RAM_DEPTH)-1) downto 0);
    signal addrb_converted: std_logic_vector((clogb2(G_RAM_DEPTH)-1) downto 0);
    constant C_MEDIANA_PIPELINE_DEPTH: integer:= 7;
    
    
    
    
    component medijana is
        port (
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
    end component medijana;
    
    component im_ram is
        generic (
            G_RAM_WIDTH : integer := 8;            		    -- Specify RAM data width
            G_RAM_DEPTH : integer := 256*256;		
            G_RAM_PERFORMANCE : string := "LOW_LATENCY"		        -- Specify RAM depth (number of entries)
           );
        port (
            addra : in std_logic_vector((clogb2(G_RAM_DEPTH)-1) downto 0);     -- Write address bus, width determined from RAM_DEPTH
            addrb : in std_logic_vector((clogb2(G_RAM_DEPTH)-1) downto 0);     -- Read address bus, width determined from RAM_DEPTH
            dina  : in std_logic_vector(G_RAM_WIDTH-1 downto 0);		  -- RAM input data
            clka  : in std_logic;                       			  -- Clock
            wea   : in std_logic;                       			  -- Write enable
            enb   : in std_logic;                       			  -- RAM Enable, for additional power savings, disable port when not in use
            rstb  : in std_logic;    
            regceb : in std_logic;                   			  -- Output reset (does not affect memory contents)                     			  -- Output register enable
            doutb : out std_logic_vector(G_RAM_WIDTH-1 downto 0) 		  -- RAM output data
        );
    end component im_ram;
    
    component fifo_buffer is
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
    end component fifo_buffer;
    
begin

    
    MEDIAN_FILTER_MAP: medijana port map (
        clk => clk,
        reset => reset,
        a0 => reg_matrix(0,0),
        a1 => reg_matrix(0,1),
        a2 => reg_matrix(0,2),
        a3 => reg_matrix(1,0),
        a4 => reg_matrix(1,1),
        a5 => reg_matrix(1,2),
        a6 => reg_matrix(2,0),
        a7 => reg_matrix(2,1),
        a8 => reg_matrix(2,2),
        medijan => pixel_out
        );
        
        FIFO1_PORT_MAP: fifo_buffer 
        generic map(
        C_IMG_WIDTH => 253
        )
        port map (
        data_in  => reg_matrix(0,2),
        data_out => fifo1_out,
        valid    => fifo1_valid,
        enable   => fifo1_enable,
        reset    => reset,
        clk      => clk
        );
        
        FIFO2_PORT_MAP: fifo_buffer 
        generic map(
        C_IMG_WIDTH => 253
        )
        port map (
        data_in  => reg_matrix(1,2),
        data_out => fifo2_out,
        valid    => fifo2_valid,
        enable   => fifo2_enable,
        reset    => reset,
        clk      => clk
        );
        
        addra_converted <= std_logic_vector(to_unsigned(write_counter, clogb2(G_RAM_DEPTH)));
        addrb_converted <=std_logic_vector(to_unsigned(read_counter, clogb2(G_RAM_DEPTH)));
        
        RAM_PORT_MAP: im_ram 
        generic map (
            G_RAM_WIDTH => 8,            		    -- Specify RAM data width
            G_RAM_DEPTH => 65536, 
            G_RAM_PERFORMANCE => "HIGH_PERFORMANCE" -- Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
        )
        port map(
            addra => addra_converted,     -- Write address bus, width determined from RAM_DEPTH
            addrb => addrb_converted,     -- Read address bus, width determined from RAM_DEPTH
            dina  => pixel_out,		  -- RAM input data
            clka  => clk,                       			  -- Clock
            wea   => write_enable_int,                      			  -- Write enable
            enb   => '1',                      			  -- RAM Enable, for additional power savings, disable port when not in use
            rstb  => reset,    
            regceb => '1',                  			  -- Output reset (does not affect memory contents)                     			  -- Output register enable
            doutb => pixel_in		  -- RAM output data
        );
        

    STATE_TRANSITION: process (clk) is
        begin
            if (rising_edge(clk)) then
                if (reset = '1') then
                    state_reg <= idle;
                else
                    state_reg <= next_state;
                end if;        
            end if;
        end process STATE_TRANSITION;
    
    NEXT_STATE_LOGIC: process (state_reg, start_process, read_counter, write_counter) is
  
        begin
            case (state_reg) is
               when idle=>
             
                    if (start_process='0') then
                        next_state<=idle;
                    else
                        next_state<=read;
                    end if;
               
                when read =>
                    if (read_counter= 260 + C_MEDIANA_PIPELINE_DEPTH) then --kad procita prva 2 reda, krece da pise
                        next_state<=readwrite;
                    else
                        next_state<=read;
                    end if;
                when readwrite =>
                    if (read_counter=256*256 - 1) then  -- kad procita celu memoriju
                        next_state<=write;
                    else
                        next_state<=readwrite;
                    end if;
                when write =>
                    
                    if (write_counter=256*256 - 1) then -- kad ispise sve
                        next_state<=idle;
                    else
                        next_state<=write;
                    end if;
            end case;
    end process NEXT_STATE_LOGIC;
    
    FLAG_LOGIC: process(clk) is
        begin
        if (rising_edge(clk)) then
          if (reset = '1') then
            read_counter<=0;
            write_counter<=0;
          else
            if (state_reg = read) then
               read_counter<=read_counter+1; 
            elsif (state_reg = readwrite) then
                read_counter<=read_counter+1;
                write_counter<=write_counter+1;                                                        
             elsif (state_reg = write) then
                write_counter<=write_counter+1;  
             end if;
            end if;
          end if;  
    end process FLAG_LOGIC;
    
        REG_MATRIX_PROCESS: process(clk) is
        begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                reg_matrix <= (others => (others=> (others => '0')));
            else
                if (read_counter >= 2) then
                    reg_matrix(0,0) <= pixel_in;
                    reg_matrix(0,1) <= reg_matrix(0,0);
                    reg_matrix(0,2) <= reg_matrix(0,1);
                end if;
                if (fifo1_valid = '1') then 
                    reg_matrix(1,0) <= fifo1_out;
                    reg_matrix(1,1) <= reg_matrix(1,0);
                    reg_matrix(1,2) <= reg_matrix(1,1);
                end if;
                if (fifo2_valid = '1') then 
                    reg_matrix(2,0) <= fifo2_out;
                    reg_matrix(2,1) <= reg_matrix(2,0);
                    reg_matrix(2,2) <= reg_matrix(2,1);
                end if;
                
            end if;
        end if;
        end process REG_MATRIX_PROCESS;
        
        CONTROL_SIGNALS_LOGIC: process(read_counter, state_reg) is
        begin
            if (read_counter >= 5) then
                fifo1_enable <= '1';
            else 
                fifo1_enable <= '0';    
            end if;
            if (read_counter >= 261) then
                fifo2_enable <= '1';
            else
                fifo2_enable <= '0';
            end if;
        end process CONTROL_SIGNALS_LOGIC;
        
        ROW_AND_COL_LOGIC: process(clk) is
        begin
            if (rising_edge(clk)) then
                if reset= '1' then
                    row <= 0;
                    col <= 0;
                else
                    if (state_reg = write or state_reg = readwrite) then
                        if (col = 255) then
                            col <= 0;
                            row <= row+1;
                        else
                            col <= col+1;
                        end if;
                    else 
                        row <= 0;
                        col <= 0;
                    end if;
                end if;
            end if;
        end process ROW_AND_COL_LOGIC;
        
        WRITE_ENABLE_LOGIC: process (state_reg, row, col, reset) is --ne dozvoliti upis u ivicne piksele jer sluze samo za padding
        begin
            if (reset = '1') then
                write_enable_int <= '0';
            elsif (state_reg = readwrite or state_reg = write) then
                if (row = 0 or col = 0 or row = 255 or col = 255) then
                    write_enable_int <= '0';
                else
                    write_enable_int <= '1';
                end if;
            else 
                write_enable_int <= '0';    
            end if;
        end process WRITE_ENABLE_LOGIC;
        
        write_enable <= write_enable_int;
        
        OUTPUT_SIGNAL_LOGIC: process (state_reg, pixel_out) is --za testiranje
        begin
            if (state_reg = readwrite or state_reg = write) then
                output<= pixel_out;
            else
                output <= (others => '0');
            end if;
        end process OUTPUT_SIGNAL_LOGIC;


    

end Behavioral;
