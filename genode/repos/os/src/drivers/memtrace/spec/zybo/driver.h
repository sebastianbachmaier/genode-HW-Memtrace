/*
 * \brief  MEMTRACE driver for the ZYBO
 * \author Sebastian Bachmaier <sebastian.bachmaier@tum.de>
 * \date   2018-12-03
 */

#ifndef _DRIVERS__MEMTRACE__SPEC__ZYBO__DRIVER_H_
#define _DRIVERS__MEMTRACE__SPEC__ZYBO__DRIVER_H_


#include <drivers/board_base.h>
#include <memtrace/driver.h>
#include <irq_session/connection.h>
#include <timer_session/connection.h>


#include "memtrace.h"

enum {
	NOP = 0x00,
	GET = 0x01,
	SET = 0x02,
	DIRTY = 0x03,
	ENABLECOPY = 0x04,
	DISABLECOPY = 0x05,
	PAUSECOPY = 0x06,
	UNPAUSECOPY = 0x07,
	PAUSETRACE = 0x08,
	UNPAUSETRACE = 0x09,
	STATUS_FOUND = 0x200,
	STATUS_NOTFOUND = 0x404
};

class Zybo_driver : public Memtrace::Driver
{
	private:

		Server::Entrypoint &_ep;
		FPGA_CONTR_REG _fpga_contr;

		Zybo_driver(Server::Entrypoint &ep)
		:
			_ep(ep),
			_fpga_contr(Genode::Board_base::MEMTRACE_BASE, Genode::Board_base::MEMTRACE_SIZE)
		{ }

	public:

		static Zybo_driver& factory(Server::Entrypoint &ep);


		/******************************
		 **  MEMTRACE::Driver interface  **
		 ******************************/

		void set_translation(
			Genode::addr_t origin,
			Genode::addr_t copy,
			unsigned size
		) {
			_fpga_contr.write<FPGA_CONTR_REG::Op>(NOP);
			_fpga_contr.write<FPGA_CONTR_REG::Origin>(origin);
			_fpga_contr.write<FPGA_CONTR_REG::Copy>(copy);
			_fpga_contr.write<FPGA_CONTR_REG::Size>(size);
			_fpga_contr.write<FPGA_CONTR_REG::Op>(SET);
			_fpga_contr.write<FPGA_CONTR_REG::Op>(NOP);
		}


		Genode::addr_t get_translation(
			Genode::addr_t origin
		) {
			_fpga_contr.write<FPGA_CONTR_REG::Op>(NOP);
			_fpga_contr.write<FPGA_CONTR_REG::Origin>(origin);
			_fpga_contr.write<FPGA_CONTR_REG::Op>(GET);
			_fpga_contr.write<FPGA_CONTR_REG::Op>(NOP);
			return (Genode::addr_t) _fpga_contr.read<FPGA_CONTR_REG::Copy>();
		}

		Genode::addr_t get_modified_page() {
			_fpga_contr.write<FPGA_CONTR_REG::Op>(NOP);
			_fpga_contr.write<FPGA_CONTR_REG::Op>(DIRTY);
			_fpga_contr.write<FPGA_CONTR_REG::Op>(NOP);
			return (Genode::addr_t) _fpga_contr.read<FPGA_CONTR_REG::Dirty>();
		}

		void copying_enabled(bool enabled) {
			if(enabled) {
				_fpga_contr.write<FPGA_CONTR_REG::Op>(NOP);
				_fpga_contr.write<FPGA_CONTR_REG::Op>(ENABLECOPY);
				_fpga_contr.write<FPGA_CONTR_REG::Op>(NOP);
			}else {
				_fpga_contr.write<FPGA_CONTR_REG::Op>(NOP);
				_fpga_contr.write<FPGA_CONTR_REG::Op>(DISABLECOPY);
				_fpga_contr.write<FPGA_CONTR_REG::Op>(NOP);
			}	
		}


		void pause_copying(bool pause) {
			if(pause) {
				_fpga_contr.write<FPGA_CONTR_REG::Op>(NOP);
				_fpga_contr.write<FPGA_CONTR_REG::Op>(PAUSECOPY);
				_fpga_contr.write<FPGA_CONTR_REG::Op>(NOP);
			}else {
				_fpga_contr.write<FPGA_CONTR_REG::Op>(NOP);
				_fpga_contr.write<FPGA_CONTR_REG::Op>(UNPAUSECOPY);
				_fpga_contr.write<FPGA_CONTR_REG::Op>(NOP);
			}	
		}

		void pause_tracing(bool pause) {
			if(pause) {
				_fpga_contr.write<FPGA_CONTR_REG::Op>(NOP);
				_fpga_contr.write<FPGA_CONTR_REG::Op>(PAUSETRACE);
				_fpga_contr.write<FPGA_CONTR_REG::Op>(NOP);
			}else {
				_fpga_contr.write<FPGA_CONTR_REG::Op>(NOP);
				_fpga_contr.write<FPGA_CONTR_REG::Op>(UNPAUSETRACE);
				_fpga_contr.write<FPGA_CONTR_REG::Op>(NOP);
			}	
		}

		unsigned get_status() {
			return (unsigned) _fpga_contr.read<FPGA_CONTR_REG::Status>();
		}


		Genode::addr_t get_pages_map(unsigned i) {
			switch(i) {
				case 1: (Genode::addr_t) _fpga_contr.read<FPGA_CONTR_REG::Page1>(); break;
				case 2: (Genode::addr_t) _fpga_contr.read<FPGA_CONTR_REG::Page2>(); break;
				case 3: (Genode::addr_t) _fpga_contr.read<FPGA_CONTR_REG::Page3>(); break;
				case 4: (Genode::addr_t) _fpga_contr.read<FPGA_CONTR_REG::Page4>(); break;
				case 5: (Genode::addr_t) _fpga_contr.read<FPGA_CONTR_REG::Page5>(); break;
				case 6: (Genode::addr_t) _fpga_contr.read<FPGA_CONTR_REG::Page6>(); break;
				case 7: (Genode::addr_t) _fpga_contr.read<FPGA_CONTR_REG::Page7>(); break;
				case 8: (Genode::addr_t) _fpga_contr.read<FPGA_CONTR_REG::Page8>(); break;
				case 9: (Genode::addr_t) _fpga_contr.read<FPGA_CONTR_REG::Page9>(); break;
				case 10: (Genode::addr_t) _fpga_contr.read<FPGA_CONTR_REG::Page10>(); break;
				case 11: (Genode::addr_t) _fpga_contr.read<FPGA_CONTR_REG::Page11>(); break;
				case 12: (Genode::addr_t) _fpga_contr.read<FPGA_CONTR_REG::Page12>(); break;
				case 13: (Genode::addr_t) _fpga_contr.read<FPGA_CONTR_REG::Page13>(); break;
				case 14: (Genode::addr_t) _fpga_contr.read<FPGA_CONTR_REG::Page14>(); break;
				case 15: (Genode::addr_t) _fpga_contr.read<FPGA_CONTR_REG::Page15>(); break;
				case 16: (Genode::addr_t) _fpga_contr.read<FPGA_CONTR_REG::Page16>(); break;
				default: (Genode::addr_t) _fpga_contr.read<FPGA_CONTR_REG::Page1>(); break;
			}
			return (Genode::addr_t) _fpga_contr.read<FPGA_CONTR_REG::Page1>();
		}

};


Zybo_driver& Zybo_driver::factory(Server::Entrypoint &ep)
{
	static Zybo_driver driver(ep);
	return driver;
}

#endif /* _DRIVERS__MEMTRACE__SPEC__ZYBO__DRIVER_H_ */
