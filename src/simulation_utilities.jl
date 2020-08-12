function create_agents(agentcount, stubbornfrac)
	agents = Agent[]
	realagentlimit = round(Int64, (1 - stubbornfrac) * agentcount)
	stubbornlimit = agentcount - realagentlimit
	for i in 1:realagentlimit
		push!(agents, Agent(rand(0:9, 5)))
	end
	for i in 1:stubbornlimit
		push!(agents, Agent(fill(0, 5), true))
	end
	return agents
end

function init_agentdf(agents)
	return DataFrame(
		TickNr = 0,
		AgentID = 1:length(deepcopy(agents)),
		CultureTmp = [agent.culture for agent in deepcopy(agents)]
	)
end

function append_state!(df, agents, ticknr)
	append!(
		df,
		DataFrame(
			TickNr = ticknr,
			AgentID = 1:length(deepcopy(agents)),
			CultureTmp = [agent.culture for agent in deepcopy(agents)]
		)
	)
	return df
end

function prune_network!(network, agents)
	nottalking = Array{Edge, 1}()
	for agent_id in vertices(network), neighbor_id in neighbors(network, agent_id)
		similarity = compute_similarity(agents[agent_id], agents[neighbor_id])
		if similarity == 0
			push!(nottalking, Edge(agent_id, neighbor_id))
		end
	end
	for edge in nottalking
		rem_edge!(network, edge)
	end
	return network
end

function init_progressbar(repcount, experiment_name)
	println()
	println("Running: " * experiment_name * " ")
	print("[" * (" " ^ repcount) * "] " * "0 repetitions finished")
end

function update_progressbar(rep, repcount)
	REPL.Terminals.clear_line(REPL.Terminals.TTYTerminal("", stdin, stdout, stderr))
	print("[" * ("=" ^ rep) * (" " ^ (repcount - rep)) * "] " * string(rep) * " repetitions finished")
	if rep == repcount
		print("\nDone.")
	end
end
