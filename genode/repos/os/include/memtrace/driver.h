/*
 * \brief  Memtrace driver interface
 * \author Sebastian Bachmaier <sebastian.bachmaier@tum.de>
 * \date   2018-12-03
 */

#ifndef _INCLUDE__MEMTRACE__DRIVER_H_
#define _INCLUDE__MEMTRACE__DRIVER_H_

/* Genode includes */
#include <base/signal.h>

namespace Memtrace { 
	struct Driver; 
	typedef Genode::addr_t Pages[64];
}


struct Memtrace::Driver
{

	virtual void set_translation(
		Genode::addr_t origin,
		Genode::addr_t copy,
		unsigned size
	) = 0;


	virtual Genode::addr_t get_translation(
		Genode::addr_t origin
	) = 0;

	virtual Genode::addr_t get_modified_page() = 0;

	virtual void copying_enabled(bool enabled) = 0;

	virtual void pause_copying(bool pause) = 0;

	virtual void pause_tracing(bool pause) = 0;

	virtual Genode::addr_t get_pages_map(unsigned i) = 0;

	virtual unsigned get_status() = 0;

};

#endif /* _INCLUDE__MEMTRACE__DRIVER_H_ */
