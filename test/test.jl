include(joinpath("..", "axelrodnet.jl"))

# basic test
test_0 = Axelrodnet.run!(networkprops=Dict("grid_height" => 10))

# sqrt_agentcount tests
test_1 = Axelrodnet.run!(agentcount=10_000)
test_2 = Axelrodnet.run!(agentcount=1_000_000)

# n_iter tests
test_3 = Axelrodnet.run!(n_iter=10_000)
test_4 = Axelrodnet.run!(n_iter=100_000)

# socialbotfrac tests
test_5 = Axelrodnet.run!(socialbotfrac=0.1)
test_6 = Axelrodnet.run!(socialbotfrac=0.3)

# nettopology tests
test_7 = Axelrodnet.run!(nettopology=1)
test_8 = Axelrodnet.run!(nettopology=2)
test_9 = Axelrodnet.run!(nettopology=3)
test_10 = Axelrodnet.run!(nettopology=4)

# repcount test
test_11 = Axelrodnet.run!(repcount=3)

# export_every_n test
test_12 = Axelrodnet.run!(export_every_n=50)
