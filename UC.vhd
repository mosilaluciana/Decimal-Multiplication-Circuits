library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UC is
Port ( Clk: IN std_logic;
       Rst: IN std_logic;
       Step: IN std_logic;
       Error: IN std_logic;
       TermOp: IN std_logic;
       whichState: OUT std_logic_vector(5 downto 0));
       
end UC;

architecture Behavioral of UC is

type stare is (idle, selectMetoda, introdX, introdY, calcul, stop);

signal state: stare:=idle;
begin

proces_stare: process(Clk)
begin
    if (Rst = '1') then
        state <= idle;
    else
        if(Error = '1') then
            state <= stop;
        else    
        if(Clk = '1' and Clk'event) then
            case state is
                when idle => if (STEP = '1') then
                                state <= selectMetoda;
                             else
                                state <= idle;
                             end if;
                when selectMetoda =>    if (STEP = '1') then
                                            state <= introdX;
                                         else
                                            state <= selectMetoda;
                                         end if;
              when introdX =>   if (STEP = '1') then
                                          state <= introdY;
                                  else
                                           state <= introdX;
                                  end if;
              when introdY =>   if (STEP = '1') then
                                        state <= calcul;
                                  else
                                        state <= introdY;
                                  end if;
              when calcul => if (TermOp = '1') then
                                   state <= stop;
                              else
                                    state <= calcul;
                              end if;
              when others => state <= stop;
            end case;
        end if;
    end if;
    end if;
end process;

proces_iesiri: process(state)
begin
    case state is
        when idle =>        whichState <= "100000";
        when selectMetoda=> whichState <= "010000";
        when introdX =>     whichState <= "001000";
        when introdY =>     whichState <= "000100";
        when calcul =>      whichState <= "000010";
        when stop =>        whichState <= "000001";
        when others =>      whichState <= "111111";
    end case;
end process;
end Behavioral;