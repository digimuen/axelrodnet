include(joinpath("src", "axelrodnet.jl"))

Axelrodnet.run_experiment(
    experiment_name="low_agentcount",
    agentcount=100,
    n_iter=1_000_000,
    nettopology="grid",
    networkprops=Dict("grid_height" => 10),
    stubbornfrac=0.0,
    rndseed=0,
    repcount=10,
    export_every_n=100_000,
    export_experiment=true,
    exportmode="aggregated",
    keep_rawnet=true
)
