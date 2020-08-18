include(joinpath("src", "axelrodnet.jl"))

Axelrodnet.run_experiment(
    experiment_name="test_run_grid",
    agentcount=100,
    n_iter=1_000_000,
    nettopology="grid",
    networkprops=Dict("grid_heit" => 10),
    stubborncount=1001,
    rndseed=0,
    n_replicates=10,
    export_every_n=100_000,
    exportdata=true,
    exportmode="aggregated",
    keep_rawnet=true
)

Axelrodnet.run_experiment(
    experiment_name="test_run_watts_strogatz",
    agentcount=100,
    n_iter=1_000_000,
    nettopology="watts_strogatz",
    networkprops=Dict("k" => 101, "beta" => 1.2),
    stubborncount=1001,
    rndseed=0,
    n_replicates=10,
    export_every_n=1_000_000,
    exportdata=true,
    exportmode="default",
    keep_rawnet=true
)

Axelrodnet.run_experiment(
    experiment_name="test_run_barabasi_albert",
    agentcount=100,
    n_iter=1_000_000,
    nettopology="barabasi_albert",
    networkprops=Dict("m0" => 200),
    stubborncount=1001,
    rndseed=0,
    n_replicates=10,
    export_every_n=100_000,
    exportdata=true,
    exportmode="aggregated",
    keep_rawnet=true
)
