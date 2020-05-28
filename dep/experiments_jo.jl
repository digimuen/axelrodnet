# imports
include("axelrodnet.jl")

# replication of the original experiment
orig_replication = Axelrodnet.run!(
    agentcount=100,
    n_iter=100,
    nettopology=1,
    networkprops=Dict("grid_height" => 10),
    socialbotfrac=0.0,
    rndseed=151,
    repcount=3,
    export_every_n=1
)

Axelrodnet.export_experiment(orig_replication)
