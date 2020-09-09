function aggregate_all_experiments(data_folder::String; write_data::Bool)
    experiment_names = readdir(data_folder)
    aggregated_dataframe = init_aggregated_experiment_dataframe()
    for current_experiment in experiment_names
        aggregated_dataframe = vcat(
            aggregated_dataframe,
            aggregate_experiment(data_folder, current_experiment)
        )
    end
    if write_data
        Feather.write(
            joinpath(data_folder, "aggregated_data.feather"),
            aggregated_dataframe
        )
    end
    return aggregated_dataframe
end

function aggregate_experiment(data_folder::String, experiment_name::String; write_data::Bool=false)
    data = read_simulation_dataframe(data_folder, experiment_name)
    graphs = read_simulation_graphs(data_folder, experiment_name)
    aggregated_dataframe = build_aggregated_dataframe(data, graphs)
    if write_data
        Feather.write(
            joinpath(data_folder, experiment_name, experiment_name * ".feather"),
            aggregated_dataframe
        )
    end
    return aggregated_dataframe
end

function read_simulation_dataframe(data_folder::String, experiment_name::String)
    data = Feather.read(
        joinpath(data_folder, experiment_name, "agents", "adata.feather")
    )
    return data
end

function read_simulation_graphs(data_folder::String, experiment_name::String)
    graph_file_names = readdir(joinpath(data_folder, experiment_name, "graphs"))
    graphs = [
        LightGraphs.loadgraph(
            joinpath(data_folder, experiment_name, "graphs", file_name),
            GraphIO.GML.GMLFormat()
        ) for file_name in graph_file_names
    ]
    return graphs
end

function build_aggregated_dataframe(data::DataFrames.DataFrame, graphs::AbstractArray)
    aggregated_dataframe = init_aggregated_experiment_dataframe()
    for rep in 1:length(graphs)
        filtered_data = filter_by_rep(data, rep)
        row = build_row(filtered_data, graphs[rep])
        push!(aggregated_dataframe, row)
    end
    return aggregated_dataframe
end

function init_aggregated_experiment_dataframe()
    aggregated_experiment_dataframe = DataFrames.DataFrame(
        NetworkType = String[],
        StubbornCount = Int64[],
        Replicate = Int64[],
        SeperateComponents = Int64[],
        SizeBiggestComponent = Int64[],
        UniqueCultures = Int64[],
        FractionZeros = Float64[]
    )
    return aggregated_experiment_dataframe
end

function filter_by_rep(dataframe::DataFrames.DataFrame, replicate)
    final_tick = maximum(dataframe.TickNr)
    filtered_dataframe = dataframe |>
        @filter(_.Replicate == replicate && _.TickNr == final_tick) |>
        DataFrames.DataFrame
    return filtered_dataframe
end

function build_row(data::DataFrames.DataFrame, graph::LightGraphs.AbstractGraph)
    network_type = get_network_type(data)
    stubborn_count = data.StubbornCount[1]
    replicate = data.Replicate[1]
    connected_component_sizes = get_connected_component_sizes(graph)
    seperate_components = length(connected_component_sizes)
    size_biggest_component = maximum(connected_component_sizes)
    unique_cultures = get_unique_cultures(data)
    fraction_zeros = get_fraction_zeros(data)
    return (
        network_type,
        stubborn_count,
        replicate,
        seperate_components,
        size_biggest_component,
        unique_cultures,
        fraction_zeros
    )
end

function get_network_type(data::DataFrames.DataFrame)
    network_type = data.NetworkType[1]
    if network_type == "watts_strogatz"
        network_type = network_type * "_" * string(data.Beta[1])
    end
    return network_type
end

function get_connected_component_sizes(graph::LightGraphs.AbstractGraph)
    connected_component_sizes = [
        length(component) for component in LightGraphs.connected_components(graph)
    ]
    return connected_component_sizes
end

function get_unique_cultures(data::DataFrames.DataFrame)
    unique_cultures = data |>
        @map(_.Culture) |>
        @unique() |>
        collect |>
        length
    return unique_cultures
end

function get_fraction_zeros(data)
    culture_dimensions = length(data.Culture[1])
    agent_count = data |> nrow
    cultures_concat = data |>
        @map(_.Culture) |>
        collect |>
        join
    fraction_zeros = length(collect(eachmatch(r"0", cultures_concat))) / (culture_dimensions * agent_count)
    return fraction_zeros
end
