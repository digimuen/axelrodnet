mutable struct simulation
    name::String
    batch_name::String
    repnr::Int64
    rng::MersenneTwister
    init_state::Any
    final_state::Any

    function Simulation(; batch_name="")
        new(
			"",
			batch_name,
			0,
			MersenneTwister(),
            (nothing, nothing),
            (nothing, nothing)
        )
    end
end

function tick!(
	state::Tuple{AbstractGraph, AbstractArray}
)


end

function run!(
	simulation::Simulation=Simulation(),
	batchrunnr::Int64=-1
	;
	name::String="_"
	)

end

function run_batch(

)

end
