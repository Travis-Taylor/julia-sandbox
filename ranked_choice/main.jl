#= Ranked Choice Voting simulation
Basic 4-choice implementation of ranked choice voting.
When a voter's first choice is eliminated from the running, their second will be
used to re-tally results, and so on until a candidate has a majority

Inputs to the results will be weighted preference of candidates and write-in
options, as well as the number of voters.

TODO(ttaylor) maybe axes of different policy paradigms (e.g. economic views vs
social views)
=#
using StatsBase

# Ranked-choice Vote struct, allowing 4 choices in order of preference
struct Vote
    first::String
    second::String
    third::String
    fourth::String

    function Vote(choices::Tuple{String,String,String,String})
        new(choices...)
    end
end

candidates::Vector{String} = ["Sheetal", "James", "Natsuki", "Kalae"]
candidate_popularity = Dict{String,Float32}()
#= Stand-in value for write-in candidates; actual candidate value will be
evaluated with `gen_write_in` when Vote is initialized =#
writein = "write-in"


## Randomized Inputs ##
# Normalized popularity in range [0-1]
for candidate ∈ candidates
    candidate_popularity[candidate] = rand(Float32)
    approval_percent = round(candidate_popularity[candidate] * 100, sigdigits=3)
    println("Candidate $candidate approval rating: $approval_percent%")
end

# Assume write-in candidates are effectively random
function gen_write_in(max_num::Int)::String
    "SomeCandidate$(rand(0:max_num))"
end
push!(candidates, writein)
# Also assume write-in candidates are fairly unlikely
candidate_popularity[writein] = rand(0.0:0.01:0.15)
writein_likelihood = round(candidate_popularity[writein] * 100, sigdigits=3)

println("Candidate $writein likelihood: $writein_likelihood%")


# Voting Population
num_voters = 1000000
majority = num_voters / 2

## Generate votes ##
votes = Vector{Vote}()
candidate_weights = Weights(collect(values(candidate_popularity)))
for ii ∈ 1:num_voters
    choices = Vector{String}()
    remaining_candidates = copy(candidates)
    remaining_popularity = copy(candidate_popularity)
    for choice in 1:4
        remaining_weights = Weights(collect(values(remaining_popularity)))
        candidate = sample(remaining_candidates, remaining_weights)
        if candidate == writein
            push!(choices, gen_write_in(num_voters))
            # Don't remove writein from options, they can write in more than 1
        else
            push!(choices, candidate)
            # Remove this choice from the remaining candidate list
            filter!(el -> el ≠ candidate, remaining_candidates)
            pop!(remaining_popularity, candidate)
        end
    end
    vote = Vote((choices...,))
    push!(votes, vote)
end

function get_unique_candidates(votes::Vector{Vote})
    firsts = Vector{String}()
    seconds = Vector{String}()
    thirds = Vector{String}()
    fourths = Vector{String}()
    for vote ∈ votes
        push!(firsts, vote.first)
        push!(seconds, vote.second)
        push!(thirds, vote.third)
        push!(fourths, vote.fourth)
    end
    Set{String}(unique([firsts; seconds; thirds; fourths]))
end


function evaluate_votes(eliminated::Set{String})
    selections::Vector{String} = []
    for vote ∈ votes
        for field in [:first, :second, :third, :fourth]
            top_choice = getfield(vote, field)
            if top_choice ∉ eliminated
                push!(selections, top_choice)
                break
            end
        end
    end
    selections
end

function tally_votes(vote_counts::Dict{String,Int})::Tuple{Union{String,Nothing},Int}
    min_votes = num_voters
    winner = nothing
    for (candidate, vote_count) ∈ vote_counts
        if vote_count > majority
            println("$candidate received $vote_count votes.")
            println("That's a majority!! Winner winner!")
            winner = candidate
            break
        elseif vote_count < min_votes
            min_votes = vote_count
        end
    end
    (winner, min_votes)
end

## Tally Top Choices each round ##

unique_candidates = get_unique_candidates(votes)
winner = nothing
eliminated = Set{String}()
round_no = 1
while isnothing(winner)
    global winner
    global eliminated
    global round_no
    println("\nRound $round_no: Tallying votes\n")
    selections = evaluate_votes(eliminated)
    counts = countmap(selections)
    println("There are $(length(counts)) candidates left in the round")
    # eliminate candidates with no votes (they're not in `counts` but should be eliminated)
    candidates_without_votes = setdiff(unique_candidates, selections)
    union!(eliminated, candidates_without_votes)
    # Find the candidate(s) with the least number of votes, if we have to eliminate
    winner, min_votes = tally_votes(counts)
    if isnothing(winner)
        println("No one received a majority of votes, so removing candidates with least votes ($min_votes)")
        min_candidates = findall(count -> count <= min_votes, counts)
        for candidate ∈ min_candidates
            push!(eliminated, candidate)
        end
    end
    round_no += 1
end
println("$winner wins the election!")
