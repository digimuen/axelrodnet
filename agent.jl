mutable struct Agent
    cultureVector::AbstractArray
    socialbot::Bool

    function Agent(cultureVector, socialbot=false)

        new(cultureVector,socialbot)
    end
end
