include(joinpath("src", "axelrodnet.jl"))

for sc in 0:20
    Axelrodnet.run_experiment(
        experiment_name="grid_sc" * string(sc),
        agentcount=100,
        n_iter=1_000_000,
        nettopology="grid",
        networkprops=Dict("grid_height" => 10),
        stubborncount=sc,
        rndseed=1,
        repcount=10,
        export_every_n=1_000_000,
        export_experiment=true,
        exportmode="default",
        keep_rawnet=false
    )
end

for sc in 0:20, beta in 0.1:0.1:0.5
    Axelrodnet.run_experiment(
        experiment_name="wattsstrogatz_sc" * string(sc) * "_beta" * string(trunc(Int, beta * 10)),
        agentcount=100,
        n_iter=1_000_000,
        nettopology="watts_strogatz",
        networkprops=Dict("k" => 10, "beta" => beta),
        stubborncount=sc,
        rndseed=1,
        repcount=10,
        export_every_n=1_000_000,
        export_experiment=true,
        exportmode="default",
        keep_rawnet=false
    )
end

for sc in 0:20
    Axelrodnet.run_experiment(
        experiment_name="barabasialbert_sc" * string(sc),
        agentcount=100,
        n_iter=1_000_000,
        nettopology="barabasi_albert",
        networkprops=Dict("m0" => 10),
        stubborncount=sc,
        rndseed=1,
        repcount=10,
        export_every_n=1_000_000,
        export_experiment=true,
        exportmode="default",
        keep_rawnet=false
    )
end
