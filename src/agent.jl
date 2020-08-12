mutable struct Agent

    culture::AbstractArray
    stubborn::Bool

    function Agent(culture, stubborn=false)
        new(culture, stubborn)
    end

end
