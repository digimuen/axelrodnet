function create_agents(agentcount::Int64, stubborncount::Int64)
	agents = Agent[]
	for i in 1:(agentcount - stubborncount)
		push!(agents, Agent(i, rand(0:9, 5)))
	end
	for i in (agentcount - stubborncount + 1):agentcount
		push!(agents, Agent(i, fill(0, 5), true))
	end
	return agents
end

function append_state!(
	dataframe::DataFrames.DataFrame,
	agents::AbstractArray,
	ticknr::Int64
)
	append!(
		dataframe,
		DataFrames.DataFrame(
			TickNr = ticknr,
			AgentID = [agent.id for agent in deepcopy(agents)],
			CultureTmp = [agent.culture for agent in deepcopy(agents)]
		)
	)
	return dataframe
end

function prune_network!(
	network::LightGraphs.AbstractGraph,
	agents::AbstractArray
)
	edges_to_remove = Array{Edge, 1}()
	for agent_id in LightGraphs.vertices(network)
		for neighbor_id in LightGraphs.neighbors(network, agent_id)
			similarity = compute_similarity(agents[agent_id], agents[neighbor_id])
			if similarity == 0
				push!(edges_to_remove, LightGraphs.Edge(agent_id, neighbor_id))
			end
		end
	end
	for edge in edges_to_remove
		LightGraphs.rem_edge!(network, edge)
	end
	return network
end

function init_progressbar(n_replicates::Int64, experiment_name::String)
	println()
	println("Running: " * experiment_name * " ")
	print("[" * (" " ^ n_replicates) * "] " * "0 repetitions finished")
end

function update_progressbar(current_replicate::Int64, n_replicates::Int64)
	REPL.Terminals.clear_line(REPL.Terminals.TTYTerminal("", stdin, stdout, stderr))
	print(
		"[" * ("=" ^ current_replicate) * (" " ^ (n_replicates - current_replicate)) * "] "
		* string(current_replicate) * " repetitions finished"
	)
	if current_replicate == n_replicates
		print("\nDone.")
	end
end

function init_agentdf(agents::AbstractArray)
	return DataFrames.DataFrame(
		TickNr = 0,
		AgentID = [agent.id for agent in deepcopy(agents)],
		CultureTmp = [agent.culture for agent in deepcopy(agents)]
	)
end

function add_constant_parameters!(
	dataframe::DataFrames.DataFrame,
	networkprops::Dict,
	stubborncount::Int64,
	replicate::Int64
)
	add_constant_parameters!(dataframe, networkprops, stubborncount)
	dataframe[!, "Replicate"] .= replicate
end

function add_constant_parameters!(
	dataframe::DataFrames.DataFrame,
	networkprops::Dict,
	stubborncount::Int64
)
	dataframe[!, "StubbornCount"] .= stubborncount
	for key in keys(networkprops)
		varname = to_camelcase(key)
		dataframe[!, varname] .= networkprops[key]
	end
	return dataframe
end

function to_camelcase(varname::String)
	varname_split_titlecase = titlecase.(split(deepcopy(varname), "_"))
	varname_modified = join(varname_split_titlecase, "")
	return varname_modified
end


function join_cultures!(dataframe::DataFrames.DataFrame)
	dataframe[!, "Culture"] = [join(c) for c in dataframe[!, "CultureTmp"]]
	select!(dataframe, DataFrames.Not(:CultureTmp))
	return dataframe
end

function aggregate_data(
	agentdata::Array{DataFrames.DataFrame, 1},
	stubborncount::Int64,
	networkprops::Dict
)
	aggregated_dataframe = DataFrames.DataFrame(
		Replicate = Int64[],
		Size = Int64[],
		Culture = String[]
	)
	for (replicate, agent_dataframe) in enumerate(agentdata)
		finaltick = filter(
			:TickNr => ==(maximum(agent_dataframe[!, "TickNr"])),
			agent_dataframe
		)
		unique_cultures = unique(finaltick[!, "Culture"])
		for culture in unique_cultures
			size = sum([c == culture for c in finaltick[!, "Culture"]])
			row = (replicate, size, culture)
			push!(aggregated_dataframe, row)
		end
	end
	add_constant_parameters!(aggregated_dataframe, networkprops, stubborncount)
	return aggregated_dataframe
end

function create_experiment_directory(experiment_name::String)
	if !("experiments" in readdir())
		mkdir("experiments")
	end
	if !(experiment_name in readdir("experiments"))
		mkdir(joinpath("experiments", experiment_name))
	end
	if !("agents" in readdir(joinpath("experiments", experiment_name)))
		mkdir(joinpath("experiments", experiment_name, "agents"))
	end
	if !("graphs" in readdir(joinpath("experiments", experiment_name)))
		mkdir(joinpath("experiments", experiment_name, "graphs"))
	end
	return true
end
