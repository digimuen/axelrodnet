include(joinpath("src", "axelrodnet.jl"))

Axelrodnet.run_experiment(
    experiment_name="low_agentcount",
    agentcount=100,
    n_iter=1_000_000,
    nettopology="grid",
    networkprops=Dict(),
    stubborncount=101,
    rndseed=0,
    n_replicates=10,
    export_every_n=100_000,
    exportdata=true,
    exportmode="aggregated",
    keep_rawnet=true
)
