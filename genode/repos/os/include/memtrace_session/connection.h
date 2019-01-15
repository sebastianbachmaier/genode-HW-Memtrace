/*
 * \brief  Connection to Memtrace session
 * \author Sebastian Bachmaier <sebastian.bachmaier@tum.de>
 * \date   2018-12-03
 */

#ifndef _INCLUDE__MEMTRACE_SESSION__CONNECTION_H_
#define _INCLUDE__MEMTRACE_SESSION__CONNECTION_H_

#include <memtrace_session/client.h>
#include <base/connection.h>

namespace Memtrace { struct Connection; }

struct Memtrace::Connection : Genode::Connection<Session>, Session_client
{
	
	Connection(Genode::Env &env)
	:
		Genode::Connection<Session>(env, session(env.parent(), "ram_quota=10K")),
		Session_client(cap())
	{ }

	Connection()
	:
		Genode::Connection<Session>(session("ram_quota=10K")),
		Session_client(cap())
	{ }
};

#endif /* _INCLUDE__MEMTRACE_SESSION__CONNECTION_H_ */
