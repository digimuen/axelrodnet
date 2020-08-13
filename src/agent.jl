mutable struct Agent
    culture::AbstractArray
    stubborn::Bool
end

Agent(culture) = Agent(culture, false)
