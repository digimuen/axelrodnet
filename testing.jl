include("axelrodnet.jl")

test = Axelrodnet.run!()

test[2]

agentcount = 100
n_iter = 1000
socialbotfrac = 0.05
m0 = 50
