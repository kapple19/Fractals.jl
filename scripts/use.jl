##
include("../src/Fractals.jl")

##
using .Fractals
using Plots
using RecipesBase
using DoubleFloats: Double64

##
x = Double64.(5.1LinRange(-1, 1, 301))
y = Double64.(LinRange(-2.4, 3.8, 299))

g = LimitsGrid(z -> exp(z), x, y)

##
c₀ = distinguishable_colors(47, RGB(0, 0, 0))
c₁ = [c₀; repeat([:white], maximum(g.N) - length(c₀))]
c₂ = [c₀; :white]
c = c₁[1:maximum(g.N)-minimum(g.N)]

pN = heatmap(
	title = "Continued Exponentials: x₀ + iy₀",
	yguide = "y₀",
	xguide = "x₀", 
	x, y, g.N',
	c = palette(c),
	aspect_ratio = 1.0,
	colorbar = false
)

pC = heatmap(
	1:2,
	eachindex(c₂) .- 1,
	repeat(eachindex(c₂)' .- 1, 2)',
	c = palette(c₂),
	xticks = false,
	colorbar = false,
	yguide = "Periods"
)

plot(pN, pC, layout = grid(1, 2, widths = [0.95, 0.05]))

##