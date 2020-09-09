module Axelrodnet

    using LightGraphs
    using GraphIO
    using DataFrames
    using Random
    using Feather
    using ParserCombinator
    using REPL
    using StatsBase
    using Query

    export run_experiment
    export run
    export export_experiment
    export aggregate_experiment
    export aggregate_all_experiments

    include("agent.jl")
    include("assert.jl")
    include("io.jl")
    include("tick.jl")
    include("network.jl")
    include("utilities.jl")
    include("simulation.jl")
    include("aggregate.jl")

end
