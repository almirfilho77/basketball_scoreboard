-- Laboratório de Sistemas Digitais
-- Alunos: Almir Soares / Lucas Bezerra
-- Laboratório 12 - Jogo de basquete

-- Módulo Conversor BCD

--Descrição: este módulo realiza a conversão dos dados em binário para a representação do display de 7 seguimentos.
-- O dado chega pela variável "entrada" e é quebrado de 4 em 4 bits e trasformado em um número de 0 a 9 no display. O
-- número é quebrado em unidade de milhar, centena, dezena e unidade, portanto a variável "entrada" deve representar
-- o valor dessa forma.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

-- Entradas: 	clk (sinal de clock), entrada (valor a ser convertido)
-- Saídas:		disp0...disp2 (sinal que vão para o display)

entity conversorBCD is port(
   clk             	   : 	 in std_logic;
   entrada              :   in std_logic_vector(7 downto 0);
   disp0,disp1,disp2    :   out std_logic_vector(6 downto 0)
);
end conversorBCD;


architecture hardware of conversorBCD is

	type dataout is array (0 to 15) of std_logic_vector(6 downto 0);

	signal matrix: dataout := ("0111111","0000110","1011011","1001111","1100110",				-- Display apagado para valores maiores que 9
                              "1101101","1111101","0000111","1111111","1100111",
										"0000000","0000000","0000000","0000000","0000000",
										"0000000");
										
	-- Conversão de binário para BCD
	--0 "1111110"
	--1 "0110000"
	--2 "1101101"
	--3 "1111001"
	--4 "0110011"
	--5 "1011011"
	--6 "1011111"
	--7 "1110000"
	--8 "1111111"
	--9 "1110011"	
	
	shared variable hex_src : std_logic_vector (4 downto 0) ;
   shared variable bcd     : std_logic_vector (11 downto 0);
	signal bcd_aux : std_logic_vector (11 downto 0);
    
begin

	process (entrada)
	begin
     
          bcd             := (others => '0') ;
          bcd(2 downto 0) := entrada(7 downto 5) ;
          hex_src         := entrada(4 downto 0) ;
          
        for i in hex_src'range loop
            if bcd(3 downto 0) > "0100" then
                bcd(3 downto 0) := bcd(3 downto 0) + "0011" ;
            end if ;
            if bcd(7 downto 4) > "0100" then
                bcd(7 downto 4) := bcd(7 downto 4) + "0011" ;
            end if ;
            -- No roll over for hundred digit, since in 0 .. 2

            bcd := bcd(10 downto 0) & hex_src(hex_src'left) ; -- shift bcd + 1 new entry
            hex_src := hex_src(hex_src'left - 1 downto hex_src'right) & '0' ; -- shift src + pad with 0
        end loop ;
    end process ;

	-- Chama a posição da matriz correspondente ao valor decimal da entrada
	
    disp0 <= NOT matrix(conv_integer(bcd(3 downto 0)));
    disp1 <= NOT matrix(conv_integer(bcd(7 downto 4)));
    disp2 <= NOT matrix(conv_integer(bcd(11 downto 8)));
end hardware;


