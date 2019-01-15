#include <base/component.h>
#include <timer_session/connection.h>
#include <base/log.h>
#include <rm_session/connection.h>
#include <region_map/client.h>
#include <base/printf.h>
#include <dataspace/client.h>
#include <base/sleep.h>
#include <memtrace_session/connection.h>
#include <util/profiler.h>

namespace Fiasco {
#include <l4/sys/kdebug.h>
}
/** select the test heere **/
#define TEST 4
#define ISAXI 1

using namespace Genode;

Genode::size_t Component::stack_size() { return 16*1024; }



void show_page(Memtrace::Connection& mem) {

	addr_t page = mem.get_modified_page();
	unsigned status = mem.get_status();
	
	printf("(Page|Status): %08lX : %08lX\n", page, status);

}


void dump_mem(Genode::addr_t addr, size_t size) {
	size = size / 16;
	volatile int* p = (int *) addr;
	
	printf("Show memory at %p \n",p);
	for (int i = 0; i < size; ++i)
	{
		printf("%08X: ",p+(i*4));
		for (int j = 0; j < 4; ++j)
		{
				printf("%08X ",p[i*4+j]);
		}
		printf("\n");
	}
	printf("\n");
}

void profile_dataspace_4KiB_repeating(addr_t& addr) {

	int* array = (int*) addr;
	for (int j = 0; j < 1000; ++j)
	{
		for (int i = 0; i < 4096; ++i)
		{
			array[i] = i*j;
		}
	}
	Genode::log("Done Profiling");
}

void profile_dataspace_16MiB_single(addr_t& addr) {

	int* array = (int*) addr;

	for (int i = 0; i < 1000*4096; ++i)
	{
		array[i] = i;
	}
	
	Genode::log("Done Profiling");
}

