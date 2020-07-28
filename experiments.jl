# include module
include(joinpath("src", "axelrodnet.jl"))

# convenience function for experiment runs
function run_experiment(;
    experiment_name::String,
    agentcount::Int64,
    n_iter::Int64,
    nettopology::Int64,
    networkprops::Dict,
    socialbotfrac::Float64,
    rndseed::Int64,
    repcount::Int64,
    export_every_n::Int64,
    export_experiment::Bool,
    aggregated::Bool
)
    if !("experiments" in readdir())
        mkdir("experiments")
    end
    if !(experiment_name in readdir("experiments"))
        mkdir(joinpath("experiments", experiment_name))
    end
    experiment = Axelrodnet.run(
        agentcount=agentcount,
        n_iter=n_iter,
        nettopology=nettopology,
        networkprops=networkprops,
        socialbotfrac=socialbotfrac,
        rndseed=rndseed,
        repcount=repcount,
        export_every_n=export_every_n
    )
    if export_experiment
        path = joinpath("experiments", experiment_name)
        Axelrodnet.export_experiment(
            experiment=experiment,
            path=path,
            socialbotfrac=socialbotfrac,
            networkprops=networkprops,
            aggregated=aggregated
        )
    end
    return experiment
end

# grid graph
for sbf in 0.00:0.01:0.2
    run_experiment(
        experiment_name="grid_sbf" * string(trunc(Int, sbf * 100)),
        agentcount=10_000,
        n_iter=1_000_000,
        nettopology=1,
        networkprops=Dict("grid_height" => 100),
        socialbotfrac=sbf,
        rndseed=1,
        repcount=3,
        export_every_n=10_000,
        export_experiment=true,
        aggregated=false
    )
end

# Watts-Strogatz graph
for sbf in 0.00:0.01:0.2, beta in 0.1:0.1:0.5
    run_experiment(
        experiment_name="wattsstrogatz_sbf" * string(trunc(Int, sbf * 100)) * "_beta" * string(trunc(Int, beta * 10)),
        agentcount=10_000,
        n_iter=1_000_000,
        nettopology=3,
        networkprops=Dict("k" => 10, "beta" => beta),
        socialbotfrac=sbf,
        rndseed=1,
        repcount=3,
        export_every_n=10_000,
        export_experiment=true,
        aggregated=false
    )
end

# Barabasi-Albert graph
for sbf in 0.00:0.01:0.2
    run_experiment(
        experiment_name="barabasialbert_sbf" * string(trunc(Int, sbf * 100)),
        agentcount=10_000,
        n_iter=1_000_000,
        nettopology=4,
        networkprops=Dict("m0" => 10),
        socialbotfrac=sbf,
        rndseed=1,
        repcount=3,
        export_every_n=10_000,
        export_experiment=true,
        aggregated=false
    )
end
