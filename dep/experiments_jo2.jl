# imports
include("axelrodnet.jl")

er_runs = Axelrodnet.run!(
    agentcount=100,
    n_iter=1_000_000,
    nettopology=2,
    networkprops=Dict("p" => 0.1),
    socialbotfrac=0.01,
    rndseed=151,
    repcount=3,
    export_every_n=10_000
)

Axelrodnet.export_experiment(er_runs)
