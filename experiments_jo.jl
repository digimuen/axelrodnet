# imports
using GraphIO
using LightGraphs
using Feather
using DataFrames
using ParserCombinator
include("axelrodnet.jl")

# replication of the original experiment
orig_replication = Axelrodnet.run!(
    sqrt_agentcount=10,
    n_iter=1_000_000,
    nettopology=1,
    networkprops=Dict{String, Any}(),
    socialbotfrac=0.0,
    rndseed=151,
    repcount=20,
    export_every_n=10_000
)

# export graphs to edge list format
for key in keys(orig_replication[2])
    if !("graphs" in readdir("data"))
        mkdir(joinpath("data", "graphs"))
    end
    savegraph(
        joinpath("data", "graphs", "rep_" * string(key) * ".gml"),
        orig_replication[2][key],
        GMLFormat()
    )
end

# unpack culture vector for data exchange
function reshape_df!(df)
    df["Culture1"] = [c[1] for c in df["Culture"]]
    df["Culture2"] = [c[2] for c in df["Culture"]]
    df["Culture3"] = [c[3] for c in df["Culture"]]
    df["Culture4"] = [c[4] for c in df["Culture"]]
    df["Culture5"] = [c[5] for c in df["Culture"]]
    deletecols!(df, :Culture)
    return df
end
for key in keys(orig_replication[1])
    reshape_df!(orig_replication[1][key])
end

# export data
for key in keys(orig_replication[1])
    if !("agents" in readdir("data"))
        mkdir(joinpath("data", "agents"))
    end
    Feather.write(joinpath("data", "agents", "rep_" * string(key) * ".feather"), orig_replication[1][key])
end
