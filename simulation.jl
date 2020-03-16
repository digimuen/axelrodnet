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

	if !acting_agent.socialbot

		similarity = sum([i == j for (i, j) in zip(acting_agent.cultureVector, interaction_partner.cultureVector)]) / length(acting_agent.cultureVector)

		if rand() < similarity && similarity != 1
			assimilate!(agents, acting_agent, interaction_partner)
		end
	end

	return (network, agents)
end

using Random
MersenneTwister(1234)

function run!(
	;
	agentcount = 100,
	n_iter = 1000,
	socialbotfrac = 0.05,
	m0 = 50,
	rndseed = 1,
	repcount = 100
	)

	Random.seed!(MersenneTwister(rndseed))

	for i in 1:repcount

		agents = Agent[]

		for i in 1:round(Int64, (1-socialbotfrac)*agentcount)
			push!(agents, Agent(rand(0:9,5)))
		end

		realagents = length(agents)

		for i in 1:(agentcount - realagents)
			push!(agents, Agent(fill(0,5), true))
		end

		network = barabasi_albert(length(agents),m0)

		regioncount = Int64[]

		for i in 1:n_iter
			tick!(network,agents)
			push!(regioncount,length(unique([agent.cultureVector for agent in agents])))
		end

		df = DataFrame(AgentID = 1:length(agents), Culture = [agent.cultureVector for agent in agents])

	end

	return agents, regioncount, df
end
