function assert_input_parameters(
	agentcount::Int64,
	nettopology::String,
	networkprops::Dict,
	stubborncount::Int64
)
	if stubborncount > agentcount
		stubborncount = trunc(Int64, agentcount / 10)
		print_warning(
			"agentcount must be greater than stubborncount",
			"stubborncount", stubborncount
		)
	end
	if nettopology == "grid"
		handle_faulty_grid_params!(networkprops, agentcount)
	elseif nettopology == "watts_strogatz"
		handle_faulty_watts_strogatz_params!(networkprops, agentcount)
	elseif nettopology == "barabasi_albert"
		handle_faulty_barabasi_albert_params!(networkprops, agentcount)
	end
	return agentcount, nettopology, networkprops, stubborncount
end

function handle_faulty_grid_params!(networkprops, agentcount)
	if !("grid_height" in keys(networkprops))
		grid_height = 1
		print_warning(
			"parameter 'grid_height' is missing from networkprops",
			"grid_height", grid_height
		)
		networkprops["grid_height"] = grid_height
	else
		if (agentcount % networkprops["grid_height"]) != 0
			grid_height = 1
			print_warning(
				"agentcount must be divisible by grid_height",
				"grid_height", grid_height
			)
			networkprops["grid_height"] = grid_height
		end
	end
	return networkprops
end

function handle_faulty_watts_strogatz_params!(networkprops, agentcount)
	if !("k" in keys(networkprops))
		k = 2
		print_warning(
			"parameter 'k' is missing from networkprops",
			"k", k
		)
		networkprops["k"] = 2
	end
	if !("beta" in keys(networkprops))
		beta = 0.5
		print_warning(
			"parameter 'beta' is missing from networkprops",
			"beta", beta
		)
		networkprops["beta"] = beta
	end
	if "k" in keys(networkprops)
		if networkprops["k"] <= 0
			k = 2
			print_warning(
				"parameters 'k' must be greater than 0",
				"k", k
			)
			networkprops["k"] = k
		end
		if networkprops["k"] > (agentcount / 10)
			k = trunc(Int64, (agentcount / 10))
			print_warning(
				"Watts-Strogatz model requires n >> k",
				"k", k
			)
			networkprops["k"] = k
		end
	end
	if "beta" in keys(networkprops)
		if (networkprops["beta"] < 0) | (networkprops["beta"] > 1)
			beta = 0.5
			print_warning(
				"parameter 'beta' must be between 0 and 1",
				"beta", beta
			)
			networkprops["beta"] = 0.5
		end
	end
	return networkprops
end

function handle_faulty_barabasi_albert_params!(networkprops, agentcount)
	if !("m0" in keys(networkprops))
		m0 = trunc(Int64, (agentcount / 10))
		print_warning(
			"parameter 'm0' is missing from networkprops",
			"m0", m0
		)
		networkprops["m0"] = m0
	else
		if networkprops["m0"] > agentcount
			m0 = trunc(Int64, (agentcount / 10))
			print_warning(
				"Barabási-Albert model requires m0 < agentcount",
				"m0", m0
			)
			networkprops["m0"] = m0
		end
	end
	return networkprops
end

function print_warning(message::String, varname::String, default_value::Any)
	println("WARNING: " * message)
	println("         defaulted to " * varname * " = $default_value")
end
