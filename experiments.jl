include(joinpath("src", "axelrodnet.jl"))

for sc in 0:3:30
    Axelrodnet.run_experiment(
        experiment_name="grid_sc" * string(sc),
        agentcount=100,
        n_iter=5_000_000,
        nettopology="grid",
        networkprops=Dict("grid_height" => 10),
        stubborncount=sc,
        rndseed=1,
        n_replicates=10,
        export_every_n=1_000_000,
        exportdata=true,
        exportmode="default",
        keep_rawnet=false
    )
end

for sc in 0:3:30, beta in 0.05:0.05:0.2
    Axelrodnet.run_experiment(
        experiment_name="wattsstrogatz_sc" * string(sc) * "_beta" * lpad(trunc(Int, beta * 100), 2, "0"),
        agentcount=100,
        n_iter=5_000_000,
        nettopology="watts_strogatz",
        networkprops=Dict("k" => 10, "beta" => beta),
        stubborncount=sc,
        rndseed=1,
        n_replicates=10,
        export_every_n=1_000_000,
        exportdata=true,
        exportmode="default",
        keep_rawnet=false
    )
end

for sc in 0:3:30
    Axelrodnet.run_experiment(
        experiment_name="barabasialbert_sc" * string(sc),
        agentcount=100,
        n_iter=5_000_000,
        nettopology="barabasi_albert",
        networkprops=Dict("m0" => 10),
        stubborncount=sc,
        rndseed=1,
        n_replicates=10,
        export_every_n=1_000_000,
        exportdata=true,
        exportmode="default",
        keep_rawnet=false
    )
end

Axelrodnet.aggregate_all_experiments("experiments", write_data=true)
