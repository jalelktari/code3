library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pos is
    generic (
        VALIDATOR_COUNT : natural := 5; -- Nombre de validateurs
        BLOCK_SIZE : natural := 256, -- Taille de bloc en bits
        TOKEN_SIZE : natural := 128 -- Taille de jeton en bits
    );
    port (
        clk : in std_logic; -- Horloge
        rst : in std_logic; -- Reset
        tx_data : in std_logic_vector(BLOCK_SIZE-1 downto 0); -- Données de transaction
        tx_valid : in std_logic; -- Indicateur de validité de transaction
        validator_token : in std_logic_vector(VALIDATOR_COUNT-1 downto 0)(TOKEN_SIZE-1 downto 0); -- Jetons détenus par chaque validateur
        block_data : out std_logic_vector(BLOCK_SIZE-1 downto 0); -- Données de bloc
        block_valid : out std_logic -- Indicateur de validité de bloc
    );
end pos;

architecture rtl of pos is
    signal validator_index : integer range 0 to VALIDATOR_COUNT-1 := 0; -- Index du validateur en cours
    signal block_data_int : unsigned(BLOCK_SIZE-1 downto 0); -- Données de bloc en entier non signé
    signal block_valid_int : std_logic := '0'; -- Indicateur de validité de bloc en entier
begin

    process(clk, rst)
    begin
        if rst = '1' then
            validator_index <= 0;
            block_data_int <= (others => '0');
            block_valid_int <= '0';
        elsif rising_edge(clk) then
            if tx_valid = '1' then -- Si une transaction est valide
                block_data_int <= block_data_int xor unsigned(tx_data); -- Ajouter les données de transaction au bloc
            end if;
            if validator_token(validator_index) > random_unsigned(TOKEN_SIZE) then -- Sélectionner le validateur en fonction du jeton détenu
                block_valid_int <= '1'; -- Le bloc est valide
            end if;
            validator_index <= (validator_index + 1) mod VALIDATOR_COUNT; -- Passer au validateur suivant
        end if;
    end process;

    block_data <= std_logic_vector(block_data_int); -- Conversion en std_logic_vector
    block_valid <= block_valid_int; -- Conversion en std_logic

end rtl;
