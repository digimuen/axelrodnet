include(joinpath("src", "axelrodnet.jl"))

for sf in 0.00:0.01:0.2
    Axelrodnet.run_experiment(
        experiment_name="grid_sf" * string(trunc(Int, sf * 100)),
        agentcount=100,
        n_iter=1_000_000,
        nettopology="grid",
        networkprops=Dict("grid_height" => 10),
        stubbornfrac=sf,
        rndseed=1,
        repcount=10,
        export_every_n=1_000_000,
        export_experiment=true,
        exportmode="default",
        keep_rawnet=false
    )
end

for sf in 0.00:0.01:0.2, beta in 0.1:0.1:0.5
    Axelrodnet.run_experiment(
        experiment_name="wattsstrogatz_sf" * string(trunc(Int, sf * 100)) * "_beta" * string(trunc(Int, beta * 10)),
        agentcount=100,
        n_iter=1_000_000,
        nettopology="watts_strogatz",
        networkprops=Dict("k" => 10, "beta" => beta),
        stubbornfrac=sf,
        rndseed=1,
        repcount=10,
        export_every_n=1_000_000,
        export_experiment=true,
        exportmode="default",
        keep_rawnet=false
    )
end

for sf in 0.00:0.01:0.2
    Axelrodnet.run_experiment(
        experiment_name="barabasialbert_sf" * string(trunc(Int, sf * 100)),
        agentcount=100,
        n_iter=1_000_000,
        nettopology="barabasi_albert",
        networkprops=Dict("m0" => 10),
        stubbornfrac=sf,
        rndseed=1,
        repcount=10,
        export_every_n=1_000_000,
        export_experiment=true,
        exportmode="default",
        keep_rawnet=false
    )
end
