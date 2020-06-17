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
    export_experiment::Bool
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
        path = joinpath("experiment", experiment_name)
        Axelrodnet.export_experiment(experiment, path)
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
        export_experiment=true
    )
end

# Erdos-Renyi graph
# for sbf in 0.00:0.01:0.2, p in 0.3:0.1:0.8
#     run_experiment(
#         experiment_name="erdosrenyi_sbf" * string(trunc(Int, sbf * 100)) * "_p" * string(trunc(Int, p * 10)),
#         agentcount=10_000,
#         n_iter=1_000_000,
#         nettopology=2,
#         networkprops=Dict("p" => p),
#         socialbotfrac=sbf,
#         rndseed=1,
#         repcount=3,
#         export_every_n=10_000,
#         export_experiment=true
#     )
# end

# Watts-Strogatz graph
# for sbf in 0.00:0.01:0.2, beta in 0.1:0.1:0.5
#     run_experiment(
#         experiment_name="wattsstrogatz_sbf" * string(trunc(Int, sbf * 100)) * "_beta" * string(trunc(Int, beta * 10)),
#         agentcount=10_000,
#         n_iter=1_000_000,
#         nettopology=3,
#         networkprops=Dict("k" => 10, "beta" => beta),
#         socialbotfrac=sbf,
#         rndseed=1,
#         repcount=3,
#         export_every_n=10_000,
#         export_experiment=true
#     )
# end

# Barabasi-Albert graph
# for sbf in 0.00:0.01:0.2
#     run_experiment(
#         experiment_name="barabasialbert_sbf" * string(trunc(Int, sbf * 100)),
#         agentcount=10_000,
#         n_iter=1_000_000,
#         nettopology=4,
#         networkprops=Dict("m0" => 10),
#         socialbotfrac=sbf,
#         rndseed=1,
#         repcount=3,
#         export_every_n=10_000,
#         export_experiment=true
#     )
# end
