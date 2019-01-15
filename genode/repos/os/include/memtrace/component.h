/*
 * \brief  Memtrace-session component
 * \author Sebastian Bachmaier <sebastian.bachmaier@tum.de>
 * \date   2018-12-03
 */

#ifndef _INCLUDE__MEMTRACE__COMPONENT_H_
#define _INCLUDE__MEMTRACE__COMPONENT_H_

#include <base/printf.h>
#include <root/component.h>
#include <memtrace_session/memtrace_session.h>
#include <memtrace/driver.h>

namespace Memtrace {
	class Session_component;
	class Root;
};


class Memtrace::Session_component : public Genode::Rpc_object<Memtrace::Session>
{
	private:
		Genode::Rpc_entrypoint &_ep;
		Driver                 &_driver;


	public:

		Session_component(Genode::Rpc_entrypoint &ep,
		                  Driver                 &driver)
		: _ep(ep), _driver(driver) { }

		~Session_component() { }


		/*****************************
		 ** Memtrace::Session interface **
		 *****************************/
		void set_translation(
			Genode::addr_t origin,
			Genode::addr_t copy,
			unsigned size
		) { _driver.set_translation(origin, copy, size); }


		Genode::addr_t get_translation(
			Genode::addr_t origin
		) { return _driver.get_translation(origin); }

		Genode::addr_t get_modified_page()
		{ return _driver.get_modified_page();  }


		void copying_enabled(bool enabled)
		{ return _driver.pause_copying(enabled);  }

		void pause_copying(bool pause)
		{ return _driver.pause_copying(pause);  }

		void pause_tracing(bool pause)
		{ return _driver.pause_tracing(pause);  }

		Genode::addr_t get_pages_map(unsigned i)
		{ return _driver.get_pages_map(i); }

		unsigned get_status()
		{ return _driver.get_status(); }
};


class Memtrace::Root : public Genode::Root_component<Memtrace::Session_component>
{
	private:

		Genode::Rpc_entrypoint &_ep;
		Driver                 &_driver;

	protected:

		Session_component *_create_session(const char *args)
		{
			Genode::size_t ram_quota  = Genode::Arg_string::find_arg(args, "ram_quota").ulong_value(0);

			if (ram_quota < sizeof(Session_component)) {
				PWRN("Insufficient donated ram_quota (%zd bytes), require %zd bytes",
					 ram_quota, sizeof(Session_component));
				throw Genode::Root::Quota_exceeded();
			}

			return new (md_alloc()) Session_component(_ep, _driver);
		}

	public:

		Root(Genode::Rpc_entrypoint *session_ep, Genode::Allocator *md_alloc, Driver &driver)
		: Genode::Root_component<Memtrace::Session_component>(session_ep, md_alloc),
		_ep(*session_ep), _driver(driver) { }
};


#endif /* _INCLUDE__MEMTRACE__COMPONENT_H_ */
