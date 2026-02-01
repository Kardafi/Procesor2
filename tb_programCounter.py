import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


@cocotb.test()
async def tb_program_counter(dut):
    """Test podstawowy modułu programCounter"""

    # Parametry testu
    CLK_PERIOD = 10  # ns

    # Uruchom zegar
    cocotb.start_soon(Clock(dut.clk, CLK_PERIOD, units="ns").start())

    # Inicjalizacja
    dut.rtsPC.value = 0
    dut.cePC.value = 0
    dut.dataProgMem.value = 0

    # Reset
    dut.rtsPC.value = 1
    await RisingEdge(dut.clk)
    dut.rtsPC.value = 0

    # Sprawdź czy po resecie licznik = 0
    await RisingEdge(dut.clk)
    assert dut.dataProgMem.value == 0, f"Po resecie: {dut.dataProgMem.value} ≠ 0"

    # Włącz zliczanie
    dut.cePC.value = 1
    for i in range(5):
        await RisingEdge(dut.clk)
        expected = i + 1
        assert dut.dataProgMem.value == expected, \
            f"Po {i+1} cyklach: {dut.dataProgMem.value} ≠ {expected}"

    # Zatrzymaj zliczanie
    dut.cePC.value = 0
    current_val = int(dut.dataProgMem.value)
    for _ in range(3):
        await RisingEdge(dut.clk)
        assert dut.dataProgMem.value == current_val, \
            f"Licznik zmienił się mimo cePC=0: {dut.dataProgMem.value} ≠ {current_val}"

    # Reset w trakcie działania
    dut.rtsPC.value = 1
    await RisingEdge(dut.clk)
    dut.rtsPC.value = 0
    await RisingEdge(dut.clk)
    assert dut.dataProgMem.value == 0, "Licznik nie zresetował się po RTS"

    cocotb.log.info("✅ Test zakończony pomyślnie!")
