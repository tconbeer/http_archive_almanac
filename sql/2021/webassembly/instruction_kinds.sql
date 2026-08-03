select
    client,
    sum(instr.categories.other) / sum(instr.total) as other_pct,
    sum(instr.categories.constants) / sum(instr.total) as constants_pct,
    sum(instr.categories.wait_notify) / sum(instr.total) as wait_notify_pct,
    sum(instr.categories.indirect_calls) / sum(instr.total) as indirect_calls_pct,
    sum(instr.categories.direct_calls) / sum(instr.total) as direct_calls_pct,
    sum(instr.categories.load_store) / sum(instr.total) as load_store_pct,
    sum(instr.categories.memory) / sum(instr.total) as memory_pct,
    sum(instr.categories.control_flow) / sum(instr.total) as control_flow_pct,
    sum(instr.categories.table) / sum(instr.total) as table_pct,
    sum(instr.categories.global_var) / sum(instr.total) as global_var_pct,
    sum(instr.categories.local_var) / sum(instr.total) as local_var_pct
from `httparchive.almanac.wasm_stats`
where date = '2021-09-01'
group by client
order by client
