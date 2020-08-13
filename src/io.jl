function export_experiment(;
	experiment::Union{Tuple{Any, Any}, Tuple{Any, Any, Any}},
	experiment_name::String="default",
	stubborncount::Int64=0,
	networkprops::Dict=Dict(),
	exportmode::String="default"
)
	path = joinpath("experiments", experiment_name)
	create_experiment_directory(experiment_name)
	export_graphs(
		experiment=experiment,
		path=path
	)
	export_agentdata(
		experiment=experiment,
		path=path,
		exportmode=exportmode,
		stubborncount=stubborncount,
		networkprops=networkprops
	)
	return true
end

function export_graphs(;
	experiment::Union{Tuple{Any, Any}, Tuple{Any, Any, Any}},
	path::String
)
	for key in keys(experiment[2])
		LightGraphs.savegraph(
			joinpath(path, "graphs", "rep_" * lpad(string(key), 2, "0") * ".gml"),
			experiment[2][key],
			GraphIO.GML.GMLFormat()
		)
		if length(experiment) == 3
			LightGraphs.savegraph(
				joinpath(path, "graphs", "repraw_" * lpad(string(key), 2, "0") * ".gml"),
				experiment[3][key],
				GraphIO.GML.GMLFormat()
			)
		end
	end
	return true
end

function export_agentdata(;
	experiment::Union{Tuple{Any, Any}, Tuple{Any, Any, Any}},
	path::String,
	exportmode::String,
	stubborncount::Int64,
	networkprops::Dict
)
	for key in keys(experiment[1])
		join_cultures!(experiment[1][key])
	end
	if exportmode == "aggregated"
		export_aggregated(
			experiment=experiment,
			path=path,
			stubborncount=stubborncount,
			networkprops=networkprops
		)
	elseif exportmode == "separate_dataframes"
		export_separate_dataframes(
			experiment=experiment,
			path=path
		)
	else
		export_default(
			experiment=experiment,
			path=path,
			stubborncount=stubborncount,
			networkprops=networkprops
		)
	end
end

function export_aggregated(;
	experiment::Union{Tuple{Any, Any}, Tuple{Any, Any, Any}},
	path::String,
	stubborncount::Int64,
	networkprops::Dict
)
	agentdata_array = experiment[1]
	aggregated_dataframe = aggregate_data(agentdata_array, stubborncount, networkprops)
	Feather.write(
		joinpath(path, "agents", "adata.feather"),
		aggregated_dataframe
	)
	return true
end

function export_separate_dataframes(;
	experiment::Union{Tuple{Any, Any}, Tuple{Any, Any, Any}},
	path::String
)
	agentdata_array = experiment[1]
	for (replicate, agent_dataframe) in enumerate(agentdata_array)
		Feather.write(
			joinpath(path, "agents", "adata_rep" * string(replicate) * ".feather"),
			agent_dataframe
		)
	end
	return true
end

function export_default(;
	experiment::Union{Tuple{Any, Any}, Tuple{Any, Any, Any}},
	path::String,
	stubborncount::Int64,
	networkprops::Dict
)
	agentdata_array = experiment[1]
	agent_dataframe = reduce(vcat, agentdata_array)
	Feather.write(
		joinpath(path, "agents", "adata.feather"),
		agent_dataframe
	)
	return true
end
