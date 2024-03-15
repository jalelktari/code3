library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pow is
    generic (
        BLOCK_SIZE : natural := 256, -- Taille de bloc en bits
        TARGET : std_logic_vector(255 downto 0) := (others => '0') & '1' & (others => '0') -- Cible de difficulté de preuve de travail
    );
    port (
        clk : in std_logic; -- Horloge
        rst : in std_logic; -- Reset
        tx_data : in std_logic_vector(BLOCK_SIZE-1 downto 0); -- Données de transaction
        tx_valid : in std_logic; -- Indicateur de validité de transaction
        nonce : out std_logic_vector(31 downto 0); -- Nonce calculé
        block_data : out std_logic_vector(BLOCK_SIZE-1 downto 0); -- Données de bloc
        block_valid : out std_logic -- Indicateur de validité de bloc
    );
end pow;

architecture rtl of pow is
    signal block_data_int : unsigned(BLOCK_SIZE-1 downto 0); -- Données de bloc en entier non signé
    signal hash_value_int : unsigned(255 downto 0); -- Valeur de hachage SHA-256 en entier non signé
    signal target_int : unsigned(255 downto 0); -- Cible de difficulté de preuve de travail en entier non signé
    signal nonce_int : unsigned(31 downto 0) := (others => '0'); -- Nonce en entier non signé
    signal block_valid_int : std_logic := '0'; -- Indicateur de validité de bloc en entier
begin

    target_int <= unsigned(TARGET);

    process(clk, rst)
    begin
        if rst = '1' then
            block_data_int <= (others => '0');
            nonce_int <= (others => '0');
            block_valid_int <= '0';
        elsif rising_edge(clk) then
            if tx_valid = '1' then -- Si une transaction est valide
                block_data_int <= block_data_int xor unsigned(tx_data); -- Ajouter les données de transaction au bloc
            end if;
            block_data_int(BLOCK_SIZE-1 downto 32) <= nonce_int; -- Ajouter le nonce au bloc
            hash_value_int <= SHA256(block_data_int); -- Calculer la valeur de hachage SHA-256
            if hash_value_int <= target_int then -- Vérifier si la valeur de hachage est inférieure ou égale à la cible de difficulté
                block_valid_int <= '1'; -- Le bloc est valide
            end if;
            nonce_int <= nonce_int + 1; -- Incrémenter le nonce
        end if;
    end process;

    nonce <= std_logic_vector(nonce_int); -- Conversion en std_logic_vector
    block_data <= std_logic_vector(block_data_int); -- Conversion en std_logic_vector
    block_valid <= block_valid_int; -- Conversion en std_logic

end rtl;
