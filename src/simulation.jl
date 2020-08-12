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
    exportmode::String,
    keep_rawnet::Bool
)
    experiment = Axelrodnet.run(
		experiment_name=experiment_name,
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
	init_progressbar(repcount, experiment_name)
	for rep in 1:repcount
		agents = create_agents(agentcount, stubbornfrac)
		network = create_network(nettopology, agentcount, networkprops)
		df = init_agentdf(agents)
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
		update_progressbar(rep, repcount)
	end
	if keep_rawnet
		return (data, networks, networks_raw)
	else
		return (data, networks)
	end
end
