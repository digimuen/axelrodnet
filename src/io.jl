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
		reshape_df!(experiment[1][key])
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

function reshape_df!(dataframe::DataFrames.DataFrame)
	dataframe[!, "Culture"] = [join(c) for c in dataframe[!, "CultureTmp"]]
	select!(dataframe, DataFrames.Not(:CultureTmp))
	return dataframe
end

function export_aggregated(;
	experiment::Union{Tuple{Any, Any}, Tuple{Any, Any, Any}},
	path::String,
	stubborncount::Int64,
	networkprops::Dict
)
	agentdata_dict = experiment[1]
	aggregated_dataframe = DataFrames.DataFrame(
		Rep = Int64[],
		Size = Int64[],
		Culture = String[]
	)
	for key in keys(agentdata_dict)
		replicate_dataframe = agentdata_dict[key]
		finaltick = filter(
			:TickNr => ==(maximum(replicate_dataframe[!, "TickNr"])),
			replicate_dataframe
		)
		replicate = key
		unique_cultures = unique(finaltick[!, "Culture"])
		for culture in unique_cultures
			size = sum([c == culture for c in finaltick[!, "Culture"]])
			row = (replicate, size, culture)
			push!(aggregated_dataframe, row)
		end
	end
	aggregated_dataframe[!, "StubbornCount"] .= stubborncount
	for key in keys(networkprops)
		varname = to_camelcase(key)
		aggregated_dataframe[!, varname] .= networkprops[key]
	end
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
	agentdata_dict = experiment[1]
	for key in keys(agentdata_dict)
		replicate_dataframe = agentdata_dict[key]
		Feather.write(
			joinpath(path, "agents", "adata_rep" * string(key) * ".feather"),
			replicate_dataframe
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
	agentdata_dict = experiment[1]
	full_dataframe = DataFrames.DataFrame(
		Replicate = Int64[],
		TickNr = Int64[],
		AgentID = Int64[],
		Culture = String[]
	)
	for key in keys(agentdata_dict)
		replicate_dataframe = agentdata_dict[key]
		replicate_dataframe[!, "Replicate"] .= key
		append!(
			full_dataframe,
			replicate_dataframe
		)
	end
	full_dataframe[!, "StubbornCount"] .= stubborncount
	for key in keys(networkprops)
		varname = to_camelcase(key)
		full_dataframe[!, varname] .= networkprops[key]
	end
	Feather.write(
		joinpath(path, "agents", "adata.feather"),
		full_dataframe
	)
	return true
end
