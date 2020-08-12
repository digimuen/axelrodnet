# include module
include(joinpath("src", "axelrodnet.jl"))

run_experiment(
    experiment_name="low_agentcount",
    agentcount=100,
    n_iter=1_000_000,
    nettopology=1,
    networkprops=Dict("grid_height" => 10),
    socialbotfrac=0.0,
    rndseed=0,
    repcount=10,
    export_every_n=10_000,
    export_experiment=true,
    aggregated=1,
    keep_rawnet=false
)

run_experiment(
    experiment_name="high_agentcount",
    agentcount=10_000,
    n_iter=2_000_000,
    nettopology=1,
    networkprops=Dict("grid_height" => 100),
    socialbotfrac=0.0,
    rndseed=0,
    repcount=10,
    export_every_n=50_000,
    export_experiment=true,
    aggregated=1,
    keep_rawnet=false
)
