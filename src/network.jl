function create_network(
	nettopology::String,
	agentcount::Int64,
	networkprops::Dict
)
	if nettopology == "grid"
		network = LightGraphs.grid(agentcount, networkprops)
	elseif nettopology == "erdos_renyi"
		network = LightGraphs.erdos_renyi(agentcount, networkprops["p"])
	elseif nettopology == "watts_strogatz"
		network = LightGraphs.watts_strogatz(agentcount, networkprops["k"], networkprops["beta"])
	elseif nettopology == "barabasi_albert"
		network = LightGraphs.barabasi_albert(agentcount, networkprops["m0"])
	elseif nettopology == "complete"
		network = LightGraphs.complete_graph(agentcount)
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
		network = LightGraphs.grid(Int64[agentcount, 1])
		return network
	end
end

function default_network(agentcount::Int64, networkprops::Dict)
	network = LightGraphs.grid(agentcount, networkprops)
	return network
end
