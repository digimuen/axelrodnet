function create_agents(agentcount::Int64, stubborncount::Int64)
	agents = Agent[]
	for i in 1:stubborncount
		push!(agents, Agent(fill(0, 5), true))
	end
	for i in (stubborncount + 1):agentcount
		push!(agents, Agent(rand(0:9, 5)))
	end
	return agents
end

function init_agentdf(agents::AbstractArray)
	return DataFrames.DataFrame(
		TickNr = 0,
		AgentID = 1:length(deepcopy(agents)),
		CultureTmp = [agent.culture for agent in deepcopy(agents)]
	)
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
			AgentID = 1:length(deepcopy(agents)),
			CultureTmp = [agent.culture for agent in deepcopy(agents)]
		)
	)
	return dataframe
end

function prune_network!(
	network::LightGraphs.AbstractGraph,
	agents::AbstractArray
)
	nottalking = Array{Edge, 1}()
	for agent_id in LightGraphs.vertices(network), neighbor_id in LightGraphs.neighbors(network, agent_id)
		similarity = compute_similarity(agents[agent_id], agents[neighbor_id])
		if similarity == 0
			push!(nottalking, LightGraphs.Edge(agent_id, neighbor_id))
		end
	end
	for edge in nottalking
		LightGraphs.rem_edge!(network, edge)
	end
	return network
end

function init_progressbar(repcount::Int64, experiment_name::String)
	println()
	println("Running: " * experiment_name * " ")
	print("[" * (" " ^ repcount) * "] " * "0 repetitions finished")
end

function update_progressbar(rep::Int64, repcount::Int64)
	REPL.Terminals.clear_line(REPL.Terminals.TTYTerminal("", stdin, stdout, stderr))
	print("[" * ("=" ^ rep) * (" " ^ (repcount - rep)) * "] " * string(rep) * " repetitions finished")
	if rep == repcount
		print("\nDone.")
	end
end

function to_camelcase(varname::String)
	varname_split_titlecase = titlecase.(split(deepcopy(varname), "_"))
	varname_modified = join(varname_split_titlecase, "")
	return varname_modified
end
