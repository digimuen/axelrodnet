function tick!(
	agents::AbstractArray,
	network::AbstractGraph
)
	acting_agent = StatsBase.sample(agents)
	interaction_partner = draw_interaction_partner(agents, network, acting_agent)
	if !acting_agent.stubborn
		similarity = compute_similarity(acting_agent, interaction_partner)
		if (rand() < similarity) && (similarity != 1)
			assimilate!(agents, acting_agent, interaction_partner)
		end
	end
	return (agents, network)
end

function draw_interaction_partner(
	agents::AbstractArray,
	network::AbstractGraph,
	agent::Agent
)
	agent_neighbors = LightGraphs.neighbors(network, agent.id)
	interaction_partner_id = rand(agent_neighbors)
	interaction_partner = agents[interaction_partner_id]
	return interaction_partner
end

function compute_similarity(
	acting_agent::Agent,
	interaction_partner::Agent
)
	shared_traits = sum(
		[
			i == j
			for (i, j) in zip(acting_agent.culture, interaction_partner.culture)
		]
	)
	similarity = shared_traits / length(acting_agent.culture)
	return similarity
end

function assimilate!(
	agents::AbstractArray,
	acting_agent::Agent,
	interaction_partner::Agent
)
	random_attr = rand(1:length(acting_agent.culture))
	if !(acting_agent.culture[random_attr] == interaction_partner.culture[random_attr])
		acting_agent.culture[random_attr] = interaction_partner.culture[random_attr]
	else
		assimilate!(agents, acting_agent, interaction_partner)
	end
	return acting_agent
end
