using LightGraphs

mutable struct simulation
    name::String
    batch_name::String
    repnr::Int64
    rng::MersenneTwister
    init_state::Any
    final_state::Any

    function Simulation(; batch_name="")
        new(
			"",
			batch_name,
			0,
			MersenneTwister(),
            (nothing, nothing),
            (nothing, nothing)
        )
    end
end

function assimilate!(agents, acting_agent, interaction_partner)
	random_attr = rand(1:length(acting_agent.cultureVector))

	if acting_agent.cultureVector[random_attr] - interaction_partner.cultureVector[random_attr] != 0

		acting_agent.cultureVector[random_attr] = interaction_partner.cultureVector[random_attr]

	else
		assimilate!(agents, acting_agent, interaction_partner)
	end
end

function tick!(
	network::AbstractGraph,
	agents::AbstractArray
)
	random_draw = rand(1:length(agents))
	acting_agent = agents[random_draw]
	interaction_partner = agents[rand(neighbors(network,random_draw))]

	if !acting_agent.socialbot

		similarity = sum([i == j for (i, j) in zip(acting_agent.cultureVector, interaction_partner.cultureVector)]) / length(acting_agent.cultureVector)

		if rand() < similarity && similarity != 1
			assimilate!(agents, acting_agent, interaction_partner)
		end
	end

	return (network, agents)
end

function run!(
	# simulation::Simulation=Simulation(),
	batchrunnr::Int64=-1
	;
	name::String="_"
	)

	agentcount = 2000

	agents = Agent[]
	for i in 1:round(Int64, 0.98*agentcount)
		push!(agents, Agent(rand(1:9,5)))
	end

	socialbotfrac = agentcount - length(agents)

	for i in 1:socialbotfrac
		push!(agents, Agent(fill(1,5), true))
	end

	network = barabasi_albert(length(agents),50)

	regioncount = Int64[]

	for i in 1:1000
		tick!(network,agents)
		push!(regioncount,length(unique([agent.cultureVector for agent in agents])))
	end

	return agents, regioncount
end

function run_batch(

)

end



test = run!()

for i in 1:5
Matrix([agent.cultureVector for agent in test])
Matrix()

unique(t)

using StatsBase
first.(sort(collect(countmap(([agent.cultureVector for agent in test]))), by=last, rev=true))

a = [1,2,3,4,5]
b = [5,4,3,2,1]

agents = [a,b]

for j in 1:length(agents)


for i in 1:5
	print(a[i] == b[i])
end
