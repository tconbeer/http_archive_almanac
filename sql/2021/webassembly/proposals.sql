select
    client,
    countif(instr.proposals.atomics > 0) as atomics,
    countif(instr.proposals.bigint_externals > 0) as bigint_externals,
    countif(instr.proposals.bulk > 0) as bulk,
    countif(instr.proposals.multi_value > 0) as multi_value,
    countif(instr.proposals.mutable_externals > 0) as mutable_externals,
    countif(instr.proposals.non_trapping_conv > 0) as non_trapping_conv,
    countif(instr.proposals.ref_types > 0) as ref_types,
    countif(instr.proposals.sign_extend > 0) as sign_extend,
    countif(instr.proposals.simd > 0) as simd,
    countif(instr.proposals.tail_calls > 0) as tail_calls,
    count(0) as total
from `httparchive.almanac.wasm_stats`
where date = '2021-09-01'
group by client
order by client
