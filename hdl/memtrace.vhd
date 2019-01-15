library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity direct_mem_max_v1_0 is
	generic (
		-- Users to add parameters here
		FIFO_WIDTH : integer := 68;
		ADDR_WIDTH : integer := 32;

		FIFO_CAPACITY	: integer := 128;

		MAX_SIZE	: INTEGER := 64;
		MAX_SIZE_DIRTY : INTEGER := 128;
		KEY_WIDTH	: INTEGER := 32;
		VALUE_WIDTH	: INTEGER := 32;

		PAGE_OFFSET : INTEGER := 12;
		MEMORY_ADDR_BITS : INTEGER := 29;
 

		STATUS_FOUND : std_logic_vector := x"00000200";
		STATUS_NOTFOUND : std_logic_vector := x"00000404";

		API_READ : std_logic_vector := x"00000001";
		API_WRITE : std_logic_vector := x"00000002";
		API_GETPAGE :std_logic_vector := x"00000003";
		API_ENABLECOPY : std_logic_vector := x"00000004";
		API_DISABLECOPY : std_logic_vector := x"00000005";
		API_PAUSECOPY : std_logic_vector := x"00000006";
		API_UNPAUSECOPY : std_logic_vector := x"00000007";
		API_PAUSETRACE : std_logic_vector := x"00000008";
		API_UNPAUSETRACE : std_logic_vector := x"00000009";

		S_CONTR_BASE_ADDR	: std_logic_vector	:= x"60000000";
		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface s_ram_axi_axi
		C_s_ram_axi_DATA_WIDTH	: integer	:= 32;
		C_s_ram_axi_ADDR_WIDTH	: integer	:= 32;

		-- Parameters of Axi Master Bus Interface m_ram_axi
		C_m_ram_axi_START_DATA_VALUE	: std_logic_vector	:= x"AA000000";
		C_m_ram_axi_TARGET_SLAVE_BASE_ADDR	: std_logic_vector	:= x"40000000";
		C_m_ram_axi_ADDR_WIDTH	: integer	:= 32;
		C_m_ram_axi_DATA_WIDTH	: integer	:= 32;
		C_m_ram_axi_TRANSACTIONS_NUM	: integer	:= 4;

		-- Parameters of Axi Slave Bus Interface s_contr_axi
		C_s_contr_axi_DATA_WIDTH	: integer	:= 32;
		C_s_contr_axi_ADDR_WIDTH	: integer	:= 32;

		-- Parameters of Axi Master Bus Interface m_copy_axi
		C_m_copy_axi_START_DATA_VALUE	: std_logic_vector	:= x"AA000000";
		C_m_copy_axi_TARGET_SLAVE_BASE_ADDR	: std_logic_vector	:= x"40000000";
		C_m_copy_axi_ADDR_WIDTH	: integer	:= 32;
		C_m_copy_axi_DATA_WIDTH	: integer	:= 32;
		C_m_copy_axi_TRANSACTIONS_NUM	: integer	:= 4
	);
	port (

		switch1In: IN STD_LOGIC;
		ledsOut: OUT STD_LOGIC_VECTOR(3 downto 0) := "0000";

		-- Ports of Axi Slave Bus Interface s_ram_axi_axi
		s_ram_axi_aclk	: in std_logic;
		s_ram_axi_aresetn	: in std_logic;
		s_ram_axi_awaddr	: in std_logic_vector(C_s_ram_axi_ADDR_WIDTH-1 downto 0);
		s_ram_axi_awprot	: in std_logic_vector(2 downto 0);
		s_ram_axi_awvalid	: in std_logic;
		s_ram_axi_awready	: out std_logic := '0';
		s_ram_axi_wdata	: in std_logic_vector(C_s_ram_axi_DATA_WIDTH-1 downto 0);
		s_ram_axi_wstrb	: in std_logic_vector((C_s_ram_axi_DATA_WIDTH/8)-1 downto 0);
		s_ram_axi_wvalid	: in std_logic;
		s_ram_axi_wready	: out std_logic := '0';
		s_ram_axi_bresp	: out std_logic_vector(1 downto 0) := (others => '0');
		s_ram_axi_bvalid	: out std_logic := '0';
		s_ram_axi_bready	: in std_logic;
		s_ram_axi_araddr	: in std_logic_vector(C_s_ram_axi_ADDR_WIDTH-1 downto 0);
		s_ram_axi_arprot	: in std_logic_vector(2 downto 0);
		s_ram_axi_arvalid	: in std_logic;
		s_ram_axi_arready	: out std_logic := '0';
		s_ram_axi_rdata	: out std_logic_vector(C_s_ram_axi_DATA_WIDTH-1 downto 0) := (others => '0');
		s_ram_axi_rresp	: out std_logic_vector(1 downto 0) := (others => '0');
		s_ram_axi_rvalid	: out std_logic := '0';
		s_ram_axi_rready	: in std_logic;

		-- Ports of Axi Master Bus Interface m_ram_axi
		m_ram_axi_aclk	: in std_logic;
		m_ram_axi_aresetn	: in std_logic;
		m_ram_axi_awaddr	: out std_logic_vector(C_m_ram_axi_ADDR_WIDTH-1 downto 0) := (others => '0');
		m_ram_axi_awprot	: out std_logic_vector(2 downto 0) := (others => '0');
		m_ram_axi_awvalid	: out std_logic := '0';
		m_ram_axi_awready	: in std_logic;
		m_ram_axi_wdata	: out std_logic_vector(C_m_ram_axi_DATA_WIDTH-1 downto 0) := (others => '0');
		m_ram_axi_wstrb	: out std_logic_vector(C_m_ram_axi_DATA_WIDTH/8-1 downto 0) := (others => '0');
		m_ram_axi_wvalid	: out std_logic:= '0';
		m_ram_axi_wready	: in std_logic;
		m_ram_axi_bresp	: in std_logic_vector(1 downto 0);
		m_ram_axi_bvalid	: in std_logic;
		m_ram_axi_bready	: out std_logic := '0';
		m_ram_axi_araddr	: out std_logic_vector(C_m_ram_axi_ADDR_WIDTH-1 downto 0) := (others => '0');
		m_ram_axi_arprot	: out std_logic_vector(2 downto 0) := (others => '0');
		m_ram_axi_arvalid	: out std_logic := '0';
		m_ram_axi_arready	: in std_logic;
		m_ram_axi_rdata	: in std_logic_vector(C_m_ram_axi_DATA_WIDTH-1 downto 0);
		m_ram_axi_rresp	: in std_logic_vector(1 downto 0);
		m_ram_axi_rvalid	: in std_logic;
		m_ram_axi_rready	: out std_logic:= '0';

		-- Ports of Axi Slave Bus Interface s_contr_axi
		s_contr_axi_aclk	: in std_logic;
		s_contr_axi_aresetn	: in std_logic;
		s_contr_axi_awaddr	: in std_logic_vector(C_s_contr_axi_ADDR_WIDTH-1 downto 0);
		s_contr_axi_awprot	: in std_logic_vector(2 downto 0);
		s_contr_axi_awvalid	: in std_logic;
		s_contr_axi_awready	: out std_logic:= '0';
		s_contr_axi_wdata	: in std_logic_vector(C_s_contr_axi_DATA_WIDTH-1 downto 0);
		s_contr_axi_wstrb	: in std_logic_vector((C_s_contr_axi_DATA_WIDTH/8)-1 downto 0);
		s_contr_axi_wvalid	: in std_logic;
		s_contr_axi_wready	: out std_logic:= '0';
		s_contr_axi_bresp	: out std_logic_vector(1 downto 0) := "00";
		s_contr_axi_bvalid	: out std_logic:= '0';
		s_contr_axi_bready	: in std_logic;
		s_contr_axi_araddr	: in std_logic_vector(C_s_contr_axi_ADDR_WIDTH-1 downto 0);
		s_contr_axi_arprot	: in std_logic_vector(2 downto 0) := "000";
		s_contr_axi_arvalid	: in std_logic;
		s_contr_axi_arready	: out std_logic:= '0';
		s_contr_axi_rdata	: out std_logic_vector(C_s_contr_axi_DATA_WIDTH-1 downto 0) := (others => '0');
		s_contr_axi_rresp	: out std_logic_vector(1 downto 0) := "00";
		s_contr_axi_rvalid	: out std_logic:= '0';
		s_contr_axi_rready	: in std_logic;

		-- Ports of Axi Master Bus Interface m_copy_axi
		m_copy_axi_aclk	: in std_logic;
		m_copy_axi_aresetn	: in std_logic;
		m_copy_axi_awaddr	: out std_logic_vector(C_m_copy_axi_ADDR_WIDTH-1 downto 0) := (others => '0');
		m_copy_axi_awprot	: out std_logic_vector(2 downto 0) := "000";
		m_copy_axi_awvalid	: out std_logic := '0';
		m_copy_axi_awready	: in std_logic;
		m_copy_axi_wdata	: out std_logic_vector(C_m_copy_axi_DATA_WIDTH-1 downto 0) := (others => '0');
		m_copy_axi_wstrb	: out std_logic_vector(C_m_copy_axi_DATA_WIDTH/8-1 downto 0) := (others => '0');
		m_copy_axi_wvalid	: out std_logic := '0';
		m_copy_axi_wready	: in std_logic;
		m_copy_axi_bresp	: in std_logic_vector(1 downto 0);
		m_copy_axi_bvalid	: in std_logic;
		m_copy_axi_bready	: out std_logic := '1';
		m_copy_axi_araddr	: out std_logic_vector(C_m_copy_axi_ADDR_WIDTH-1 downto 0) := (others => '0');
		m_copy_axi_arprot	: out std_logic_vector(2 downto 0) := "000";
		m_copy_axi_arvalid	: out std_logic := '0';
		m_copy_axi_arready	: in std_logic;
		m_copy_axi_rdata	: in std_logic_vector(C_m_copy_axi_DATA_WIDTH-1 downto 0);
		m_copy_axi_rresp	: in std_logic_vector(1 downto 0);
		m_copy_axi_rvalid	: in std_logic;
		m_copy_axi_rready	: out std_logic := '0'
	);
