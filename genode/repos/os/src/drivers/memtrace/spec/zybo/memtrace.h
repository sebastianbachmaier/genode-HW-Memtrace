/*
 * \brief  Zybo Memtrace definitions
 * \author Sebastian Bachmaier <sebastian.bachmaier@tum.de>
 * \date   2018-12-03
 */

#ifndef _DRIVERS__MEMTRACE__SPEC__ZYBO__MEMTRACE_H_
#define _DRIVERS__MEMTRACE__SPEC__ZYBO__MEMTRACE_H_

#include <os/attached_io_mem_dataspace.h>
#include <util/mmio.h>


struct FPGA_CONTR_REG : Genode::Attached_io_mem_dataspace, Genode::Mmio
{
	FPGA_CONTR_REG(Genode::addr_t const mmio_base, Genode::size_t const mmio_size)
	: Genode::Attached_io_mem_dataspace(mmio_base, mmio_size), Genode::Mmio((Genode::addr_t)local_addr<void>()) { }

	struct Op 	: Register<0x00, 32> {};
	struct Status		: Register<0x04, 32> {};
	struct Origin		: Register<0x08, 32> {};
	struct Copy 	: Register<0x0C, 32> {};
	struct Size		: Register<0x10, 32> {};
	struct Dirty 	: Register<0x14, 32> {};

	struct Page1 	: Register<0x20, 32> {};
	struct Page2 	: Register<0x24, 32> {};
	struct Page3 	: Register<0x28, 32> {};
	struct Page4 	: Register<0x2C, 32> {};
	struct Page5 	: Register<0x30, 32> {};
	struct Page6 	: Register<0x34, 32> {};
	struct Page7 	: Register<0x38, 32> {};
	struct Page8 	: Register<0x3C, 32> {};
	struct Page9 	: Register<0x40, 32> {};
	struct Page10 	: Register<0x44, 32> {};
	struct Page11 	: Register<0x48, 32> {};
	struct Page12 	: Register<0x4C, 32> {};
	struct Page13 	: Register<0x50, 32> {};
	struct Page14 	: Register<0x54, 32> {};
	struct Page15 	: Register<0x58, 32> {};
	struct Page16 	: Register<0x5C, 32> {};
};

#endif /* _DRIVERS__MEMTRACE__SPEC__ZYBO__MEMTRACE_H_*/
