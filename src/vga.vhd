library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.components.all;

entity vga is
    port (
        clk: in std_logic;
        hsync_out: out std_logic;
        vsync_out: out std_logic;
        r_out: out std_logic_vector(3 downto 0);
        g_out: out std_logic_vector(3 downto 0);
        b_out: out std_logic_vector(3 downto 0)
    );
end entity;

architecture behav of vga is
    constant FRAME_WIDTH: natural := 640;
    constant FRAME_HEIGHT: natural := 480;

    constant H_PORCH_W: natural := 16;
    constant H_SYNC_W: natural := 96;
    constant H_PERIOD: natural := 800;
    constant H_SYNC_POLARITY: std_logic := '0';

    constant V_PORCH_W: natural := 10;
    constant V_SYNC_W: natural := 2;
    constant V_PERIOD: natural := 525;
    constant V_SYNC_POLARITY: std_logic := '0';

    constant BOX_WIDTH: natural := 8;
    constant BOX_CLK_DIV: natural := 1_000_000;

    constant BOX_X_MAX: natural := 512 - BOX_WIDTH;
    constant BOX_Y_MAX: natural := FRAME_HEIGHT - BOX_WIDTH;
    constant BOX_X_MIN: natural := 0;
    constant BOX_Y_MIN: natural := 256;

    constant BOX_X_INIT: unsigned(11 downto 0) := x"000";
    constant BOX_Y_INIT: unsigned(11 downto 0) := x"190";

    signal pixel_clk: std_logic;
    signal active: std_logic;

    signal h_counter_reg: unsigned(11 downto 0) := (others => '0');
    signal v_counter_reg: unsigned(11 downto 0) := (others => '0');

    signal h_sync_reg: std_logic := not(H_SYNC_POLARITY);
    signal v_sync_reg: std_logic := not(V_SYNC_POLARITY);
    signal h_sync_delay_reg: std_logic := not(H_SYNC_POLARITY);
    signal v_sync_delay_reg: std_logic := not(V_SYNC_POLARITY);

    signal r_reg: std_logic_vector(3 downto 0) := (others => '0');
    signal g_reg: std_logic_vector(3 downto 0) := (others => '0');
    signal b_reg: std_logic_vector(3 downto 0) := (others => '0');

    signal r: std_logic_vector(3 downto 0) := (others => '0');
    signal g: std_logic_vector(3 downto 0) := (others => '0');
    signal b: std_logic_vector(3 downto 0) := (others => '0');

    signal box_x_reg: unsigned(11 downto 0) := BOX_X_INIT;
    signal box_y_reg: unsigned(11 downto 0) := BOX_Y_INIT;
    signal box_x_dir: std_logic := '1';
    signal box_y_dir: std_logic := '1';

    signal box_counter_reg: unsigned(24 downto 0) := (others => '0');

    signal update_box: std_logic;
    signal pixel_in_box: std_logic;

