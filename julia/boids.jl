module Boids
using Plots
using Statistics

mutable struct WorldState
    boids::Vector{Tuple{Float64, Float64}}
    speed::Vector{Tuple{Float64, Float64}}
    height::Float64
    width::Float64
    function WorldState(n_boids, h, w)
        boids = [(rand(0:w), rand(0:h)) for _ in 1:n_boids]
        speed = [(rand(-1:0.01:1), rand(-1:0.01:1)) for _ in 1:n_boids]
        new(boids, speed, h, w)
    end
end

function update!(state::WorldState)
    boids = state.boids
    speed = state.speed


    center_rule = Vector{Tuple{Float64, Float64}}()
    speed_rule = Vector{Tuple{Float64, Float64}}()
    avoid_rule = Vector{Tuple{Float64, Float64}}()
    for i in 1:length(state.speed)
        boids = state.boids
        speed = state.speed
        center_speed = center(state, i)
        mean_speed = mean_vector(state, i)
        avoid_speed = avoid_crowd(state, i)
        push!(center_rule, center_speed)
        push!(speed_rule, mean_speed)
        push!(avoid_rule, avoid_speed)

        state.speed[i] = (center_rule[i] .+ speed[i] .+ speed_rule[i] .+ avoid_rule[i])
        if state.speed[i][1] > 2 || state.speed[i][2] > 2
            state.speed[i] = 2, 2
        end
        boids[i] = boids[i] .+ state.speed[i]
        if boids[i][1] > state.height || boids[i][2] > state.width || boids[i][1] < 0 || boids[i][2] < 0
            state.boids[i] = (mod(state.boids[i][1], state.height), mod(state.boids[i][2], state.width))
        else
            state.boids = boids
        end
    end

    # TODO: реализация алгоритма
    return nothing
end

#центр масс
function center(state::WorldState, n)
    mean_x::Float64 = 0.0
    mean_y::Float64 = 0.0
    boids = state.boids
    for i in 1:length(boids)
        if i != n
            mean_x = mean_x + boids[i][1]
            mean_y = mean_y + boids[i][2]
        end
    end
    mean_dist = (mean_x / (length(boids) - 1), mean_y / (length(boids) - 1))
    center_speed = (0.0, 0.0)
    center_speed = ((mean_dist[1] - boids[n][1]), (mean_dist[2] - boids[n][2]))

    return center_speed .* 0.02
end

function mean_vector(state::WorldState, n)
    mean_x::Float64 = 0.0
    mean_y::Float64 = 0.0
    speed = state.speed
    for i in 1:length(speed)
        if i != n
            mean_x = mean_x + speed[i][1]
            mean_y = mean_y + speed[i][2]
        end
    end
    mean_speed = (mean_x / (length(speed) - 1), mean_y / (length(speed) - 1))
    vec_speed = (0.0, 0.0)
    vec_speed = ((mean_speed[1] - speed[n][1]), (mean_speed[2] - speed[n][2]))

    return vec_speed .* 0.01
end

function avoid_crowd(state::WorldState, n)
    avoid_speed = (0.0, 0.0)
    boids = state.boids
    for i in 1:length(boids)
        if i != n
            R = sqrt((boids[i][1] - boids[n][1])^2 + (boids[i][2] - boids[n][2])^2)
            if R < 2
                avoid_speed = avoid_speed .- (boids[i][1] - boids[n][1], boids[i][2] - boids[n][2])
            end
        end
    end

    return avoid_speed .* 0.05
end


function (main)(ARGS)
    h = 30
    w = 30
    n_boids = 10

    state = WorldState(n_boids, h, w)

    anim = @animate for time = 1:100
        update!(state)
        boids = state.boids
        scatter(boids, xlim = (0, state.width), ylim = (0, state.height))
    end
    gif(anim, "boids.gif", fps = 10)
end

end

using .Boids
Boids.main("")
