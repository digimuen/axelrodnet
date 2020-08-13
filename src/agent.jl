mutable struct Agent
    id::Int64
    culture::AbstractArray
    stubborn::Bool
end

Agent(id, culture) = Agent(id, culture, false)
