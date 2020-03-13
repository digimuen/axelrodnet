using Random

function create_network(
    agents::AbstractArray,

)
    # this algorithm is modelled after the python networkx implementation:
    # https://github.com/networkx/networkx/blob/master/networkx/generators/random_graphs.py#L655

    agentcount = length(agents[:,1])

    g = SimpleGraph(agentcount)
    pref_attach_list = collect(1:agentcount)

    for source in 1:agentcount

        shuffle!(pref_attach_list)
        m0 = 10

        if m0 >= agentcount
            m0 = agentcount - 1
        elseif m0 <= 0
            break
        end

        targets = Array{Int64}(undef, 0)

        for i in pref_attach_list

            if length(targets) >= m0
                break
            end

            if !(i in targets) && i != source
                push!(targets, i)
            end
        end

        for e in zip(targets, fill(source, m0))
            add_edge!(g, e[1], e[2])
        end

        append!(pref_attach_list, targets)
    end

    return g
end

# function generateStochasticBlockModel(;rng=MersenneTwister(), agents::AbstractArray, cluster = 20)
#     agent_count = length(agents)
#     #rng = MersenneTwister(1)
#     #agent_count = 4000
#
#     nsize = agent_count #Int(round(agent_count / cluster))
#     cluster = div(nsize, 100)
#     minclustersize = 7
#     csize = rand(rng, cluster)
#     csizesum = sum(csize)
#     clustersizes = zeros(Int64, cluster)
#     for i in 1:cluster
#         clustersizes[i] = minclustersize +
#         div((nsize-(minclustersize*cluster)) * csize[i],csizesum) + 1
#
#     end
#     clustersizes[1] = max((clustersizes[1] + (nsize - sum(clustersizes))), minclustersize)
#
#     sigma = zeros(Real, cluster, cluster)
#
#     for i in 1:cluster
#         for j in i:cluster
#             if(i == j)
#                 #sigma[i,j] = Int(round(min(max_edges * (1-rand(rng)*rand(rng)) + 1, clustersizes[i]))) -1
#                 sigma[i,j] = clustersizes[i] * rand(rng, 0.01:0.0001:0.05)
#
#             else
#                 #sigma[i,j] = 0.1*rand(rng) *rand(rng)* min(clustersizes[i], clustersizes[j])
#                 if rand(rng) < 0.6
#                     sigma[i,j] = 0
#                 else
#                     sigma[i,j] = rand(rng, 0:0.0001:0.01)
#                 end
#             end
#
#         end
#     end
#
#     println(sigma)
#     println(clustersizes)
#     g = stochastic_block_model(sigma, clustersizes, seed = rand(rng, Int64))
#     @info "created."
#     pruneIsolatedVertices!(g)
#     g
# end
