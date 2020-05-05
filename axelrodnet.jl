module Axelrodnet

    using LightGraphs
    using SimpleWeightedGraphs
    using DataFrames
    using Random

    include("agent.jl")
    # include("network.jl")
    include("simulation.jl")

    export run!

end
