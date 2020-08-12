function create_network(
	nettopology::String,
	agentcount::Int64,
	networkprops::Dict
)
	if nettopology == "grid"
		network = grid(agentcount, networkprops)
	elseif nettopology == "erdos_renyi"
		network = erdos_renyi(agentcount, networkprops["p"])
	elseif nettopology == "watts_strogatz"
		network = watts_strogatz(agentcount, networkprops["k"], networkprops["beta"])
	elseif nettopology == "barabasi_albert"
		network = barabasi_albert(agentcount, networkprops["m0"])
	elseif nettopology == "complete"
		network = complete_graph(agentcount)
	else
		network = default_network(agentcount, networkprops)
	end
	return network
end

function LightGraphs.grid(agentcount::Int64, networkprops::Dict)
	try
		height = Int(networkprops["grid_height"])
		width = Int(agentcount / height)
		network = LightGraphs.grid([height, width])
		return network
	catch
		print(
			"""
			No/Faulty grid height provided
			defaulting to grid with dimensions [agentcount, 1]
			"""
		)
		network = LightGraphs.grid(Int64[agentcount, 1])
		return network
	end
end

function default_network(agentcount::Int64, networkprops::Dict)
	network = grid(agentcount, networkprops)
	print(
		"""
		irregular input for nettopology
		defaulting to grid
		"""
	)
	return network
end
