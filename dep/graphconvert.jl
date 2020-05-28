function convert2weightedGraph(
    network::AbstractGraph,
	agents::AbstractArray
    )

	src_network = deepcopy(network)

	weighted_net = SimpleWeightedGraph(nv(src_network))

	for v in vertices(src_network)
		for neighbor in neighbors(src_network, v)
			weighted_distance = sum(agents[v].cultureVector .- agents[neighbor].cultureVector)
			add_edge!(weighted_net, v, neighbor, weighted_distance)
			rem_edge!(src_network, v, neighbor)
		end
	end

	return weighted_net
end
