# include module
include(joinpath("src", "axelrodnet.jl"))
if !("experiments" in readdir())
    mkdir("experiments")
end

# replication of Axelrod's original experiment
grid_experiment_path = joinpath("experiments", "grid_experiment")
if !("grid_experiment" in readdir("experiments"))
    mkdir(joinpath("experiments", "grid_experiment"))
end
grid_experiment = Axelrodnet.run(
    agentcount=100,
    n_iter=1_000_000,
    nettopology=1,
    networkprops=Dict("grid_height" => 100),
    socialbotfrac=0.00,
    rndseed=1,
    repcount=3,
    export_every_n=10_000
)
Axelrodnet.export_experiment(grid_experiment, grid_experiment_path)

# experiments with Erdos-Renyi graph 1
er1_experiment_path = joinpath("experiments", "er1_experiment")
if !("er1_experiment" in readdir("experiments"))
    mkdir(joinpath("experiments", "er1_experiment"))
end
er1_experiment = Axelrodnet.run(
    agentcount=100,
    n_iter=1_000_000,
    nettopology=2,
    networkprops=Dict("p" => 0.1),
    socialbotfrac=0.05,
    rndseed=1,
    repcount=3,
    export_every_n=10_000
)
Axelrodnet.export_experiment(er1_experiment, er1_experiment_path)

# experiments with Erdos-Renyi graph 2
er2_experiment_path = joinpath("experiments", "er2_experiment")
if !("er2_experiment" in readdir("experiments"))
    mkdir(joinpath("experiments", "er2_experiment"))
end
er2_experiment = Axelrodnet.run(
    agentcount=100,
    n_iter=1_000_000,
    nettopology=2,
    networkprops=Dict("p" => 0.2),
    socialbotfrac=0.05,
    rndseed=1,
    repcount=3,
    export_every_n=10_000
)
Axelrodnet.export_experiment(er2_experiment, er2_experiment_path)

# experiments with Erdos-Renyi graph 3
er3_experiment_path = joinpath("experiments", "er3_experiment")
if !("er3_experiment" in readdir("experiments"))
    mkdir(joinpath("experiments", "er3_experiment"))
end
er3_experiment = Axelrodnet.run(
    agentcount=100,
    n_iter=1_000_000,
    nettopology=2,
    networkprops=Dict("p" => 0.3),
    socialbotfrac=0.05,
    rndseed=1,
    repcount=3,
    export_every_n=10_000
)
Axelrodnet.export_experiment(er3_experiment, er3_experiment_path)
