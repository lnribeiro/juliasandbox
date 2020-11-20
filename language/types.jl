
module Company

# modules are a nice workaround to solve the "ERROR: invalid redefinition of constant MyType" problem
# https://juliafs.readthedocs.io/en/latest/manual/faq.html#how-can-i-modify-the-declaration-of-a-type-immutable-in-my-session
# of course, it also helps organizing the code :)

abstract type Employee end

mutable struct Researcher <: Employee # if it's mutable, then we can modify an instance attribute as instance.id = 1
#struct Researcher <: Employee

    id::Int
    name::String
    projects

    # Constructor 
    function Researcher(name::String)
        id = rand(Int)
        @assert !isempty(name)
        new(id, name, nothing)
    end

end

mutable struct Professor <: Employee
    
    id::Int
    name::String
    lectures
    projects

    function Professor(name::String)
        id = rand(Int)
        @assert !isempty(name)
        new(id, name)
    end

end

function setProjects(empl, projects::Array)

    @assert !isempty(projects)
    empl.projects = projects

end

function printResearcher(employee::Researcher)

    println("Id: $(employee.id)")
    println("Name: $(employee.name)")

    println("Job: Researcher")
    if !isnothing(employee.projects)
        println("Projects:")
        for project in employee.projects
            println("* $project")
        end
    end

end

end