end direct_mem_max_v1_0;

architecture arch_imp of direct_mem_max_v1_0 is

	TYPE t_copy_State IS (
		s_IDLE,
		s_RCV,
		s_RCV_DONE,
		s_CLONE,
		s_CLONE_DONE,
		s_DEBUG
	);


	TYPE t_mem_State IS (
		s_IDLE,
		s_READ,
		s_READ_DONE,
		s_WRITE,
		s_WRITE_DONE,
		s_DEBUG
	);

	signal s_copy_rcv_State : t_copy_State := s_IDLE;
	signal s_copy_clone_State : t_copy_State := s_IDLE;

	signal s_contr_State : t_mem_State := s_IDLE;
	signal s_contr_read_State : t_mem_State := s_IDLE;



	-- MAP 
	type t_map_entry is record
		key 	: unsigned(KEY_WIDTH-1 downto 0);
		value 	: unsigned(VALUE_WIDTH-1 downto 0);
		size 	: unsigned(32-1 downto 0);
		is_set	: STD_LOGIC;
	end record t_map_entry;

	type t_map is array (0 to MAX_SIZE-1) of t_map_entry;

	signal DMAP : t_map := 
	(
		others =>(
			(others =>'0'),
			(others=>'0'),
			(others=>'0'),
			'0'
		)
	);
	

	function map_find (
		DMAPIn : in t_map;
		key: in unsigned(KEY_WIDTH-1 downto 0)
	)
		return t_map_entry is
		-- default
		variable v_found : t_map_entry := ((others =>'0'), (others=>'0'), (others=>'0'), '0');
	begin
		--search for element
		for I in 0 to MAX_SIZE-1 loop
			if (key >= DMAPIn(I).key  and key < (DMAPIn(I).key + DMAPIn(I).size) and DMAPIn(I).is_set = '1') then
				v_found.key := key;
				v_found.value := (key-DMAPIn(I).key)+DMAPIn(I).value;
				v_found.is_set := '1';
				exit;
			end if;
		end loop;
		return v_found;
	end;


	-- FIFO

	-- record of a write consist of addr, data, and valid byte masking (strobe)
	type t_write is record
		addr 	: STD_LOGIC_VECTOR(C_s_ram_axi_DATA_WIDTH-1 downto 0);
		data 	: STD_LOGIC_VECTOR(C_s_ram_axi_ADDR_WIDTH-1 downto 0);
		strb	: STD_LOGIC_VECTOR((C_s_ram_axi_DATA_WIDTH/8)-1 downto 0);
	end record t_write;

	type t_FIFO is array (FIFO_CAPACITY-1 downto 0) of t_write;
	signal FIFO : t_FIFO := (others => ((others => '0'),(others => '0'),(others => '0')));
	signal head : integer := 0;
	signal last : integer := 0;


	--DIRTY


	type t_dirty_entry is record
		page : UNSIGNED(ADDR_WIDTH-PAGE_OFFSET-1 downto 0);
		is_dirty : STD_LOGIC;
	end record t_dirty_entry ;

	type t_dirty is array (0 to MAX_SIZE_DIRTY-1) of t_dirty_entry;
	signal DIRTY : t_dirty := ( others => ((others=>'0'),'0') );


	--signal DIRTY : std_logic_vector((2**(MEMORY_ADDR_WIDTH -PAGE_SIZE_WIDTH))-1 downto 0) := (15 => '1', others => '0');

	--impure function findDirtyPage(
	--	start: in integer;
	--	size: in integer
	--) return integer is
	--	variable result : boolean := false;
	--begin
	--	if size = 1 then
	--		result := DIRTY(start) = '1';
	--	else
	--		result := findDirtyPage(start, size / 2) and findDirtyPage(start + (size / 2), size / 2);
	--	end if;
	--	return result;
	--end;

