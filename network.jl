function create_network(
    agents::AbstractArray,

)
    # this algorithm is modelled after the python networkx implementation:
    # https://github.com/networkx/networkx/blob/master/networkx/generators/random_graphs.py#L655

    agentcount = length(agents[:,1])

    g = SimpleDiGraph(agentcount)
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
