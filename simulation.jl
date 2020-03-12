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

	agents = zeros(Int64, 100, 5)
	for i in 1:100
		agents[i,:] = rand(1:9,5)
	end

	simulation.init_state = (create_network(agents), agents)



end

function run_batch(

)

end
