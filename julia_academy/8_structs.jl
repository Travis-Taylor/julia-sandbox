#= Structs (aka Classes) =#

struct SomeStruct
    first_field
    second_field
end

# Objects are immutable once created, by default
obj = SomeStruct(1, "2")

# Mutable allows overriding values of object
mutable struct Person
    name::String
    age::Int64
    dnd_alignment::Tuple{String, String}
end
person = Person("Jimmy", 42, ("Lawful", "Neutral"))
person.age += 1
println("Happy birthday $(person.name)")


# Define custom constructor
mutable struct Order
    entree::String
    side::String
    price::Float64

    function Order(entree::String, side::String)
        # Calculate price here
        local price::Float64
        if entree == "burger"
            price = 20.0
        elseif entree == "lasagna"
            price = 15.0
        else
            price = 22.75
        end
        new(entree, side, price)
    end
end

order = Order("Beef bolognese", "tater tots")
println("$(order.entree) + $(order.side): \$$(order.price)")

function discount!(order::Order)
    println("Congratulations, you're the 10,000th customer!")
    order.price *= 0.8
end
discount!(order)

println("$(order.entree) + $(order.side): \$$(order.price)")

