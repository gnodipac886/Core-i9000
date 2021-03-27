/* DO NOT MODIFY. WILL BE OVERRIDDEN BY THE AUTOGRADER. */

/**
 * `memory` loads a binary into memory, and uses this to drive
 * the DUT.
**/
module source_tb(
    tb_itf.tb itf,
    tb_itf.mem mem_itf,
    cache_monitor_itf.cache_monitor cache_itf
);

// Paramaterized Memory
ParamMemory #(25, 13, 4, 256, 512) memory(mem_itf);
shadow_memory sm(cache_itf);


endmodule : source_tb
