include("axelrodnet.jl")

er_runs = Axelrodnet.run!(
    sqrt_agentcount=100,
    n_iter=1_000_000,
    nettopology=2,
    networkprops=Dict("p" => 0.3),
    socialbotfrac=0.01,
    rndseed=151,
    repcount=100,
    export_every_n=10_000
)
