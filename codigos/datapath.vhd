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

-- Definição do datapath e de suas entradas e saidas
-- Entradas:
--				clk - Clock de 50 MHz
--				q_load - Load do registrador que armazena o quarto atual
--				clr - Clear de todos os registradores do datapath
--				load - Load dos registradores que armazenam a pontuação dos times
--				btn_q - Botão de controle do quarto
--				a1,a2,a3 - Botões de cesta do time A
--				b1,b2,b3 - Botôes de cesta do time B
--	Saídas:
--				cesta - Sinal que indica a ocorrência de uma cesta
--				q_aux - Sinal auxiliar para indicar final do último quarto
--				quarter_reg - Registrador que armazena o quarto atual
--				A_reg,B_reg	-	Registradores que armazenam a pontuação do time A e do time B, respectivamente
entity datapath is
port(
    clk,q_ld,clr,load,btn_q						:	in	std_logic;                          
    a1,a2,a3,b1,b2,b3								:	in std_logic;
	 cesta,q_aux										:	out std_logic;
	 quarter_reg										:	out std_logic_vector(1 downto 0);
	 A_reg,B_reg										:	out std_logic_vector(7 downto 0)	 
	 );
end datapath;

-- Definiçao da arquitetura do datapath
architecture RTL of datapath is
    
	 -- Definiçao dos sinais auxiliares do datapath
	 signal E							:	std_logic;								-- Sinal que indica o time autor da cesta
	 signal vc							:	std_logic_vector(1 downto 0);		--	Sinal que indica o valor da cesta 
	 signal vc_8b,B_aux,A_aux		:	std_logic_vector(7 downto 0);		--	Registradores auxiliares para compatibilizar operações algébicas
	 signal quarter_aux				:	std_logic_vector(1 downto 0);		--	Registrador auxiliar que possibilita operações algébricacs com o registrador do quarto
	 
begin
		
	vc(0) <= a1 OR b1 OR a3 OR b3;	-- Lógica combinacional para indicar pontuação da cesta detectada, conforme página 3 do PDF
	vc(1) <= a2 OR	a3 OR b2 OR b3;												
	
	cesta <= vc(0) OR vc(1);	-- Lógica combinacional para indicar ocorrência de uma cesta, conforme página 3 do PDF							
	
	E <= b1 OR b2 OR b3;	--	Lógica combinacional para indicar time autor da cesta, conforme página 3 do PDF

	vc_8b(7 downto 2) <= "000000"; -- Adequaçao de tamano do vetor para poder incrementar nos registradores de pontuação dos times
	vc_8b(1 downto 0) <= vc;
	
	A_reg <= A_aux;
	B_reg <= B_aux;
	quarter_reg <= quarter_aux;
	
	process(clk, q_ld,clr,load,E)
	begin
		if rising_edge(clk) then			
						
			if quarter_aux = "11" then		
				if btn_q = '1' then
					q_aux <= '1';	-- Ao entrar no último quarto a variável auxiliar q_aux recebe valor 1
				end if;
			else
				if q_ld = '1' then
					quarter_aux <= quarter_aux + "01";		-- Caso não esteja no último quarto e seja indicada a passagem de quarto é 
																		--	incrementada uma unidade no registrador do quarto
				end if;
			end if;
			
			if load = '1' then		--	Caso seja detectada uma cesta o registador correspondente de acordo com o sinal E
											--	é incrementado no valor "vc" da cesta 
				if (E = '1') then
					B_aux <= B_aux + vc_8b;				
				else
					A_aux <= A_aux + vc_8b;
				end if;	
			end if;
			
			if clr = '1' then			-- Caso a partida seja reiniciada todos os registradores são zerados
				quarter_aux <= "00";
				A_aux <= "00000000";
				B_aux <= "00000000";
				q_aux <= '0';
			end if;
	
			
		end if;
	end process;



end architecture;
