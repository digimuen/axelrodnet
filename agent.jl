mutable struct Agent
    id::Int64
    cultureVector::AbstractArray
    socialbot::Bool

    function Agent(id, cultureVector, socialbot=false)

        new(id, cultureVector,socialbot)
    end
end
