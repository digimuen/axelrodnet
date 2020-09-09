using Feather
using DataFrames
using LightGraphs
using GraphIO
using ParserCombinator

data = Feather.read(
    joinpath("experiments", "test_run_grid", "agents", "adata.feather")
)

graph = LightGraphs.loadgraph(
    joinpath("experiments", "test_run_grid", "graphs", "rep_01.gml"),
    GraphIO.GML.GMLFormat()
)


connected_comps = LightGraphs.connected_components(graph)
connected_comps_by_size = [length(i) for i in connected_comps]
# SizeBiggestComponent
maximum(connected_comps_by_size)
# SeperateComponents
length(connected_comps)

data

# StubbornCount in data
# NetworkType in data
# UniqueCultures -> aggregate from Culture
# SeperateComponents
# ExcessZeros -> aggregate from Culture

function aggregate()

end

function read_raw_data()
end
