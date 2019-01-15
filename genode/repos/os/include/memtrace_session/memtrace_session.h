/*
 * \brief  Memtrace session interface
 * \author Sebastian Bachmaier <sebastian.bachmaier@tum.de>
 * \date   2018-12-03
 */

#ifndef _INCLUDE__MEMTRACE_SESSION__GPIO_SESSION_H_
#define _INCLUDE__MEMTRACE_SESSION__GPIO_SESSION_H_

#include <base/signal.h>
#include <dataspace/capability.h>
#include <session/session.h>

namespace Memtrace { struct Session; }


struct Memtrace::Session : Genode::Session
{
	static const char *service_name() { return "Memtrace"; }

	virtual ~Session() { }

	virtual void set_translation(
		Genode::addr_t origin,
		Genode::addr_t copy,
		unsigned size
	) = 0;


	virtual Genode::addr_t get_translation(
		Genode::addr_t origin
	) = 0;

	virtual Genode::addr_t get_modified_page() = 0;

	virtual void copying_enabled(
		bool enabled
	)  = 0;

	virtual void pause_copying(
		bool pause
	)  = 0;

	virtual void pause_tracing(
		bool pause
	)  = 0;

	virtual Genode::addr_t get_pages_map(
		unsigned i
	)  = 0;

	virtual unsigned get_status(
	)  = 0;

	/*******************
	 ** RPC interface **
	 *******************/
	GENODE_RPC(
		Rpc_set_translation,
		void, 
		set_translation, 
		Genode::addr_t, Genode::addr_t, unsigned
	);

	GENODE_RPC(
		Rpc_get_translation,
		Genode::addr_t, 
		get_translation, 
		Genode::addr_t
	);

	GENODE_RPC(
		Rpc_get_modified_page,
		Genode::addr_t, 
		get_modified_page
	);

	GENODE_RPC(
		Rpc_copying_enabled,
		void, 
		copying_enabled,
		bool
	);

	GENODE_RPC(
		Rpc_pause_copying,
		void, 
		pause_copying,
		bool
	);

	GENODE_RPC(
		Rpc_pause_tracing,
		void, 
		pause_tracing,
		bool
	);

	GENODE_RPC(
		Rpc_get_pages_map,
		Genode::addr_t, 
		get_pages_map,
		unsigned
	);

	GENODE_RPC(
		Rpc_get_status,
		unsigned, 
		get_status
	);

	GENODE_RPC_INTERFACE(
		Rpc_set_translation,
		Rpc_get_translation,
		Rpc_get_modified_page,
		Rpc_copying_enabled,
		Rpc_pause_copying,
		Rpc_pause_tracing,
		Rpc_get_pages_map,
		Rpc_get_status
	);
};

#endif /* _INCLUDE__MEMTRACE_SESSION__GPIO_SESSION_H_ */
