library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm is
    port (
        clk: in std_logic;
        duty: in unsigned(10 downto 0);
        pwm_out: out std_logic
    );
end entity;

architecture behav of pwm is
    signal timer: unsigned(10 downto 0) := to_unsigned(0, 11);
    signal tri_duty: unsigned(10 downto 0);
begin
    tri_duty <= duty when duty < to_unsigned(512, 11) else to_unsigned(1024, 11) - duty;

    process(clk) is begin
        if rising_edge(clk) then
            timer <= timer + 1;
            if timer = to_unsigned(0, 11) then
                pwm_out <= '1';
            end if;
            if timer = tri_duty then
                pwm_out <= '0';
            end if;
        end if;
    end process;
end architecture behav;
