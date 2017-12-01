-- Laboratório de Sistemas Digitais
-- Alunos: Almir Soares / Lucas Bezerra
-- Laboratório 12 - Jogo de basquete

-- Módulo Controlador

-- Descrição: neste módulo está a máquina de estados que controla o Datapath e determina as respostas do sistema a cada entrada. A máquina é composta 
-- por 6 estados: INIT, PLAY, SCORE, TIMER, TIME_OUT E FINISH.
-- Ao ligar o scoreboard o estado INIT zera todos os registradores e a máquina entra no estado PLAY quando o btn_q fica ALTO, indicando que o jogo
-- está em curso. Durante o jogo (btn_q = 1), quando a bola entra na cesta, o sistema entra no estado SCORE onde ele soma o valor da cesta (1, 2 e 3)
-- ao valor total já pontuado, discriminando a pontuação entre a equipe da casa (A) e a equipe visitante (B), e retorna ao estado de espera. Quando o btn_q
-- fica em valor BAIXO, o jogo vai para o intervalo (TIME_OUT) passando pelo TIMER (onde o quarto é incrementado), só retornando quando o btn_q fica ALTO 
-- novamente. No último quarto a variável q_aux indica que o jogo deve acabar ao fim do quarto, logo não será possível retornar ao jogo a não ser que o 
-- s_btn seja apertado, fazendo a máquina passar pelo estado FINISH e voltar ao INIT.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entradas: 	clk (sinal de clock); 
--				btn_q (inicio e fim do quarto); 
--				cesta (sensor indicando que a bola entrou na cesta);
--				quarter_flag (botão de reset);
--				q_aux (flag indicando último quarto).

-- Saídas:		q_load (sinal de load do registrador quarter_reg);
--				load (load dos outros registradores do Datapath);
--				clr (clear de todos os registradores do Datapath);

-- Regs. auxs.:	current_state (estado atual da máquina de estados);
--				aux (auxiliar da lógica do sensor de cesta);
--				cesta_aux (sinal do sensor pós processado);

entity Controlador is
port(
	clk																		:	in	std_logic;                          
	btn_q, cesta, quarter_flag, q_aux										:	in std_logic;										
	q_load, load, clr														:	out std_logic
	);
end Controlador;

architecture RTL of Controlador is
    type state is (INIT, PLAY, SCORE, TIME_OUT, TIMER, FINISH);
    signal current_state        :   state   :=  INIT;
	 
	 signal aux				:	std_logic := '1';
	 signal cesta_aux		:	std_logic;

begin
	-- Atribuição do sinal do sensor pós processado
	
	cesta_aux <= cesta AND aux;
   
	-- Lógica para suavizar o sinal do sensor de cesta
	
	process(clk,cesta)
    begin    
        if rising_edge(clk) then
            if cesta = '1' then
                aux <= '0';
            else
                aux <= '1';
            end if;
        end if;
    end process;
	
	-- Implementação da FSM de acordo com a página 1 e a página 4 do PDF (Máquina de alto nível e de baixo nível, respectivamente)
	
	process(clk)
	begin
		if rising_edge(clk) then
			case current_state is
			
				when INIT => 
					if  btn_q = '1' then
						current_state <= PLAY;
					else
						current_state <= INIT;
					end if;
						
				when PLAY =>
					if  btn_q = '0' then
							current_state <= TIMER;
					else
						if cesta_aux = '1' then 
							current_state <= SCORE;
						else
							current_state <= PLAY;
						end if;
					end if;
				 
				when SCORE =>
					current_state <= PLAY;
					 
				when TIMER =>
					current_state <= TIME_OUT;
				 
				when TIME_OUT =>
					if quarter_flag = '1' then
						current_state <= FINISH;
					else
						if btn_q = '1' AND q_aux = '0' then
							current_state <= PLAY;
						else
							current_state <= TIME_OUT;
						end if;
					end if;
					  
					  
				when FINISH =>
					if quarter_flag = '1' then
						current_state <= INIT;
					else
						current_state <= FINISH;
					end if;
						  
			end case;
		end if;
	end process;
	
	-- Criação e atribuição dos sinais de controle do Datapath de acordo com a página 1 e a página 4 do PDF (Máquina de alto nível e de baixo nível, 
	-- respectivamente)

	process(clk)
	begin
		if rising_edge(clk) then
		  
			case current_state is
				when INIT =>
					clr  <= '1';
					load <= '0';
					q_load <= '0';
									
				when PLAY =>
					clr  <= '0';
					load <= '0';
					q_load <= '0';
					 
				when SCORE =>   
					clr  <= '0';
					load <= '1';
					q_load <= '0';
					
				when TIMER =>
					clr  <= '0';
					load <= '0';
					q_load <= '1';
					
				when TIME_OUT =>
					clr  <= '0';
					load <= '0';
					q_load <= '0';
					
				when FINISH =>
					clr  <= '0';
					load <= '0';
					q_load <= '0';
					
				end case;
		end if;
	end process;
end architecture;
