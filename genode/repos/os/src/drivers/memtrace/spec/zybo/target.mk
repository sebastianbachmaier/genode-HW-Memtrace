TARGET   = memtrace_drv
REQUIRES = zybo
SRC_CC   = main.cc
LIBS     = base config server
INC_DIR += $(PRG_DIR)

vpath main.cc $(PRG_DIR)

