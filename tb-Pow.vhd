library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_pow is
end tb_pow;

architecture testbench of tb_pow is
    constant MESSAGE_SIZE : positive := 8;
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal tx_data : std_logic_vector(MESSAGE_SIZE-1 downto 0) := (others => '0');
    signal tx_valid : std_logic := '0';
    signal commit_done : std_logic;
    signal result_data : std_logic_vector(MESSAGE_SIZE-1 downto 0);

begin

    dut : entity work.pow
        generic map(
            MESSAGE_SIZE => MESSAGE_SIZE,
            DIFFICULTY => 4 -- Difficulté de 4 pour les tests
        )
        port map(
            clk => clk,
            rst => rst,
            tx_data => tx_data,
            tx_valid => tx_valid,
            commit_done => commit_done,
            result_data => result_data
        );

    process
    begin
        rst <= '0'; -- Désactiver le reset après quelques cycles
        wait for 10 ns;
        rst <= '1';

        -- Envoyer une transaction valide
        tx_data <= "10101010";
        tx_valid <= '1';
        wait for 10 ns;
        assert commit_done = '1' report "Consensus not reached" severity error;
        assert result_data = "11010001" report "Incorrect result" severity error;
        tx_valid <= '0';

        -- Envoyer une transaction invalide (taille de message incorrecte)
        tx_data <= "110011001100";
        tx_valid <= '1';
        wait for 10 ns;
        assert commit_done = '0' report "Consensus reached with invalid message" severity error;
        tx_valid <= '0';

        -- Envoyer plusieurs transactions valides
        for i in 0 to 2 loop
            tx_data <= std_logic_vector(to_unsigned(i, MESSAGE_SIZE));
            tx_valid <= '1';
            wait for 10 ns;
            tx_valid <= '0';
        end loop;
        assert commit_done = '1' report "Consensus not reached" severity error;
        assert result_data = std_logic_vector(to_unsigned(2, MESSAGE_SIZE)) report "Incorrect result" severity error;

        wait;
    end process;

    process
    begin
        while true loop
            clk <= not clk; -- Générer une horloge
            wait for 5 ns;
        end loop;
    end process;

end testbench;
