function run_experiment(;
    experiment_name::String,
    agentcount::Int64,
    n_iter::Int64,
    nettopology::String,
    networkprops::Dict,
    stubborncount::Int64,
    rndseed::Int64,
    repcount::Int64,
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
        repcount=repcount,
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
	repcount::Int64=1,
	export_every_n::Int64=100,
	keep_rawnet::Bool=false
)
	Random.seed!(Random.MersenneTwister(rndseed))
	networks = Dict{Int64, LightGraphs.AbstractGraph}()
	networks_raw = Dict{Int64, LightGraphs.AbstractGraph}()
	agentdata = Dict{Int64, DataFrames.DataFrame}()
	init_progressbar(repcount, experiment_name)
	for rep in 1:repcount
		agents = create_agents(agentcount, stubborncount)
		network = create_network(nettopology, agentcount, networkprops)
		agentdf = init_agentdf(agents)
		for ticknr in 1:n_iter
			tick!(agents, network)
			if ticknr % export_every_n == 0
				append_state!(agentdf, agents, ticknr)
			end
		end
		agentdata[rep] = agentdf
		if keep_rawnet
			networks_raw[rep] = deepcopy(network)
			networks[rep] = prune_network!(network, agents)
		else
			networks[rep] = network
		end
		update_progressbar(rep, repcount)
	end
	if keep_rawnet
		return (agentdata, networks, networks_raw)
	else
		return (agentdata, networks)
	end
end
