#= Voting Utils =#
module Voting
using StatsBase

export generate_votes, get_unique_candidates, evaluate_votes, tally_votes, writein, Vote

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

#= Stand-in value for write-in candidates; actual candidate value will be
evaluated with `gen_write_in` when Vote is initialized =#
writein = "write-in"

"""
Generate write-in candidate. Assume write-in candidates are effectively random
sample of population. Accepts a max value for the randomly generated numeric ID,
generating names from 0-`max_num`
"""
function gen_write_in(max_num::Int)::String
    "SomeCandidate$(rand(0:max_num))"
end

"""
Generate votes for the given number of voters, using the weights defined in
`candidate_popularity` for each of the ranked vote choices.
Ensures that voters cannot enter the same (named) candidate more than once.
"""
function generate_votes(num_voters::Int, candidate_popularity::Dict{String,Float32})::Vector{Vote}
    votes = Vector{Vote}()
    for ii ∈ 1:num_voters
        choices = Vector{String}()
        # Ensure voters don't pick the same candidate for multiple choices
        # remaining_candidates = copy(candidates)
        remaining_candidates = copy(collect(keys(candidate_popularity)))
        remaining_popularity = copy(candidate_popularity)
        for choice ∈ 1:4
            remaining_weights = Weights(collect(values(remaining_popularity)))
            candidate = sample(remaining_candidates, remaining_weights)
            if candidate == writein
                push!(choices, gen_write_in(num_voters))
                # Don't remove writein from options, they can write in more than 1
            else
                push!(choices, candidate)
                # Remove this choice from the remaining candidate list
                filter!(c -> c ≠ candidate, remaining_candidates)
                pop!(remaining_popularity, candidate)
            end
        end
        vote = Vote((choices...,))
        push!(votes, vote)
    end
    votes
end

"""Calculate the unique candidate set from the list of votes"""
function get_unique_candidates(votes::Vector{Vote})::Set{String}
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


"""
Evaluate the top choice of each vote, aggregating the list of selected candidates.
Excludes candidates who have been previously eliminated from a round, falling back
to lower rank choices.
I a vote has no remaining choices that haven't been eliminated, it is not counted.
Returns a dict of the candidate to their tally of votes
"""
function evaluate_votes(votes::Vector{Vote}, eliminated::Set{String})::Dict{String,Int}
    selections::Vector{String} = []
    for vote ∈ votes
        for field ∈ [:first, :second, :third, :fourth]
            top_choice = getfield(vote, field)
            if top_choice ∉ eliminated
                push!(selections, top_choice)
                break
            end
        end
    end
    # Count the occurrences of each selection
    countmap(selections)
end

"""
Tally the selections to see if any candidate has obtained a majority of the votes.
If there are only 2 candidates left, evaluates which candidate received a plurality.
If no candidate wins, returns the minimum number of votes received by a candidate,
to be selected for elimination from the round.
"""
function tally_votes(vote_counts::Dict{String,Int}, num_voters::Int)::Tuple{Union{String,Nothing},Int}
    candidates_left = length(vote_counts)
    # If only 2 left, just evaluate which has a plurality (i.e. more than the other)
    if candidates_left == 2
        winner, vote_count = maximum(vote_counts)
        println("$winner received $vote_count votes.")
        return (winner, vote_count)
    end
    # Else evaluate if any candidate obtained the majority
    majority = num_voters / 2
    min_votes = num_voters
    for (candidate, vote_count) ∈ vote_counts
        if vote_count > majority
            println("$candidate received $vote_count votes.")
            return candidate, vote_count
        elseif vote_count < min_votes
            min_votes = vote_count
        end
    end
    (nothing, min_votes)
end


end