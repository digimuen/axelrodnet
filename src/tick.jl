function tick!(
	agents::AbstractArray,
	network::AbstractGraph
)
	agent_id = rand(1:length(agents))
	acting_agent = agents[agent_id]
	interaction_partner = draw_interaction_partner(agents, network, agent_id)
	if !acting_agent.stubborn
		similarity = compute_similarity(acting_agent, interaction_partner)
		if rand() < similarity && similarity != 1
			assimilate!(agents, acting_agent, interaction_partner)
		end
	end
	return (agents, network)
end

function draw_interaction_partner(
	agents::AbstractArray,
	network::AbstractGraph,
	agent_id::Int64
)
	agent_neighbors = LightGraphs.neighbors(network, agent_id)
	interaction_partner_id = rand(agent_neighbors)
	return agents[interaction_partner_id]
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
