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

end

function tick!(
	network::AbstractGraph,
	agents::AbstractArray
)
	random_draw = rand(1:length(agents))
	acting_agent = agents[random_draw]
	interaction_partner = agents[rand(neighbors(network,random_draw))]

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
	agentcount::Int64=100,
	n_iter::Int64=1000,
	socialbotfrac::Float64=0.00,
	m0::Int64=5,
	rndseed::Int64=1,
	repcount::Int64=1
)

	Random.seed!(MersenneTwister(rndseed))

	regioncounts = DataFrame(RegionCount = Any[])
	df = DataFrame(RepNr = Int64[], AgentID = Int64[], Culture = Any[])

	for rep in 1:repcount

		agents = Agent[]

		for i in 1:round(Int64, (1-socialbotfrac)*agentcount)
			push!(agents, Agent(rand(0:9, 5)))
		end

		realagents = length(agents)

		for i in 1:(agentcount - realagents)
			push!(agents, Agent(fill(0, 5), true))
		end

		network = barabasi_albert(length(agents),m0)

		regioncount_list = Int64[]

		for i in 1:n_iter
			tick!(network,agents)
			push!(
				regioncount_list,
				length(unique([agent.cultureVector for agent in agents]))
			)
		end

		regioncount = DataFrame(RegionCount = [regioncount_list])

		append!(
			df,
			DataFrame(
				RepNr = rep,
				AgentID = 1:length(agents),
				Culture = [agent.cultureVector for agent in agents]
			)
		)

		append!(regioncounts, regioncount)

	end

	return regioncounts, df

end
