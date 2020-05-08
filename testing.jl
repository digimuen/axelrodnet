include("axelrodnet.jl")

agentcount::Int64=100,
n_iter::Int64=1000,
socialbotfrac::Float64=0.00,
m0::Int64=5,
rndseed::Int64=1,
repcount::Int64=1,
completemixing::Bool=false

test = Axelrodnet.run!()
test_2 = Axelrodnet.run!(sqrt_agentcount=1000, n_iter=1000, repcount=3)
using CSV
fullmix = Axelrodnet.run!(completemixing = true)

print(test[1])
print(fullmix[1])

grid([3,3])

trunc(Int64, 5.5)

test2 = convert2weightedGraph(test[1], test[2])



using DataFrames

d = DataFrame(A = Int64[], B = Any[])

append!(
    d,
    DataFrame(
        A = [1, 2, 3],
        B = [3, "b", 3]
    )
)
