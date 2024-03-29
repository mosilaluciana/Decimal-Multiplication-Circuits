library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Inmultire_zecimala_Metoda1 is
Port (
    Clk: IN std_logic;
    X: IN std_logic_vector(15 downto 0);
    Y: IN std_logic_vector(15 downto 0);
    Rst: IN std_logic;
    Start: IN std_logic;
    P: OUT std_logic_vector(31 downto 0);
    Term: OUT std_logic);
end Inmultire_zecimala_Metoda1;

architecture Behavioral of Inmultire_zecimala_Metoda1 is
signal LoadB: std_logic;
signal Bout: std_logic_vector(15 downto 0):=x"0000";

signal SumatorOut: std_logic_vector(19 downto 0);
signal SumatorTOut: std_logic;

signal AccOut: std_logic_vector(19 downto 0); 
signal RstA: std_logic;
signal RstB: std_logic;
signal RstQ: std_logic;
signal LoadA: std_logic;
signal shrAQ: std_logic;

signal D_in_accumulator: std_logic_vector(19 downto 0):="00000000000000000000"; 

signal LoadQ: std_logic;
signal Qout: std_logic_vector(15 downto 0);
signal A0: std_logic_vector(3 downto 0);
signal Q0: std_logic_vector(3 downto 0);
signal SRI_acc: std_logic_vector(3 downto 0);


signal firstOperand: std_logic_vector(19 downto 0);

begin

D_in_accumulator <= SumatorOut;
A0 <= AccOut(3 downto 0);
Q0 <= Qout(3 downto 0);
firstOperand <= "0000" & Bout; -- se concateneaza 0 deoarece sumatorul este pe 5 cifre, iar b pe 4

--Registru_B aici se stocheaza (deinmultitul) X
reg_b: entity work.bistabil_N_reset_sincron generic map(n=>16) port map (Clk => Clk, Rst => RstB, en => LoadB, D => X, Q => Bout);

Sumator_zecimal: entity work.Sumator_zecimal_5 port map(X => firstOperand,Y => AccOut, Tin => '0' ,S => SumatorOut , Tout => SumatorTOut );

--Accumulator A
Accumulator_A: entity work.SRRN generic map(n=>20) port map(Clk => Clk, D => D_in_accumulator, SRI => "0000", Rst => RstA, en => shrAQ, Load => loadA, Q => AccOut);

--Registru_Q (Inmultitorul) Y
reg_q: entity work.SRRN generic map(n=>16) port map(Clk => Clk, D => Y, SRI => A0, Rst => RstQ, en => shrAQ, Load => LoadQ, Q => Qout);

--UC
uc_metoda1: entity work.UC_metoda1 port map(Clk => Clk, Rst => Rst, Start => Start, Q0 => Q0, LoadB => LoadB, RstA => RstA, RstB => RstB, RstQ => RstQ, LoadA => LoadA, LoadQ => LoadQ, shrAQ => shrAQ, Term=>Term);

P <= AccOut(15 downto 0) & Qout(15 downto 0);
end Behavioral;