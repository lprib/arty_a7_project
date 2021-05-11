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

    constant H_VIDEO_LEN: natural := 640;
    constant V_VIDEO_LEN: natural := 480;

    constant H_COUNTER_MAX: natural := 800 - 1;
    constant V_COUNTER_MAX: natural := 524 - 1;

    constant H_FP_LEN: natural := 16;
    constant V_FP_LEN: natural := 11;

    constant H_SYNC_START: natural := H_VIDEO_LEN + H_FP_LEN;
    constant V_SYNC_START: natural := V_VIDEO_LEN + V_FP_LEN;

    constant H_SYNC_LEN: natural := 97;
    constant V_SYNC_LEN: natural := 2;

    -- 150Mhz -> 25Mhz
    constant PIXEL_CLK_DIV_AMOUNT: natural := 6;

    signal pixel_clk: std_logic;
    signal h_counter: natural range 0 to H_COUNTER_MAX := 0;
    signal v_counter: natural range 0 to V_COUNTER_MAX := 0;

    -- should buffer A be written to screen (else buffer B)
    signal screen_buf_a: std_logic := '0';
    signal buf_a_we: std_logic;
    signal buf_b_we: std_logic;

    signal buf_a_out: std_logic_vector(7 downto 0);
    signal buf_b_out: std_logic_vector(7 downto 0);

    signal buf_read_addr: natural range 0 to BUF_SIZE - 1;

    -- Gets assigned to buf_a_out or buf_b_out depending on which is the screen buffer
    signal screen_buffer_out: std_logic_vector(7 downto 0);

    -- 3 byte number for indexing into screen_buffer_out
    signal subbyte_index: unsigned(2 downto 0) := "000";
begin

    pixel_clock_div: pulse_clock_div
    generic map (
        divisor => PIXEL_CLK_DIV_AMOUNT
    )
    port map (
        clk => clk,
        div => pixel_clk
    );

    -- if output buf is b, writes should go to a and vice versa
    buf_a_we <= write_enable and not(screen_buf_a);
    buf_b_we <= write_enable and screen_buf_a;

    screen_buffer_out <= buf_a_out when screen_buf_a = '1' else buf_b_out;

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
        if rising_edge(clk) and pixel_clk = '1' then
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

    data_out: process(clk)
    begin
        if
            rising_edge(clk) and
            pixel_clk = '1' and
            h_counter < H_VIDEO_LEN and
            v_counter < V_VIDEO_LEN
        then
            screen_bit <= screen_buffer_out(to_integer(subbyte_index));
            subbyte_index <= subbyte_index + 1;
            if subbyte_index = "111" then
                -- When we reach the end of a byte, change the read address
                if buf_read_addr = BUF_SIZE - 1 then
                    buf_read_addr <= 0;
                else
                    buf_read_addr <= buf_read_addr + 1;
                end if;
            end if;
        end if;
    end process data_out;

    h_sync <= '1' when (h_counter >= H_SYNC_START) and (h_counter < (H_SYNC_START + H_SYNC_LEN)) else '0';
    v_sync <= '1' when (v_counter >= V_SYNC_START) and (v_counter < (V_SYNC_START + V_SYNC_LEN)) else '0';

end architecture behav;
