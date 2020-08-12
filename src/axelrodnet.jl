module Axelrodnet

    using LightGraphs
    using GraphIO
    using DataFrames
    using Random
    using Feather
    using ParserCombinator
    using REPL

    export run_experiment
    export run
    export export_experiment

    include("agent.jl")
    include("io.jl")
    include("tick.jl")
    include("network.jl")
    include("simulation_utilities.jl")
    include("simulation.jl")

end