void Component::construct(Genode::Env &env)
{
	//enter_kdebug("before restore");
	using namespace Genode;
	log("Genode FPGA Controller");

	Timer::Connection timer;

	#if TEST == 1
		/** DIABLE CACHE TEST - with performance measurements **/
		Dataspace_capability ds_caps[4] = {
			env.ram().alloc(4*4096),
			env.ram().alloc(4*4096, UNCACHED),
			env.ram().alloc(1000*sizeof(int)*4096),
			env.ram().alloc(1000*sizeof(int)*4096, UNCACHED),
		};
		addr_t addr[4] = {
			env.rm().attach(ds_caps[0]),
			env.rm().attach(ds_caps[1]),
			env.rm().attach(ds_caps[2]),
			env.rm().attach(ds_caps[3])
		};
		{
			PROFILE_SCOPE("4KiB_repeating cached", "red", timer)
			profile_dataspace_4KiB_repeating(addr[0]);
		}
		{
			PROFILE_SCOPE("4KiB_repeating uncached ", "green", timer)
			profile_dataspace_4KiB_repeating(addr[1]);
		}

		
		{
			PROFILE_SCOPE("16MiB_single cached", "red", timer)
			profile_dataspace_16MiB_single(addr[2]);
		}
		{
			PROFILE_SCOPE("16MiB_single uncached ", "green", timer)
			profile_dataspace_16MiB_single(addr[3]);
		}


		Genode::log("shutdown");

	#elif TEST == 2
		/** COPY TEST - width pause copy **/
		Dataspace_capability ds_caps[2] = {
			env.ram().alloc(4*4096, UNCACHED),
			env.ram().alloc(4*4096, UNCACHED),
		};
		addr_t addr[2] = {
			env.rm().attach(ds_caps[0]),
			env.rm().attach(ds_caps[1])
		};
		addr_t phys[2] = {
			Genode::Dataspace_client(ds_caps[0]).phys_addr(),
			Genode::Dataspace_client(ds_caps[1]).phys_addr()
		};
		unsigned* array[2] = {
			(unsigned*) addr[0],
			(unsigned*) addr[1]
		};

		Memtrace::Connection mem(env);
		/** two dataspaces have been allocated **/
		mem.set_translation(phys[0], phys[1], 4*4096);

		for (unsigned i = 0; i < 4; ++i)
			array[0][i] = 0x42 + i;

		mem.pause_copying(true);

		for (unsigned i = 4; i < 8; ++i)
			array[0][i] = 0x42 + i;

		dump_mem(addr[0], 32);
		dump_mem(addr[1], 32);

		mem.pause_copying(false);

		dump_mem(addr[0], 32);
		dump_mem(addr[1], 32);

	#elif TEST == 3
		 /** TRACING TEST - with simple copy**/
		addr_t addr[4];
		addr_t phys[4];
		Dataspace_capability ds_caps[4] = {
			env.ram().alloc(4*4096, UNCACHED),
			env.ram().alloc(4*4096, UNCACHED),
			env.ram().alloc(4*4096, UNCACHED),
			env.ram().alloc(4*4096, UNCACHED),
		};

		for(int i = 0; i < 4; i++) 
		{
			addr[i] = env.rm().attach(ds_caps[i]);
			phys[i] = Genode::Dataspace_client(ds_caps[i]).phys_addr();
			printf("physical address of ds_cap[%i] : %08lX\n", i, phys[i]);
			printf("stuff %08lX\n", Genode::Dataspace_client(env.rm().dataspace()).phys_addr());
		}

		Memtrace::Connection mem(env);
		/** map ds_cap[0] to ds_cap[1] and ds_cap[2] to ds_cap[3] **/
		mem.set_translation(phys[0], phys[1], 4*4096);
		mem.set_translation(phys[3], phys[2], 4*4096);

		//mem.copying_enabled(1);

		show_page(mem);

		printf("Now write ....\n");

		volatile int* array = (int*) addr[3];
		volatile int* copy = (int*) addr[2];
		

		for(int i = 0; i < 4096; i++)
		{
			array[i] = i;
		}
		
			
		for(int i = 0; i < 4; i++)
		{
			dump_mem(addr[i], 64);
		}
		

		for (int i = 0; i < 4; ++i)
		{
			phys[i] = Genode::Dataspace_client(ds_caps[i]).phys_addr();

			printf("physical address of ds_cap[%i] : %08lX\n", i, phys[i]);
		}

		printf("normal : %d\n", array[3]);
		printf("copy : %d\n", copy[3]);

		printf("translation was: %08lX\n", mem.get_translation(phys[3]+(sizeof(int)*3)));

		show_page(mem); 
	#elif TEST == 4
		/** compares native copying with cached and uncached dataspaces as well as an axi copied dataspace **/
		#define SIZE 1000*4*4096

		Dataspace_capability ds_caps[6] = {
			env.ram().alloc(SIZE),
			env.ram().alloc(SIZE),
			env.ram().alloc(SIZE, UNCACHED),
			env.ram().alloc(SIZE, UNCACHED),
			env.ram().alloc(SIZE, UNCACHED),
			env.ram().alloc(SIZE, UNCACHED)
		};
		addr_t addr[6] = {
			env.rm().attach(ds_caps[0]),
			env.rm().attach(ds_caps[1]),
			env.rm().attach(ds_caps[2]),
			env.rm().attach(ds_caps[3]),
			env.rm().attach(ds_caps[4]),
			env.rm().attach(ds_caps[5])
		};
		unsigned* array[6] = {
			(unsigned*) addr[0],
			(unsigned*) addr[1],
			(unsigned*) addr[2],
			(unsigned*) addr[3],
			(unsigned*) addr[4],
			(unsigned*) addr[5]
		};

		{
			PROFILE_SCOPE("writing_to_dataspace cached", "red", timer)
			for (int i = 0; i < (SIZE/4); ++i)
				array[0][i] = i;
		}
		{
			PROFILE_SCOPE("copying_to_dataspace cached", "red", timer)
			Genode::memcpy((char*)array[1], (char*)array[0], SIZE);
		}
		{
			PROFILE_SCOPE("writing_to_dataspace uncached", "green", timer)
			for (int i = 0; i < (SIZE/4); ++i)
				array[2][i] = i;
		}
		{
			PROFILE_SCOPE("copying_to_dataspace uncached", "green", timer)
			Genode::memcpy((char*)array[3], (char*)array[2], SIZE);
		}

		#if ISAXI == 1

			addr_t phys[2] = {
				Genode::Dataspace_client(ds_caps[4]).phys_addr(),
				Genode::Dataspace_client(ds_caps[5]).phys_addr()
			};

			Memtrace::Connection mem(env);
			/** two dataspaces have been allocated **/
			mem.set_translation(phys[0], phys[1], SIZE);
			{
				PROFILE_SCOPE("AXI_ENABLED: writing_to_dataspace incl. copy", "blue", timer)
				for (int i = 0; i < (SIZE/4); ++i)
					array[4][i] = i;
			}

		#endif

		
	#else
		Genode::log("No test specified");
	#endif

}

