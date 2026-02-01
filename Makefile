TOPLEVEL_LANG = Verilog
VERILOG_SOURCES = /home/karol-nieroba/Desktop/Karol_Procesor/programCounter.v
TOPLEVEL = programCounter
MODULE = tb_programCounter

# Wybierz symulator (najprostszy do instalacji to Icarus Verilog)
SIM = Icarus


include $(shell cocotb-config --makefiles)/Makefile.sim