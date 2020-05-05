include("axelrodnet.jl")

agentcount::Int64=100,
n_iter::Int64=1000,
socialbotfrac::Float64=0.00,
m0::Int64=5,
rndseed::Int64=1,
repcount::Int64=1,
completemixing::Bool=false

test = Axelrodnet.run!()
using CSV
fullmix = Axelrodnet.run!(completemixing = true)

print(test[1])
print(fullmix[1])

grid([3,3])

trunc(Int64, 5.5)

test2 = convert2weightedGraph(test[1], test[2])