BEGIN

	---AXI NOT ALIGNED ????

	--s_ram to m_ram
	m_ram_axi_awaddr <= s_ram_axi_awaddr and x"3FFFFFFF";
	m_ram_axi_awprot	<=	s_ram_axi_awprot 	;
	m_ram_axi_awvalid	<=	s_ram_axi_awvalid 	;
	m_ram_axi_wdata	<=	s_ram_axi_wdata 	;
	m_ram_axi_wstrb	<=	s_ram_axi_wstrb 	;
	m_ram_axi_wvalid	<=	s_ram_axi_wvalid 	;
	m_ram_axi_bready	<=	s_ram_axi_bready 	;
	m_ram_axi_araddr	<=	s_ram_axi_araddr  and x"3FFFFFFF"; ---- 0x50000000
	m_ram_axi_arprot	<=	s_ram_axi_arprot 	;
	m_ram_axi_arvalid	<=	s_ram_axi_arvalid 	;
	m_ram_axi_rready	<=	s_ram_axi_rready 	;

	--m_ram to s_ram	
	s_ram_axi_awready	<=	m_ram_axi_awready 	;
	s_ram_axi_wready	<=	m_ram_axi_wready 	;
	s_ram_axi_bresp	<=	m_ram_axi_bresp 	;
	s_ram_axi_bvalid	<=	m_ram_axi_bvalid 	;
	s_ram_axi_arready	<=	m_ram_axi_arready 	;
	s_ram_axi_rdata	<= m_ram_axi_rdata 	;
	s_ram_axi_rresp	<=	m_ram_axi_rresp 	;
	s_ram_axi_rvalid	<=	m_ram_axi_rvalid 	;

	-- READ OF m_copy is always '0' for all information because m_copy never reads
	m_copy_axi_araddr	<=	x"00000000";
	m_copy_axi_arprot	<=	"000" 	;
	m_copy_axi_arvalid	<=	'0' 	;
	m_copy_axi_rready	<=	'0' 	;




	-- MAIN DRIVER
	process(s_contr_axi_aclk)

		variable v_found_fifo : t_map_entry := ((others =>'0'), (others=>'0'), (others=>'0'), '0');
		variable v_found_trace : t_map_entry := ((others =>'0'), (others=>'0'), (others=>'0'), '0');
		variable v_fifoSet : t_write := ((others => '0'), (others => '0'), (others => '0'));
		variable v_fifoGet : t_write := ((others => '0'), (others => '0'), (others => '0'));
		variable fifoFull : std_logic := '0';
		variable fifoEmpty : std_logic := '0';

		variable func : std_logic_vector(ADDR_WIDTH-1 downto 0) := x"00000000";
		variable status : std_logic_vector(ADDR_WIDTH-1 downto 0) := x"00000000";
		variable key : std_logic_vector(ADDR_WIDTH-1 downto 0) := x"00000000";
		variable size : std_logic_vector(ADDR_WIDTH-1 downto 0) := x"00000000";
		variable value : std_logic_vector(ADDR_WIDTH-1 downto 0) := x"00000000";
		variable modified : std_logic_vector(ADDR_WIDTH-1 downto 0) := x"FFFFFFFF";

		variable b_pause_trace : boolean := false;
		variable b_pause_copy : boolean := false;
		variable b_copying : boolean := true;

		variable v_found : t_map_entry := ((others =>'0'), (others=>'0'), (others=>'0'), '0');
		variable v_page_found : t_dirty_entry := ((others => '0'), '0');


		-- PROCEDURE TO ADD/UPDATE VALUES
		procedure map_at (
			key: in unsigned(KEY_WIDTH-1 downto 0);
			value: in unsigned(VALUE_WIDTH-1 downto 0);
			size: in unsigned(32-1 downto 0)
		) is
		begin
			-- TEST IF KEY ALREADY AVAILABLE
			for I in 0 to MAX_SIZE-1 loop
				-- CHECK IF KEY IS IN RANGE AND SET
				if (key >= DMAP(I).key and key < (DMAP(I).key + DMAP(I).size) and DMAP(I).is_set = '1') then
					-- ENTRY FOUND, UPDATE VALUE
					DMAP(I).value <= value-(key-DMAP(I).key);
					DMAP(I).size <= value-(key-DMAP(I).size);
					v_found := DMAP(I);
					exit;
				end if;
			end loop;
			-- KEY NOT AVAILABLE
			if v_found.is_set = '0' then
				for I in 0 to MAX_SIZE-1 loop
					if (DMAP(I).is_set='0') then
						-- FREE SPACE FOUND, INSERT INTO MAP
						DMAP(I).key <= key;
						DMAP(I).value <= value;
						DMAP(I).size <= size;
						DMAP(I).is_set <= '1';
						v_found := DMAP(I);
						exit;
					end if;
				end loop;
			end if;
		end;

		procedure get_dirty_page is
		begin
			v_page_found.is_dirty := '0';

			-- FIND PAGE
			for I in 0 to MAX_SIZE_DIRTY-1 loop
				if DIRTY(i).is_dirty = '1' then
					DIRTY(i).is_dirty <= '0';
					v_page_found.page := DIRTY(i).page;
					v_page_found.is_dirty := '1';
					exit;
				end if;
			end loop;
		end;

		procedure fifo_insert (
			DataIn : in t_write;
			headIn: in integer;
			lastIn: in integer
		) is
		begin
			--CHECK IF FIFO NOT FULL
			if( not (headIn = ((lastIn -1) mod FIFO_CAPACITY ) )) then 
				-- INSERT AND UPDATE HEAD
				FIFO(headIn) <= DataIn;
				head <= (headIn + 1) mod FIFO_CAPACITY;
			end if; 
		end;

		impure function fifo_get (
			fifoIn : in t_FIFO;
			headIn: in integer;
			lastIn: in integer
		) return t_write is
			variable element : t_write := ((others => '0'), (others => '0'), (others => '0'));
		begin
			--CHECK IF FIFO NOT EMPTY
			if ( not (last = headIn )) then
				--REMOVE AND UPDATE LAST
				element := fifoIn(lastIn);
				last <= (lastIn + 1) mod FIFO_CAPACITY;	
			end if;
			return element;
		end;

		-- PROCEDURE TO ADD DIRTY FLAGS
		procedure dirty_at (
			page: in unsigned(ADDR_WIDTH-PAGE_OFFSET-1 downto 0)
		) is
		begin
			v_page_found.is_dirty := '0';
			for I in 0 to MAX_SIZE_DIRTY-1 loop
				-- CHECK IF PAGE ALREADY SET
				if DIRTY(I).page = page then
					-- FREE SPACE FOUND, SET PAGE
					v_page_found.is_dirty := '1';
					exit;
				end if;
			end loop;
			if v_page_found.is_dirty = '0' then 
				for I in 0 to MAX_SIZE_DIRTY-1 loop
					if (DIRTY(I).is_dirty = '0') then
						-- FREE SPACE FOUND, SET PAGE
						DIRTY(I).page <= page;
						DIRTY(I).is_dirty <= '1';
						exit;
					end if;
				end loop;
			end if;
		end;

		impure function get_dirty_page_at (
			idx : in integer
		) return unsigned is
			variable page : UNSIGNED(ADDR_WIDTH-PAGE_OFFSET-1 downto 0) := (others => '0');
		begin
			for I in 0 to MAX_SIZE_DIRTY-1 loop
				if DIRTY(i).is_dirty = '1' and i = (idx / 4) then
					--DIRTY(i).is_dirty <= '0';
					page := DIRTY(i).page;
					exit;
				end if;
			end loop;
			return page;
		end;

		--impure function get_fifo_entry_at (--	idx : integer--) return std_logic_vector is --	variable result : std_logic_vector(31 downto 0) := (others => '0');--begin--	-- GO THROUGH AL ENTRIES IN FIFO--	for I in 0 to FIFO_CAPACITY loop--		if I * 2 = idx  then
		--			result := FIFO((head+I) mod FIFO_CAPACITY).addr;
		--			exit;
		--		end if;
		--		if I * 2 + 1 = idx  then
		--			result := FIFO((head+I) mod FIFO_CAPACITY).data;
		--			exit;
		--		end if;
		--	end loop;
		--	return result;
		--end;



		variable counter : integer := 0;
		variable counter_clk_copy :  integer := 0;
		variable counter_transactions_copy : integer := 0;

		variable counter_clk_ram_write :  integer := 0;
		variable counter_transactions_ram_write  : integer := 0;

		variable counter_clk_contr_write :  integer := 0;
		variable counter_transactions_contr_write  : integer := 0;

		variable counter_clk_contr_read :  integer := 0;
		variable counter_transactions_contr_read  : integer := 0;

	-- PROCESS BEGIN
	BEGIN
		IF rising_edge(s_contr_axi_aclk) THEN
			-- SYNCHRONOUS RESET WITH ACTIVE LOW
			IF s_contr_axi_aresetn = '0' THEN

				-- DATA STRUCTURES
				DMAP <= 
				(
					others => (
						(others=>'0'),
						(others=>'0'),
						(others=>'0'),
						'0'
					)
				); 

				FIFO <= (
					others => (
						(others => '0'),
						(others => '0'),
						(others => '0')
					)
				);
				DIRTY <= (
					others => (
						(others=>'0'),
						'0'
					)
				);

				-- FIFO STATUS variables
				fifoFull 	:= '0';
				fifoEmpty 	:= '0';

				-- API variables
				func 	:= x"00000000";
				status 	:= x"00000000";
				key 	:= x"00000000";
				size 	:= x"00000000";
				value 	:= x"00000000";
				modified := x"FFFFFFFF";

				-- INTERMEDIATE variables
				v_found_fifo:= ((others =>'0'), (others=>'0'), (others=>'0'), '0');
				v_fifoSet:= ((others => '0'), (others => '0'), (others => '0'));
				v_fifoGet:= ((others => '0'), (others => '0'), (others => '0'));
				v_found := ((others =>'0'), (others=>'0'), (others=>'0'), '0');
				v_page_found := ((others => '0'), '0');

				counter := 0;

				counter_clk_copy := 0;
				counter_transactions_copy := 0;

				counter_clk_ram_write := 0;
				counter_transactions_ram_write := 0;

				counter_clk_contr_write := 0;
				counter_transactions_contr_write := 0;

				counter_clk_contr_read := 0;
				counter_transactions_contr_read := 0;

				b_pause_copy := false;
				b_copying := true;

			ELSE


				ledsOut <= std_logic_vector(to_unsigned(counter, 4));

				if(head = last) then
					fifoEmpty := '1';
				else
					fifoEmpty := '0';
				end if;

				if(head = ((last -1)) mod FIFO_CAPACITY) then --mod
					fifoFull := '1';
				else
					fifoFull := '0';
				end if;

				--  FIFO WRITE BACK
				CASE s_copy_clone_State IS
					WHEN s_IDLE =>
						-- FIFO NOT EMPTY AND WRITE IS ENABLED
						IF b_pause_copy = false AND fifoEmpty = '0' AND m_copy_axi_bvalid = '0'   and s_copy_rcv_State = s_IDLE and s_copy_clone_State = s_IDLE and s_contr_read_State = s_IDLE and s_contr_State = s_IDLE THEN --and switch1In = '1'
							counter := counter + 1;
							counter_clk_copy := counter_clk_copy + 1;
							--GET VALUE FROM FIFO QUEUE
							v_fifoGet := fifo_get(FIFO, head, last);
							--HAS ADRESS BEEN FOUND?
										 
							-- TRANSFORM ADRESS PUT WRITE INFORMATION ON MASTER COPY AXI BUS
							m_copy_axi_awaddr <= v_fifoGet.addr and x"3FFFFFFF";
							m_copy_axi_wdata <= v_fifoGet.data;--std_logic_vector(to_unsigned(counter,32));
							m_copy_axi_wstrb <= v_fifoGet.strb;
							-- PROTOCOL IS ALWAYS "000" (no exclusive access etc.)
							m_copy_axi_awprot <= "000";
							-- ENABLE WRITE
							m_copy_axi_wvalid <= '1';

							s_copy_clone_State <= s_CLONE;
							
						END IF;
					WHEN s_CLONE =>
                        m_copy_axi_awvalid <= '1';
						counter_clk_copy := counter_clk_copy + 1;
                        -- WAIT FOR CONNECTED SLAVE TO CONFIRM WRITE
						if m_copy_axi_awready = '1' and m_copy_axi_wready = '1' then
							s_copy_clone_State <= s_CLONE_DONE;
						end if;
					WHEN s_CLONE_DONE =>
						-- WAIT FOR CONNECTED SLAVE TO FINISH WRITING
						if m_copy_axi_bvalid = '1' then
							counter_clk_copy := counter_clk_copy + 1;
							counter_transactions_copy := counter_transactions_copy + 1;
							m_copy_axi_bready <= '1';
							m_copy_axi_awvalid <= '0';
							m_copy_axi_wvalid <= '0';
							s_copy_clone_State <= s_IDLE;
						end if;
					WHEN others =>
						s_copy_clone_State <= s_IDLE;
				END CASE;

				--COPY TO FIFO
				CASE s_copy_rcv_State IS
					WHEN s_IDLE =>
						-- CONNECTED SLAVE AND CONNECTED MASTER AGREE on TRANSACTION SO MAKE COPY TO FIFO 
						if m_ram_axi_bvalid='0' and s_ram_axi_wvalid = '1' and s_ram_axi_awvalid  = '1'  then
							 counter_clk_ram_write := counter_clk_ram_write + 1;
							
							-- INSERT INTO FIFO IF ENABLED
							v_found_trace :=((others =>'0'), (others=>'0'), (others=>'0'), '0');
                            v_found_trace := map_find(DMAP, unsigned(s_ram_axi_awaddr));
                            --HAS ADRESS BEEN FOUND?
							IF b_copying = true and fifoFull = '0' and v_found_trace.is_set = '1' THEN 
								-- SET FIFO DATA
								v_fifoSet.addr :=  std_logic_vector(v_found_trace.value);
								v_fifoSet.data := s_ram_axi_wdata;
								v_fifoSet.strb := s_ram_axi_wstrb;
								fifo_insert(v_fifoSet, head, last);
							END IF;
							--SET PAGE AS DIRTY
							IF NOT b_pause_trace AND v_found_trace.is_set = '1' THEN
									dirty_at(shift_right(unsigned(s_ram_axi_awaddr), PAGE_OFFSET));
							END IF;
							--GO TO MEMORY WRITE
							s_copy_rcv_State <= s_RCV;
						end if;

					WHEN s_RCV =>
						counter_clk_ram_write := counter_clk_ram_write + 1;
						-- WÁIT FOR CONNECTED SLAVE TO CONFIRM ORIGINAL WRITE
						if m_ram_axi_bvalid = '1' then 
                            counter_transactions_ram_write := counter_transactions_ram_write + 1;
							s_copy_rcv_State <= s_IDLE;
						end if;
					WHEN s_RCV_DONE =>
						counter_clk_ram_write := counter_clk_ram_write + 1;
						-- WAIT FOR CONNECTED SLAVE TO RESET CONFIRMATION
						if m_ram_axi_bvalid = '0' then 
							s_copy_rcv_State <= s_IDLE;
						end if;
					WHEN others =>
						s_copy_rcv_State <= s_IDLE;
				END CASE;

				--PROCESS WRITES
				CASE s_contr_State IS
					WHEN s_IDLE =>
						IF s_contr_axi_awvalid = '1' AND s_contr_axi_wvalid = '1'  and s_copy_rcv_State = s_IDLE and s_copy_clone_State = s_IDLE and s_contr_read_State = s_IDLE and s_contr_State = s_IDLE  THEN 
							counter_clk_contr_write := counter_clk_contr_write + 1;
							-- accept address and data if validly set
							s_contr_axi_awready <= '1';
							s_contr_axi_wready <= '1';

							s_contr_State <= s_WRITE;
						END IF;
					WHEN s_WRITE =>
						counter_clk_contr_write := counter_clk_contr_write + 1;
						-- choose appropriate action from memory address written to
						CASE s_contr_axi_awaddr(7 downto 0) IS
							WHEN (x"00") => 
								func := s_contr_axi_wdata;
								
								if s_contr_axi_wdata = API_WRITE then
									--INSERT INTO MAP
									v_found := ((others =>'0'), (others=>'0'), (others=>'0'), '0');
									map_at(unsigned(key), unsigned(value), unsigned(size));
								ELSIF s_contr_axi_wdata = API_READ then
									--READ FROM MAP
									v_found := map_find(DMAP, unsigned(key));
									if (v_found.is_set = '1') then
										value := std_logic_vector(v_found.value);
										status := STATUS_FOUND;
									else
										status := STATUS_NOTFOUND;
									end if;
								ELSIF s_contr_axi_wdata = API_GETPAGE THEN
									get_dirty_page;
									IF v_page_found.is_dirty = '1' THEN
										modified := std_logic_vector(shift_left(resize(v_page_found.page, ADDR_WIDTH),PAGE_OFFSET));
										status := STATUS_FOUND;
									ELSE
										modified :=	x"FFFFFFFF";
										status := STATUS_NOTFOUND;
									END IF;
								ELSIF s_contr_axi_wdata = API_ENABLECOPY THEN
									b_copying := true;
								ELSIF s_contr_axi_wdata = API_DISABLECOPY THEN
									b_copying :=  false;
								ELSIF s_contr_axi_wdata = API_PAUSECOPY THEN
									b_pause_copy :=  true;
								ELSIF s_contr_axi_wdata = API_UNPAUSECOPY THEN
									b_pause_copy :=  false;
								ELSIF s_contr_axi_wdata = API_PAUSETRACE THEN
									b_pause_trace := true;
								ELSIF s_contr_axi_wdata = API_UNPAUSETRACE THEN
									b_pause_trace := false;
								END IF;
							WHEN (x"04") => null; -- status is RO
							WHEN (x"08") => key := s_contr_axi_wdata;
							WHEN (x"0C") => value := s_contr_axi_wdata;
							WHEN (x"10") => size := s_contr_axi_wdata;
							WHEN (x"14") => null; -- FIFO counter is RO
							WHEN (x"18") => null;  -- modified is RO
							WHEN others => null;
						END CASE;
						-- mark transfer as valid
						s_contr_axi_bvalid <= '1';

						s_contr_State <= s_WRITE_DONE;
					WHEN s_WRITE_DONE =>
						counter_clk_contr_write := counter_clk_contr_write + 1;
						-- transfer was valid and has been confirmed by master
						IF s_contr_axi_bready = '1' THEN
							counter_transactions_contr_write := counter_transactions_contr_write + 1;
							-- reset validation
							s_contr_axi_bvalid <= '0';
							-- reset acceptance of data and address
							s_contr_axi_awready <= '0';
							s_contr_axi_wready <= '0';
							-- signal that write was "OK"
							s_contr_axi_bresp <= "00";

							s_contr_State <= s_IDLE; 
						END IF;
					WHEN others =>
						s_contr_State <= s_IDLE;
				END CASE;
				--PROCESS READS
				CASE s_contr_read_State IS 
					WHEN s_IDLE =>
						IF s_contr_axi_arvalid = '1' and s_copy_rcv_State = s_IDLE and s_copy_clone_State = s_IDLE and s_contr_read_State = s_IDLE and s_contr_State = s_IDLE THEN 
							counter_clk_contr_read := counter_clk_contr_read + 1;
							-- accept address if validity set
							s_contr_axi_arready <= '1';

							s_contr_read_State <= s_READ;
						END IF;
					WHEN s_READ =>
						counter_clk_contr_read := counter_clk_contr_read + 1;
						-- choose appropriate action from memory address written to
						CASE s_contr_axi_araddr(7 downto 0) IS
							WHEN (x"00") => s_contr_axi_rdata <= func;
							WHEN (x"04") => s_contr_axi_rdata <= status;
							WHEN (x"08") => s_contr_axi_rdata <= key;
							WHEN (x"0C") => s_contr_axi_rdata <= value;
							WHEN (x"10") => s_contr_axi_rdata <= size;
							WHEN (x"14") => s_contr_axi_rdata <= modified;
							WHEN (x"18") => s_contr_axi_rdata <= std_logic_vector(to_unsigned((head-last) mod FIFO_CAPACITY, 32));
							WHEN (x"1C") => 
								-- no VHDL 2008 possible so a lot of IF's
								if b_pause_copy = true and b_copying = true then
									s_contr_axi_rdata <= x"00000101";
								elsif b_pause_copy = false and b_copying = true then
									s_contr_axi_rdata <= x"00000001";
								elsif b_pause_copy = true and b_copying = false  then
									s_contr_axi_rdata <= x"00000100";
								else
									s_contr_axi_rdata <= x"00000000";
								end if;
							WHEN (x"20") => s_contr_axi_rdata <= std_logic_vector(to_unsigned(counter_clk_copy, 32));
							WHEN (x"24") => s_contr_axi_rdata <= std_logic_vector(to_unsigned(counter_transactions_copy, 32));
							WHEN (x"28") => s_contr_axi_rdata <= std_logic_vector(to_unsigned(counter_clk_ram_write, 32));
							WHEN (x"2C") => s_contr_axi_rdata <= std_logic_vector(to_unsigned(counter_transactions_ram_write, 32));
							WHEN (x"30") => s_contr_axi_rdata <= std_logic_vector(to_unsigned(counter_clk_contr_write, 32));
							WHEN (x"34") => s_contr_axi_rdata <= std_logic_vector(to_unsigned(counter_transactions_contr_write, 32));
							WHEN (x"38") => s_contr_axi_rdata <= std_logic_vector(to_unsigned(counter_clk_contr_read, 32));
							WHEN (x"3C") => s_contr_axi_rdata <= std_logic_vector(to_unsigned(counter_transactions_contr_read, 32));
							WHEN others => s_contr_axi_rdata <= x"00000000";
						END CASE;

						--if s_contr_axi_araddr(7 downto 0) >= x"20" and s_contr_axi_araddr(7 downto 0) < x"60" then 
						--	s_contr_axi_rdata <= std_logic_vector(get_dirty_page_at(to_integer(unsigned(s_contr_axi_araddr(7 downto 0)))-32)) & x"000";
						--end if;
						--if s_contr_axi_araddr(15 downto 0) >= x"0060" and s_contr_axi_araddr(15 downto 0) < x"0120" then 
						--	s_contr_axi_rdata <= get_fifo_entry_at(to_integer(unsigned(s_contr_axi_araddr(15 downto 0)))-96);
						--end if;
						-- mark transfer as valid
						s_contr_axi_rvalid <= '1';

						s_contr_read_State <= s_READ_DONE;
					WHEN s_READ_DONE =>
						counter_clk_contr_read := counter_clk_contr_read + 1;
						-- transfer was valid and has been confirmed by master
						IF s_contr_axi_rready = '1' THEN
							counter_transactions_contr_read := counter_transactions_contr_read + 1;
							-- reset validation
							s_contr_axi_rvalid <= '0';
							-- reset acceptance of address
							s_contr_axi_arready <= '0';
							-- signal that read was "OK"
							s_contr_axi_rresp <= "00";

							s_contr_read_State <= s_IDLE;
						END IF;
					WHEN others =>
						s_contr_read_State <= s_IDLE;
				END CASE;
			END IF;
		END IF;
	END PROCESS;



		--m_copy to nothing -- we don't need read responses from the master
		--s_ram_axi_awready	<=	m_copy_axi_awready 	;
		--s_ram_axi_wready	<=	m_copy_axi_wready 	;
		----s_ram_axi_bresp	<=	m_copy_axi_bresp 	;
		----s_ram_axi_bvalid	<=	m_copy_axi_bvalid 	;
		----s_ram_axi_arready	<=	m_copy_axi_arready 	;
		----dummy_rdata	<=	m_copy_axi_rdata 	;
		----s_ram_axi_rresp	<=	m_copy_axi_rresp 	;
		----s_ram_axi_rvalid	<=	m_copy_axi_rvalid 	;

		--s_contr_axi_awready	<= axi_awready;
		--s_contr_axi_wready	<= axi_wready;
		--s_contr_axi_bresp	<= axi_bresp;
		--s_contr_axi_bvStatealid	<= axi_bvalid;
		--s_contr_axi_arready	<= axi_arready;
		--s_contr_axi_rdata	<= axi_rdata;
		--s_contr_axi_rresp	<= axi_rresp;
		--s_contr_axi_rvalid	<= axi_rvalid;



		
end architecture arch_imp;
