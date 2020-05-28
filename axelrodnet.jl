module Axelrodnet

    using LightGraphs
    using SimpleWeightedGraphs
    using DataFrames
    using Random
    using Primes
    using GraphIO
    using Feather
    using ParserCombinator

    include("agent.jl")
    include("simulation.jl")

    export run!
    export export_experiment

end
