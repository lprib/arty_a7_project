library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.components.all;

entity buffered_vga is
    port (
        clk: in std_logic;
        write_enable: in std_logic;
        write_addr: in natural range 0 to (80 * 60 - 1);
        data: in std_logic_vector(7 downto 0);
        frame_flip_strobe: out std_logic;
        h_sync: out std_logic;
        v_sync: out std_logic;
        screen_bit: out std_logic
    );
end entity buffered_vga;

architecture behav of buffered_vga is
    constant BUF_SIZE: natural := 80 * 60;

    signal output_buf_a: std_logic := '0';
    signal buf_a_we: std_logic := '1';
    signal buf_b_we: std_logic := '0';
    signal buf_a_out: std_logic_vector(7 downto 0);
    signal buf_b_out: std_logic_vector(7 downto 0);

    signal buf_read_addr: natural range 0 to BUF_SIZE - 1;

    constant H_VIDEO_LEN: integer := 640;
    constant V_VIDEO_LEN: integer := 480;

    constant H_COUNTER_MAX: integer := 800 - 1;
    constant V_COUNTER_MAX: integer := 524 - 1;

    constant H_FP_LEN: integer := 16;
    constant V_FP_LEN: integer := 11;

    constant H_SYNC_START: integer := H_VIDEO_LEN + H_FP_LEN;
    constant V_SYNC_START: integer := V_VIDEO_LEN + V_FP_LEN;

    constant H_SYNC_LEN: integer := 96;
    constant V_SYNC_LEN: integer := 2;

    signal h_counter: integer range 0 to H_COUNTER_MAX;
    signal v_counter: integer range 0 to V_COUNTER_MAX;
begin
    -- if output buf is b, writes should go to a and vice versa
    buf_a_we <= write_enable and not(output_buf_a);
    buf_b_we <= write_enable and output_buf_a;

    buf_a: ram
    generic map (
        ITEM_WIDTH => 8,
        SIZE => BUF_SIZE
    )
    port map (
        clk => clk,
        write_enable => buf_a_we,
        write_addr => write_addr,
        read_addr => buf_read_addr,
        in_data => data,
        out_data => buf_a_out
    );
    
    buf_b: ram
    generic map (
        ITEM_WIDTH => 8,
        SIZE => BUF_SIZE
    )
    port map (
        clk => clk,
        write_enable => buf_b_we,
        write_addr => write_addr,
        read_addr => buf_read_addr,
        in_data => data,
        out_data => buf_b_out
    );

    counters: process(clk)
    begin
        if rising_edge(clk) then
            if h_counter = H_COUNTER_MAX then
                h_counter <= 0;
                if v_counter = V_COUNTER_MAX then
                    v_counter <= 0;
                else
                    v_counter <= v_counter + 1;
                end if;
            else
                h_counter <= h_counter + 1;
            end if;
        end if;
    end process counters;

    h_sync <= '1' when (h_counter >= H_SYNC_START) and (h_counter < (H_SYNC_START + H_SYNC_LEN)) else '0';
    v_sync <= '1' when (v_counter >= V_SYNC_START) and (v_counter < (V_SYNC_START + V_SYNC_LEN)) else '0';

    -- TODO dual clock RAM so we can run the read to VGA from a separate
    -- pixel_clock and write the RAM from the main system clock

end architecture behav;