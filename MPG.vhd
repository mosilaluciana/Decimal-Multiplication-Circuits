library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity MPG is
    Port ( input : in STD_LOGIC;
           clk : in STD_LOGIC;
           enable : out STD_LOGIC);
end MPG;

architecture Behavioral of MPG is

signal count_int : std_logic_vector(31 downto 0) :=x"00000000";
signal Q1 : std_logic;
signal Q2 : std_logic;
signal Q3 : std_logic;

begin

enable <= Q2 AND (not Q3);
process (clk) 
   begin
    if (rising_edge(clk)) then
      count_int <= count_int + 1;
    end if;
end process;

process (clk)
    begin
        if clk'event and clk='1' then 
            if count_int(15 downto 0) = "1111111111111111" then 
                Q1 <= input;
            end if; 
        end if;
end process;

process (clk)
begin
    if clk'event and clk='1' then 
        Q2 <= Q1;
        Q3 <= Q2;
     end if;
end process;


end Behavioral;