begin

    div: clock_div
    generic map (
        divisor => 4
    )
    port map (
        clk => clk,
        div => pixel_clk
    );
    r <= 
        std_logic_vector(h_counter_reg(5 downto 2))   when (active = '1' and ((h_counter_reg < to_unsigned(512, 12) and v_counter_reg < to_unsigned(256, 12)) and h_counter_reg(8) = '1')) else
        (others=>'1')               when (active = '1' and ((h_counter_reg < to_unsigned(512, 12) and not(v_counter_reg < to_unsigned(256, 12))) and not(pixel_in_box = '1'))) else
        (others=>'1')               when (active = '1' and ((not(h_counter_reg < 512) and (v_counter_reg(8) = '1' and h_counter_reg(3) = '1')) or
                                    (not(h_counter_reg < to_unsigned(512, 12)) and (v_counter_reg(8) = '0' and v_counter_reg(3) = '1')))) else
        (others=>'0');
              
    g <=
        std_logic_vector(h_counter_reg(5 downto 2))   when (active = '1' and ((h_counter_reg < to_unsigned(512, 12) and v_counter_reg < to_unsigned(256, 12)) and h_counter_reg(7) = '1')) else
        (others=>'1')               when (active = '1' and ((h_counter_reg < to_unsigned(512, 12) and not(v_counter_reg < to_unsigned(256, 12))) and not(pixel_in_box = '1'))) else 
        (others=>'1')               when (active = '1' and ((not(h_counter_reg < to_unsigned(512, 12)) and (v_counter_reg(8) = '1' and h_counter_reg(3) = '1')) or
                                    (not(h_counter_reg < to_unsigned(512, 12)) and (v_counter_reg(8) = '0' and v_counter_reg(3) = '1')))) else
        (others=>'0');

    b <=
        std_logic_vector(h_counter_reg(5 downto 2))   when (active = '1' and ((h_counter_reg < to_unsigned(512, 12) and v_counter_reg < to_unsigned(256, 12)) and  h_counter_reg(6) = '1')) else
        (others=>'1')               when (active = '1' and ((h_counter_reg < to_unsigned(512, 12) and not(v_counter_reg < to_unsigned(256, 12))) and not(pixel_in_box = '1'))) else 
        (others=>'1')               when (active = '1' and ((not(h_counter_reg < to_unsigned(512, 12)) and (v_counter_reg(8) = '1' and h_counter_reg(3) = '1')) or
                                    (not(h_counter_reg < to_unsigned(512, 12)) and (v_counter_reg(8) = '0' and v_counter_reg(3) = '1')))) else
        (others=>'0');  

  process (pixel_clk)
  begin
    if (rising_edge(pixel_clk)) then
      if (update_box = '1') then
        if (box_x_dir = '1') then
          box_x_reg <= box_x_reg + 1;
        else
          box_x_reg <= box_x_reg - 1;
        end if;
        if (box_y_dir = '1') then
          box_y_reg <= box_y_reg + 1;
        else
          box_y_reg <= box_y_reg - 1;
        end if;
      end if;
    end if;
  end process;
      
  process (pixel_clk)
  begin
    if (rising_edge(pixel_clk)) then
      if (update_box = '1') then
        if ((box_x_dir = '1' and (box_x_reg = BOX_X_MAX - 1)) or (box_x_dir = '0' and (box_x_reg = BOX_X_MIN + 1))) then
          box_x_dir <= not(box_x_dir);
        end if;
        if ((box_y_dir = '1' and (box_y_reg = BOX_Y_MAX - 1)) or (box_y_dir = '0' and (box_y_reg = BOX_Y_MIN + 1))) then
          box_y_dir <= not(box_y_dir);
        end if;
      end if;
    end if;
  end process;
  
  process (pixel_clk)
  begin
    if (rising_edge(pixel_clk)) then
      if (box_counter_reg = (BOX_CLK_DIV - 1)) then
        box_counter_reg <= (others=>'0');
      else
        box_counter_reg <= box_counter_reg + 1;     
      end if;
    end if;
  end process;
  
  update_box <= '1' when box_counter_reg = (BOX_CLK_DIV - 1) else
                '0';
                
  pixel_in_box <= '1' when (((h_counter_reg >= box_x_reg) and (h_counter_reg < (box_x_reg + BOX_WIDTH))) and
                            ((v_counter_reg >= box_y_reg) and (v_counter_reg < (box_y_reg + BOX_WIDTH)))) else
                  '0';
                
  
 ------------------------------------------------------
 -------         SYNC GENERATION                 ------
 ------------------------------------------------------
 
  process (pixel_clk)
  begin
    if (rising_edge(pixel_clk)) then
      if (h_counter_reg = (H_PERIOD - 1)) then
        h_counter_reg <= (others =>'0');
      else
        h_counter_reg <= h_counter_reg + 1;
      end if;
    end if;
  end process;
  
  process (pixel_clk)
  begin
    if (rising_edge(pixel_clk)) then
      if ((h_counter_reg = (H_PERIOD - 1)) and (v_counter_reg = (V_PERIOD - 1))) then
        v_counter_reg <= (others =>'0');
      elsif (h_counter_reg = (H_PERIOD - 1)) then
        v_counter_reg <= v_counter_reg + 1;
      end if;
    end if;
  end process;
  
  process (pixel_clk)
  begin
    if (rising_edge(pixel_clk)) then
      if (h_counter_reg >= (H_PORCH_W + FRAME_WIDTH - 1)) and (h_counter_reg < (H_PORCH_W + FRAME_WIDTH + H_SYNC_W - 1)) then
        h_sync_reg <= H_SYNC_POLARITY;
      else
        h_sync_reg <= not(H_SYNC_POLARITY);
      end if;
    end if;
  end process;
  
  
  process (pixel_clk)
  begin
    if (rising_edge(pixel_clk)) then
      if (v_counter_reg >= (V_PORCH_W + FRAME_HEIGHT - 1)) and (v_counter_reg < (V_PORCH_W + FRAME_HEIGHT + V_SYNC_W - 1)) then
        v_sync_reg <= V_SYNC_POLARITY;
      else
        v_sync_reg <= not(V_SYNC_POLARITY);
      end if;
    end if;
  end process;
  
  
  active <= '1' when ((h_counter_reg < FRAME_WIDTH) and (v_counter_reg < FRAME_HEIGHT))else
            '0';

  process (pixel_clk)
  begin
    if (rising_edge(pixel_clk)) then
      v_sync_delay_reg <= v_sync_reg;
      h_sync_delay_reg <= h_sync_reg;
      r_reg <= r;
      g_reg <= g;
      b_reg <= b;
    end if;
  end process;

  hsync_out <= h_sync_delay_reg;
  vsync_out <= v_sync_delay_reg;
  r_out <= r_reg;
  g_out <= g_reg;
  b_out <= b_reg;
end architecture;