function assimilate!(
	agents::AbstractArray,
	acting_agent::Agent,
	interaction_partner::Agent
)

	random_attr = rand(1:length(acting_agent.cultureVector))

	if acting_agent.cultureVector[random_attr] - interaction_partner.cultureVector[random_attr] != 0
		acting_agent.cultureVector[random_attr] = interaction_partner.cultureVector[random_attr]
	else
		assimilate!(agents, acting_agent, interaction_partner)
	end

	return acting_agent

end

function create_network(nettopology::Int64, agentcount::Int64, m0::Int64)
	if nettopology == 1
		network = grid([Int(sqrt(agentcount)), Int(sqrt(agentcount))])
	elseif nettopology == 2
		network = barabasi_albert(agentcount, m0)
	elseif nettopology == 3
		network = complete_graph(agentcount)
	else
		network = grid([Int(sqrt(agentcount)), Int(sqrt(agentcount))])
		print(
			"""
			irregular input for nettopology
			defaulted to grid
			choose one of the following to specify network topology:
			- nettopology=1 (grid graph)
			- nettopology=2 (barabasi-albert graph)
			- nettopology=3 (complete graph)
			"""
		)
	end
	return network
end

function tick!(
	network::AbstractGraph,
	agents::AbstractArray
)

	random_draw = rand(1:length(agents))
	acting_agent = agents[random_draw]

	interaction_partner = agents[rand(neighbors(network, random_draw))]

	if !acting_agent.socialbot

		similarity = sum(
			[
				i == j
				for (i, j) in zip(
					acting_agent.cultureVector,
					interaction_partner.cultureVector
				)
			]
		) / length(acting_agent.cultureVector)

		if rand() < similarity && similarity != 1
			assimilate!(agents, acting_agent, interaction_partner)
		end
	end

	return (network, agents)
end

function run!(
	;
	sqrt_agentcount::Int64=10,
	n_iter::Int64=1000,
	socialbotfrac::Float64=0.00,
	m0::Int64=5,
	rndseed::Int64=1,
	repcount::Int64=1,
	nettopology::Int64=1,
	export_every_n::Int64=100
)

	Random.seed!(MersenneTwister(rndseed))

	agentcount = sqrt_agentcount^2

	networks = Dict{Int64, AbstractGraph}()
	data = Dict{Int64, DataFrame}()

	for rep in 1:repcount

		df = DataFrame(
			TickNr = Int64[],
			AgentID = Int64[],
			Culture = Any[]
		)

		agents = Agent[]

		for i in 1:round(Int64, (1 - socialbotfrac) * agentcount)
			push!(agents, Agent(rand(0:9, 5)))
		end

		realagents = length(agents)

		for i in 1:(agentcount - realagents)
			push!(agents, Agent(fill(0, 5), true))
		end

		network = create_network(nettopology, agentcount, m0)
		networks[rep] = network

		state = Tuple{AbstractGraph, Array{Agent, 1}}[]

		for i in 1:n_iter
			tick!(network, agents)
			if i % export_every_n == 0
				append!(
					df,
					DataFrame(
						TickNr = i,
						AgentID = 1:length(agents),
						Culture = [agent.cultureVector for agent in agents]
					)
				)
			end

		end  # end iter

		data[rep] = df

		print(".")

	end  # end rep

	return (data, networks)

end
