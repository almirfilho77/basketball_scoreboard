-- Laboratório de Sistemas Digitais
--	Professor: Bruno
-- Alunos:	Lucas Bezerra
--				Almir Firmo
-- Experimento 12 - Jogo de basquete

-- Inclusão das bibliotecas necessárias
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- Definiçao da endidade principal e suas saídas
-- Entradas:
--				clk - Clock de 50 MHz
--				btn_q - Botão de controle dos quartos
--				a1,a2,a3 - Botões de cesta do time A
--				b1,b2,b3 - Botôes de cesta do time B
--				s_btn - Botão de reiniciar a partida
--	Saídas:
--				D0...D2 - Saídas para os displays de 7 segmentos da pontuação do time A
--				D3...D5 - Saídas para os displays de 7 segmentos da pontuação do time B
--				D6 e D7 - Saídas para os displays de 7 segmentos que indicam o quarto atual

entity basket_game is
port(
    clk										:	in	std_logic;                          
    btn_q,a1,a2,a3,b1,b2,b3,s_btn	:	in std_logic;
	 D0,D1,D2,D3,D4,D5,D6,D7			:	out std_logic_vector(6 downto 0)
	 
	 );
end basket_game;

-- Definição da arquitetura da entidade principal
architecture RTL of basket_game is
    
	-- Definição dos sinais auxiliares para conexões entre os módulos
	signal q_ld,clr,load,cesta,q_aux					:	std_logic;
	signal A_reg,B_reg,quarter_aux					:	std_logic_vector(7 downto 0);
	signal quarter_reg									:	std_logic_vector(1 downto 0);
	signal D8												:	std_logic_vector(6 downto 0); 
	signal counter_flag,quarter_flag					:	std_logic;
		
	component Controlador
	port(
		clk																:	in	std_logic;                          
		btn_q, cesta, quarter_flag,q_aux		:	in std_logic;
		q_load, load, clr												:	out std_logic

	 );
	 end component;

	component datapath 
	port(
		clk,q_ld,clr,load,btn_q						:	in	std_logic;                          
		a1,a2,a3,b1,b2,b3								:	in std_logic;
		cesta,q_aux										:	out std_logic;
		quarter_reg										:	out std_logic_vector(1 downto 0);
		A_reg,B_reg										:	out std_logic_vector(7 downto 0)
	);
	end component;

	component conversorBCD
	port(
		clk                     : 	 in std_logic;
		entrada                 :   in std_logic_vector(7 downto 0);
		disp0,disp1,disp2       :   out std_logic_vector(6 downto 0)
	);
   end component;
		
	 
begin

	-- Conversão dos dois bits de indicaçao do quarto atual para adequá-lo ao módulo do conversor BCD que recebe 8 bits
	quarter_aux(7 downto 3) <= "00000";
	quarter_aux(2 downto 0) <= quarter_reg + "001";
		
	-- Definiçao e conexão entre os módulos utilizados
	G1		:	Controlador		port map(clk,btn_q,cesta,NOT s_btn,q_aux,q_ld,load,clr);    
	G2		:	datapath			port map(clk,q_ld,clr,load,btn_q,a1,a2,a3,b1,b2,b3,cesta,q_aux,quarter_reg,A_reg,B_reg);
	G3		:	conversorBCD	port map(clk,A_reg,D0,D1,D2);
	G4		:	conversorBCD	port map(clk,B_reg,D3,D4,D5);
	G5		:	conversorBCD	port map(clk,quarter_aux,D6,D7,D8);
	  
end architecture;
