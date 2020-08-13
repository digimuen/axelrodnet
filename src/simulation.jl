function run_experiment(;
    experiment_name::String,
    agentcount::Int64,
    n_iter::Int64,
    nettopology::String,
    networkprops::Dict,
    stubborncount::Int64,
    rndseed::Int64,
    n_replicates::Int64,
    export_every_n::Int64,
    exportdata::Bool,
    exportmode::String,
    keep_rawnet::Bool
)
    experiment = run(
		experiment_name=experiment_name,
        agentcount=agentcount,
        n_iter=n_iter,
        nettopology=nettopology,
        networkprops=networkprops,
        stubborncount=stubborncount,
        rndseed=rndseed,
        n_replicates=n_replicates,
        export_every_n=export_every_n,
		keep_rawnet=keep_rawnet
    )
    if exportdata
        export_experiment(
            experiment=experiment,
            experiment_name=experiment_name,
            stubborncount=stubborncount,
            networkprops=networkprops,
            exportmode=exportmode
        )
    end
    return experiment
end

function run(;
	experiment_name::String="default",
	agentcount::Int64=100,
	n_iter::Int64=1000,
	nettopology::String="grid",
	networkprops::Dict=Dict(),
	stubborncount::Int64=0,
	rndseed::Int64=1,
	n_replicates::Int64=1,
	export_every_n::Int64=100,
	keep_rawnet::Bool=false
)
	agentcount, nettopology, networkprops, stubborncount = assert_input_parameters(
		agentcount,
		nettopology,
		networkprops,
		stubborncount
	)
	Random.seed!(Random.MersenneTwister(rndseed))
	networks = Dict{Int64, LightGraphs.AbstractGraph}()
	networks_raw = Dict{Int64, LightGraphs.AbstractGraph}()
	agentdata_array = DataFrames.DataFrame[]
	init_progressbar(n_replicates, experiment_name)
	for replicate in 1:n_replicates
		agents = create_agents(agentcount, stubborncount)
		network = create_network(nettopology, agentcount, networkprops)
		agent_dataframe = init_agentdf(agents)
		for ticknr in 1:n_iter
			tick!(agents, network)
			if ticknr % export_every_n == 0
				append_state!(agent_dataframe, agents, ticknr)
			end
		end
		add_constant_parameters!(agent_dataframe, networkprops, stubborncount, replicate)
		push!(agentdata_array, deepcopy(agent_dataframe))
		if keep_rawnet
			networks_raw[replicate] = deepcopy(network)
			networks[replicate] = prune_network!(network, agents)
		else
			networks[replicate] = network
		end
		update_progressbar(replicate, n_replicates)
	end
	if keep_rawnet
		return (agentdata_array, networks, networks_raw)
	else
		return (agentdata_array, networks)
	end
end
