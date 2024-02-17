library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Modul_principal is
Port (
    Clk: IN std_logic;
    Rst: IN std_logic;
    sw: IN std_logic_vector(15 downto 0);
    btn : IN std_logic_vector(4 downto 0);
    an: out STD_LOGIC_VECTOR(3 downto 0);
    cat: out STD_LOGIC_VECTOR(6 downto 0);
    led: out STD_LOGIC_VECTOR(8 downto 0);
    Term: out STD_LOGIC );
end Modul_principal;

architecture Behavioral of Modul_principal is

component MPG is
    Port ( input : in STD_LOGIC;
           clk : in STD_LOGIC;
           enable : out STD_LOGIC);
end component;

component bistabil_N_reset_sincron is
generic(n:integer);
Port (
    Clk: IN std_logic;
    Rst: IN std_logic;
    en: IN std_logic;
    D: IN std_logic_vector(n-1 downto 0);
    Q: OUT std_logic_vector(n-1 downto 0) );
end component;

component UC is
Port ( Clk: IN std_logic;
       Rst: IN std_logic;
       Step: IN std_logic;
       Error: IN std_logic;
       TermOp: IN std_logic;
       whichState: OUT std_logic_vector(5 downto 0));
       
end component;

component SSD is
    Port ( clk : in STD_LOGIC;
           number : in STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end component;

signal StepStartSignal: std_logic;
signal whichState: std_logic_vector(5 downto 0);
signal TermOp: std_logic;
signal X: std_logic_vector(15 downto 0);
signal Y: std_logic_vector(15 downto 0);
signal metoda: std_logic;
signal Term1: std_logic;
signal Term2: std_logic;
signal StartT1: std_logic;
signal P1: std_logic_vector(31 downto 0);
signal StartT2: std_logic;
signal P2: std_logic_vector(31 downto 0);
signal P: std_logic_vector(31 downto 0);
signal Data:std_logic_vector(31 downto 0);
signal errorX: std_logic:='0';
signal errorY: std_logic:='0';
signal errorMetoda: std_logic:='0';
signal error:std_logic;
signal enableMetodaRegistru: std_logic;
signal enableXReg: std_logic;
signal enableYReg: std_logic;
signal afis: std_logic_vector(15 downto 0);
begin

TermOp <= Term1 or Term2;
Term <= whichState(0); --stop
enableMetodaRegistru <= whichState(4) and StepStartSignal;
enableXReg <= whichState(3) and StepStartSignal;
enableYReg <= whichState(2) and StepStartSIgnal;
error <= errorX or errorY;

--SSD 
seven_sd: SSD port map (clk  => Clk, number => afis, an => An, cat => Cat);

mpg1: MPG port map(input => btn(0), clk => Clk, enable => StepStartSignal);

UC_Principala: UC port map (Clk => Clk, Rst => btn(1), Step => StepStartSignal, Error => error, TermOp => TermOp, whichState => whichState);

RegistruX: bistabil_N_reset_sincron generic map (n => 16) port map (Clk => Clk, Rst => btn(1), en => enableXReg , D => sw, Q => X);
RegistruY: bistabil_N_reset_sincron generic map (n => 16) port map (Clk => Clk, Rst => btn(1), en => enableYReg, D => sw, Q => Y);
RegistruMetoda: entity work.bistabil_reset_sincron port map (Clk => Clk, Rst => btn(1), en => enableMetodaRegistru, D => sw(0), Q => metoda);


 metoda1: entity work.Inmultire_zecimala_Metoda1 port map (Clk => Clk, X => X, Y => Y, Rst => btn(1), Start => StartT1, P => P1, Term => Term1);
 metoda2: entity work.Inmultire_zecimala_Metoda2 port map (Clk => Clk, X => X, Y => Y, Rst => btn(1), Start => StartT2, P => P2, Term => Term2);


led(8 downto 3) <= whichState (5 downto 0);
led(2) <= errorX;
led(1) <= errorY;
led(0) <= metoda;


proces_start: process(Clk)
begin
if(rising_edge(Clk)) then
    if(whichState(2) = '1') then
        if(StepStartSignal = '1') then
        case metoda is
            when '0'  => StartT1 <= '1';
                        StartT2 <= '0';
            when '1' => StartT1 <= '0';
                         StartT2 <= '1';
            when others => StartT1 <= '0';
                         StartT2 <= '0';
        end case;
    end if;
    end if;
end if;
end process;

P <= P1 when metoda = '0' else P2 when metoda = '1' else x"00000000";
      
proces_date_pe_ssd: process(Clk, error, whichState, sw, P, X, Y)
begin
    if(error = '1') then
        afis <= x"EEEE";
    else
        if (whichState(0) = '1') then  
            -- sw(1) sw(0)
            -- PH   10 
            -- PL   00
            -- X    01 
            -- Y    11
                if (sw(0) = '0') then
                    if (sw(1) = '0') then
                        afis <= P(15 downto 0);
                    else
                        afis <= P(31 downto 16);
                    end if;
                elsif (sw(0) = '1') then
                    if (sw(1) = '0') then
                        afis <= X;
                    else
                        afis <= Y;
                    end if;
                end if;
        else
                case whichState is
                    when "010000" =>
                        if sw(0) = '0' then
                            afis <= x"000" & "0001";
                                else
                            afis <= x"000" & "0010";
                            end if;
                    when "001000" => afis <= sw;
                    when "000100" => afis <= sw;
                    when others => afis <= x"FFFF";
                end case;
        end if;
    end if;
end process;



errorX <= '1' when X(15 downto 12)>"1001" or X(11 downto 8)>"1001" or X(7 downto 4)>"1001" or X(3 downto 0)>"1001" else '0';
errorY <= '1' when Y(15 downto 12)>"1001" or Y(11 downto 8)>"1001" or Y(7 downto 4)>"1001" or Y(3 downto 0)>"1001" else '0';

end Behavioral;