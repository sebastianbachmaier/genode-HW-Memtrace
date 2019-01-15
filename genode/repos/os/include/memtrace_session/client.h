/*
 * \brief  Client-side Memtrace session interface
 * \author Sebastian Bachmaier <sebastian.bachmaier@tum.de>
 * \date   2018-12-03
 */

#ifndef _INCLUDE__MEMTRACE_SESSION_H__CLIENT_H_
#define _INCLUDE__MEMTRACE_SESSION_H__CLIENT_H_

#include <memtrace_session/capability.h>
#include <base/rpc_client.h>

namespace Memtrace { struct Session_client; }


struct Memtrace::Session_client : Genode::Rpc_client<Session>
{
	explicit Session_client(Session_capability session) : Genode::Rpc_client<Session>(session) { }

	void set_translation(
		Genode::addr_t origin,
		Genode::addr_t copy,
		unsigned size
	) override { call<Rpc_set_translation>(origin, copy, size); }
	
	Genode::addr_t get_translation(
		Genode::addr_t origin
	) override { return call<Rpc_get_translation>(origin); }
	Genode::addr_t get_modified_page(
	)  override { return call<Rpc_get_modified_page>(); }


	void copying_enabled(
		bool enabled
	) override { call<Rpc_copying_enabled>(enabled); }

	void pause_copying(
		bool pause
	) override { call<Rpc_pause_copying>(pause); }

	void pause_tracing(
		bool pause
	) override { call<Rpc_pause_tracing>(pause); }

	Genode::addr_t get_pages_map(
		unsigned i
	) override { return call<Rpc_get_pages_map>(i); }

	unsigned get_status (
	) override { return call<Rpc_get_status>(); }

};

#endif /* _INCLUDE__MEMTRACE_SESSION_H__CLIENT_H_ */
