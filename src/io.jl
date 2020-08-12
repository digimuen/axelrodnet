function export_experiment(;
	experiment,
	experiment_name::String="default",
	stubbornfrac::Float64=0.0,
	networkprops::Dict=Dict(),
	exportmode::String="default"
)
	path = joinpath("experiments", experiment_name)
	create_experiment_directory(experiment_name)
	export_graphs(experiment, path)
	export_agentdata(experiment, path, exportmode, stubbornfrac, networkprops)
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

function export_agentdata(experiment, path, exportmode::String, stubbornfrac, networkprops)
	for key in keys(experiment[1])
		reshape_df!(experiment[1][key])
	end
	if exportmode == "aggregated"
		export_aggregated(experiment, path, stubbornfrac, networkprops)
	elseif exportmode == "separate_dataframes"
		export_separate_dataframes(experiment, path)
	else
		export_default(experiment, path, stubbornfrac, networkprops)
	end
end

function reshape_df!(df)
	df[!, "Culture"] = [join(c) for c in df[!, "CultureTmp"]]
	select!(df, DataFrames.Not(:CultureTmp))
	return df
end

function export_aggregated(experiment, path, stubbornfrac, networkprops)
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
	return true
end

function export_separate_dataframes(experiment, path)
	for key in keys(experiment[1])
		df = DataFrame(
			TickNr = experiment[1][key][!, "TickNr"],
			AgentID = experiment[1][key][!, "AgentID"],
			Culture = experiment[1][key][!, "Culture"]
		)
		Feather.write(joinpath(path, "agents", "adata_rep" * string(key) * ".feather"), df)
	end
	return true
end

function export_default(experiment, path, stubbornfrac, networkprops)
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
	return true
end
