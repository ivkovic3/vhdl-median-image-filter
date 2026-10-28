library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity medijana is
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
end medijana;

architecture Behavioral of medijana is

    type row_type is array (8 downto 0) of std_logic_vector (7 downto 0);
    type matrix_type is array (8 downto 0) of row_type;
    signal linija: matrix_type;
    
    function min(vr1: std_logic_vector(7 downto 0); vr2: std_logic_vector(7 downto 0)) return std_logic_vector is
        variable minimum: std_logic_vector(7 downto 0);
    begin
       
        if unsigned(vr1) < unsigned(vr2) then
            minimum := vr1;
        else
            minimum := vr2;
        end if;
        return minimum;
    end function;
    
    function max(vr1: std_logic_vector(7 downto 0); vr2: std_logic_vector(7 downto 0)) return std_logic_vector is
        variable maksimum: std_logic_vector(7 downto 0); 
    begin
        
        if unsigned(vr1) > unsigned(vr2) then
            maksimum := vr1;
        else
            maksimum := vr2;
        end if;
        return maksimum;
    end function;
    
    
begin    
    FAZE: process (clk) is
    begin
        if(rising_edge(clk))then
            if (reset = '1') then
                linija <= (others => (others => (others=>'0')));
            else     
        
            --faza1
            linija(0)(0)<= min(a0, a1);
            linija(1)(0)<= max (a0, a1);
            
            linija(2)(0)<= min (a2, a3);
            linija(3)(0)<= max (a2, a3);
            
            linija(4)(0)<= min (a4, a5);
            linija(5)(0)<= max (a4, a5);
            
            linija(6)(0)<= min (a6, a7);
            linija(7)(0)<= max (a6, a7);  
            
            linija(8)(0)<= a8;  
           --faza2 
            linija(0)(1)<= min (linija(0)(0),linija(2)(0));
            linija(2)(1)<= max (linija(0)(0),linija(2)(0));
            
            linija(1)(1)<= min (linija(1)(0),linija(3)(0));
            linija(3)(1)<= max (linija(1)(0),linija(3)(0));
            
            linija(4)(1)<= min (linija(4)(0),linija(6)(0));
            linija(6)(1)<= max (linija(4)(0),linija(6)(0));
            
            linija(5)(1)<= min (linija(5)(0),linija(7)(0));
            linija(7)(1)<= max (linija(5)(0),linija(7)(0)); 
            
            linija(8)(1)<= a8;
           --faza3
            linija(1)(2)<= min (linija(1)(1),linija(2)(1));
            linija(2)(2)<= max (linija(1)(1),linija(2)(1));
            
            linija(5)(2)<= min (linija(5)(1),linija(6)(1));
            linija(6)(2)<= max (linija(5)(1),linija(6)(1));
            
            linija(0)(2)<= linija (0)(1);
            linija(3)(2)<= linija (3)(1);
            linija(4)(2)<= linija (4)(1);
            linija(7)(2)<= linija (7)(1);
            linija(8)(2)<= linija (8)(1);
            
           -- faza4
            linija(0)(3)<= min (linija(0)(1),linija(4)(1));
            linija(4)(3)<= max (linija(0)(1),linija(4)(1));
            
            linija(1)(3)<= min (linija(1)(2),linija(5)(2));
            linija(5)(3)<= max (linija(1)(2),linija(5)(2));
            linija(2)(3)<= min (linija(2)(2),linija(6)(2));
            linija(6)(3)<= max (linija(2)(2),linija(6)(2));
            linija(3)(3)<= min (linija(3)(1),linija(7)(1));
            linija(7)(3)<= max (linija(3)(1),linija(7)(1));
            linija(8)(3)<= linija(8)(2);
           --faza5
           linija(1)(4)<= linija(1)(3);
           linija(0)(4)<= linija(0)(3);
           linija (2)(4)<= min (linija(4)(3),linija(2)(3));
           linija (4)(4)<= max (linija(4)(3),linija(2)(3));
           linija (3)(4)<= min (linija(3)(3),linija(5)(3));
           linija (5)(4)<= max (linija(3)(3),linija(5)(3));
           linija(6)(4)<= linija(6)(3);
           linija(7)(4)<= linija(7)(3);
           linija(8)(4)<= linija(8)(3);
           --faza6
            linija(1)(5)<= min (linija(1)(3),linija(2)(4));
            linija(2)(5)<= max (linija(1)(3),linija(2)(4));
            
            linija(3)(5)<= min (linija(3)(4),linija(4)(4));
            linija(4)(5)<= max (linija(3)(4),linija(4)(4));
            
            linija(5)(5)<= min (linija(5)(4),linija(6)(3));
            linija(6)(5)<= max (linija(5)(1),linija(6)(3));
            
            linija(0)(5)<= min (linija(0)(3),a8);
            linija(8)(5)<= max (linija(0)(3),a8);
            linija(7)(5)<= linija(7)(4);
            
            --faza7
            linija(4)(6)<= min (linija(8)(5),linija(4)(5));
            linija(8)(6)<= max (linija(8)(5),linija(4)(5)); 
            linija(0)(6)<= linija(0)(5);
            linija(1)(6)<= linija(1)(5);
            linija(2)(6)<= linija(2)(5);
            linija(3)(6)<= linija(3)(5);
            linija(5)(6)<= linija(5)(5);
            linija(6)(6)<= linija(6)(5);
            linija(7)(6)<= linija(7)(5);
            
            --faza8
            linija(0)(7)<= linija(0)(6);
            linija(1)(7)<= linija(1)(6);
            linija(2)(7)<= min (linija(2)(5),linija(4)(6));
            linija(4)(7)<= max (linija(2)(5),linija(4)(6)); 
            
            linija(3)(7)<= min (linija(3)(5),linija(5)(5));
            linija(5)(7)<= max (linija(3)(5),linija(5)(5)); 
            linija(6)(7)<= linija(6)(6);
            linija(7)(7)<= linija(7)(6);
            linija(8)(7)<= linija(8)(6);
            --faza 9
            medijan <= max (linija(3)(7),linija(4)(7));
            
            end if;
        
        end if;
    end process FAZE;

end Behavioral;
