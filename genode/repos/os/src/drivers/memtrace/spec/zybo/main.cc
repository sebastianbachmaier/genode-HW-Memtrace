/*
 * \brief  Memtrace driver for the Zybo
 * \author Sebastian Bachmaier <sebastian.bachmaier@tum.de>
 * \date   2018-12-03
 */

/* Genode includes */
#include <base/log.h>
#include <base/heap.h>
#include <base/sleep.h>
#include <cap_session/connection.h>
#include <memtrace/component.h>
#include <os/server.h>

#include <driver.h>


struct Main
{
	Server::Entrypoint  &ep;
	Genode::Sliced_heap  sliced_heap;
	Zybo_driver        &driver;
	Memtrace::Root           root;

	Main(Server::Entrypoint &ep)
	:
		ep(ep),
		sliced_heap(Genode::env()->ram_session(), Genode::env()->rm_session()),
		driver(Zybo_driver::factory(ep)),
		root(&ep.rpc_ep(), &sliced_heap, driver)
	{
		using namespace Genode;

		log("memtrace driver", Genode::env()->ram_session()->quota());

		/*
		 * Announce service
		 */
		env()->parent()->announce(ep.manage(root));
	}
};

/************
 ** Server **
 ************/

namespace Server {
	char const *name()             { return "memtrace_drv_ep";     }
	size_t stack_size()            { return 1024*sizeof(long); }
	void construct(Entrypoint &ep) { static Main server(ep);   }
}
