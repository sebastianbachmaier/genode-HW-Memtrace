/*
 * \brief  Cortex-MEMTRACE session capability type
 * \author Sebastian Bachmaier <sebastian.bachmaier@tum.de>
 * \date   2018-12-03
 */

#ifndef _INCLUDE__MEMTRACE_SESSION__CAPABILITY_H_
#define _INCLUDE__MEMTRACE_SESSION__CAPABILITY_H_

#include <base/capability.h>
#include <memtrace_session/memtrace_session.h>

namespace Memtrace { 
	typedef Genode::Capability<Session> Session_capability;
}

#endif /* _INCLUDE__MEMTRACE_SESSION__CAPABILITY_H_ */
