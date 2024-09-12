#= Ranked Choice Voting simulation
Basic 4-choice implementation of ranked choice voting.
When a voter's first choice is eliminated from the running, their second will be
used to re-tally results, and so on until a candidate has a majority

Inputs to the results will be weighted preference of candidates and write-in
options, as well as the number of voters.

TODO(ttaylor) maybe axes of different policy paradigms (e.g. economic views vs
social views) used to determine relative preference of candidates
=#
include("./Voting.jl")
using .Voting

candidates::Vector{String} = ["Sheetal", "James", "Natsuki", "Kalae"]
candidate_popularity = Dict{String,Float32}()


## Randomized Inputs ##
# Normalized candidate popularity in range [0-1]
for candidate ∈ candidates
    candidate_popularity[candidate] = rand(Float32)
    approval_percent = round(candidate_popularity[candidate] * 100, sigdigits=3)
    println("Candidate $candidate approval rating: $approval_percent%")
end

# Add option for write-in candidate
push!(candidates, writein)
# Assume write-ins are fairly unlikely
candidate_popularity[writein] = rand(0.0:0.01:0.15)
writein_likelihood = round(candidate_popularity[writein] * 100, sigdigits=3)
println("Candidate $writein likelihood: $writein_likelihood%")


# Voting Population
num_voters = 1000000

## Generate votes ##
votes = generate_votes(num_voters, candidate_popularity)

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

    counts = evaluate_votes(votes, eliminated)
    remaining_candidates = Set{String}(keys(counts))
    println("There are $(length(remaining_candidates)) candidates left in the round")

    # eliminate candidates with no votes (they're not in `counts` but should be eliminated)
    candidates_without_votes = setdiff(unique_candidates, remaining_candidates)
    union!(eliminated, candidates_without_votes)

    winner, min_votes = tally_votes(counts, num_voters)
    if isnothing(winner)
        println("No one received a majority of votes, so removing candidates with "
                *
                "fewest votes ($min_votes)")
        min_candidates = findall(count -> count <= min_votes, counts)
        for candidate ∈ min_candidates
            push!(eliminated, candidate)
        end
    end
    round_no += 1
end
println("$winner wins the election!")
