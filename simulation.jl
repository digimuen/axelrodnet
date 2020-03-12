using LightGraphs

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

function assimilate!(agents, acting_agent, interaction_partner)
	random_attr = rand(1:length(acting_agent.cultureVector))

	if acting_agent.cultureVector[random_attr] - interaction_partner.cultureVector[random_attr] != 0

		acting_agent.cultureVector[random_attr] = interaction_partner.cultureVector[random_attr]

	else
		assimilate!(agents, acting_agent, interaction_partner)
	end
end

function tick!(
	network::AbstractGraph,
	agents::AbstractArray
)
	random_draw = rand(1:length(agents))
	acting_agent = agents[random_draw]
	interaction_partner = agents[rand(neighbors(network,random_draw))]

	similarity = sum([i == j for (i, j) in zip(acting_agent.cultureVector, interaction_partner.cultureVector)]) / length(acting_agent.cultureVector)

	if rand() < similarity && similarity != 1
		assimilate!(agents, acting_agent, interaction_partner)
	end

	return network, agents
end

function run!(
	# simulation::Simulation=Simulation(),
	batchrunnr::Int64=-1
	;
	name::String="_"
	)

	agentcount = 200

	agents = Agent[]
	for i in 1:agentcount
		push!(agents, Agent(length(agents) + 1, rand(1:9,5)))
	end

	for i in 1:trunc(Int64, 0.05*agentcount)
		push!(agents, Agent(length(agents) + 1, fill(7,5), true))
	end

	network = barabasi_albert(length(agents),50)

	for i in 1:200000
		tick!(network,agents)
	end

	return agents
end

function run_batch(

)

end



test = run!()

unique([agent.cultureVector for agent in test])
