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
end

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
	return (network, agents)
end

function draw_interaction_partner(agents, network, agent_id::Int64)
	agent_neighbors = LightGraphs.neighbors(network, agent_id)
	interaction_partner_id = rand(agent_neighbors)
	return agents[interaction_partner_id]
end

function compute_similarity(acting_agent::Agent, interaction_partner::Agent)
	shared_traits = sum(
		[
			i == j
			for (i, j) in zip(acting_agent.culture, interaction_partner.culture)
		]
	)
	similarity = shared_traits / length(acting_agent.culture)
	return similarity
end

function run(;
	agentcount::Int64=100,
	n_iter::Int64=1000,
	nettopology::String="grid",
	networkprops::Dict=Dict(),
	stubbornfrac::Float64=0.00,
	rndseed::Int64=1,
	repcount::Int64=1,
	export_every_n::Int64=100,
	keep_rawnet::Bool=false
)

	Random.seed!(MersenneTwister(rndseed))

	networks = Dict{Int64, AbstractGraph}()
	networks_raw = Dict{Int64, AbstractGraph}()
	data = Dict{Int64, DataFrame}()

	for rep in 1:repcount
		agents = create_agents(agentcount, stubbornfrac)
		network = create_network(nettopology, agentcount, networkprops)

		df = DataFrame(
			TickNr = 0,
			AgentID = 1:length(deepcopy(agents)),
			CultureTmp = [agent.culture for agent in deepcopy(agents)]
		)

		for ticknr in 1:n_iter
			tick!(agents, network)
			if ticknr % export_every_n == 0
				append_state!(df, agents, ticknr)
			end
		end

		data[rep] = df
		if keep_rawnet
			networks_raw[rep] = deepcopy(network)
			networks[rep] = prune_network!(network, agents)
		else
			networks[rep] = network
		end

		print("=")
	end

	if keep_rawnet
		return (data, networks, networks_raw)
	else
		return (data, networks)
	end

end

function prune_network!(network, agents)
	nottalking = Array{Edge, 1}()
	for v in vertices(network)
		for neighbor in neighbors(network, v)
			if !(
				0 in (agents[v].culture .- agents[neighbor].culture)
			)
				push!(nottalking, Edge(v, neighbor))
			end
		end
	end
	for e in nottalking
		rem_edge!(network, e)
	end
	return network
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

function run_experiment(;
    experiment_name::String,
    agentcount::Int64,
    n_iter::Int64,
    nettopology::String,
    networkprops::Dict,
    stubbornfrac::Float64,
    rndseed::Int64,
    repcount::Int64,
    export_every_n::Int64,
    export_experiment::Bool,
    aggregated::Int64,
    keep_rawnet::Bool
)
    experiment = Axelrodnet.run(
        agentcount=agentcount,
        n_iter=n_iter,
        nettopology=nettopology,
        networkprops=networkprops,
        stubbornfrac=stubbornfrac,
        rndseed=rndseed,
        repcount=repcount,
        export_every_n=export_every_n,
		keep_rawnet=keep_rawnet
    )
    if export_experiment
        Axelrodnet.export_experiment(
            experiment=experiment,
            experiment_name=experiment_name,
            stubbornfrac=stubbornfrac,
            networkprops=networkprops,
            aggregated=aggregated
        )
    end
    return experiment
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

function export_experiment(;
	experiment,
	experiment_name::String="default",
	stubbornfrac::Float64=0.0,
	networkprops::Dict=Dict(),
	aggregated::Int64=0
)
	path = joinpath("experiments", experiment_name)
	create_experiment_directory(experiment_name)
	export_graphs(experiment, path)

    for key in keys(experiment[1])
        reshape_df!(experiment[1][key])
    end

	if aggregated == 2
		agg_df = DataFrame(
			Rep = Int64[],
			Size = Int64[],
			Culture = String[]
		)
		for key in keys(experiment[1])
			df = experiment[1][key]
			finaltick = filter(:TickNr => ==(maximum(df[!, "TickNr"])), df)
			rep = key
			unique_cultures = unique(finaltick[!, "Culture"])
			for c in unique_cultures
				push!(
					agg_df,
					(
						rep,
						sum([culture == c for culture in finaltick[!, "Culture"]]),
						c
					)
				)
			end
		end
		agg_df[!, "StubbornFrac"] .= stubbornfrac
		for k in keys(networkprops)
			agg_df[!, k] .= networkprops[k]
		end

		Feather.write(joinpath(path, "agents", "adata.feather"), agg_df)
	elseif aggregated == 1
	    # export entire data
		full_df = DataFrame(
			Rep = Int64[],
			TickNr = Int64[],
			AgentID = Int64[],
			Culture = String[]
		)

		for key in keys(experiment[1])
			df = experiment[1][key]
			rep = key
			append!(
				full_df,
				DataFrame(
					Rep = rep,
					TickNr = df[!, "TickNr"],
					AgentID = df[!, "AgentID"],
					Culture = df[!, "Culture"]
				)
			)
		end
		full_df[!, "StubbornFrac"] .= stubbornfrac
		for k in keys(networkprops)
			full_df[!, k] .= networkprops[k]
		end

		Feather.write(joinpath(path, "agents", "adata.feather"), full_df)
	else
		for key in keys(experiment[1])
			df = DataFrame(
				TickNr = experiment[1][key][!, "TickNr"],
				AgentID = experiment[1][key][!, "AgentID"],
				Culture = experiment[1][key][!, "Culture"]
			)

			Feather.write(joinpath(path, "agents", "adata_rep" * string(key) * ".feather"), df)
		end
	end

end

function reshape_df!(df)
	df[!, "Culture"] = [join(c) for c in df[!, "CultureTmp"]]
	select!(df, DataFrames.Not(:CultureTmp))
	return df
end

function export_graphs(experiment, path)
	for key in keys(experiment[2])
		savegraph(
			joinpath(path, "graphs", "rep_" * lpad(string(key), 2, "0") * ".gml"),
			experiment[2][key],
			GraphIO.GML.GMLFormat()
		)
		if length(experiment) == 3
			savegraph(
				joinpath(path, "graphs", "repraw_" * lpad(string(key), 2, "0") * ".gml"),
				experiment[3][key],
				GraphIO.GML.GMLFormat()
			)
		end
	end
	return true
end
