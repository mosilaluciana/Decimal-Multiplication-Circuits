library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bistabil_N_reset_sincron is
generic(n:integer);
Port (
    Clk: IN std_logic;
    Rst: IN std_logic;
    en: IN std_logic;--enable
    D: IN std_logic_vector(n-1 downto 0);
    Q: OUT std_logic_vector(n-1 downto 0) );
end bistabil_N_reset_sincron;

architecture Behavioral of bistabil_N_reset_sincron is

begin

process(Clk)
begin
    if(clk = '1' and clk'event) then
        if(Rst = '1') then
            Q <= (others => '0');
        else
            if(en = '1') then
                Q <= D;
            end if;
        end if;
    end if;
end process;
end Behavioral;