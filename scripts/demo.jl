##
includet("../src/Fractals.jl")

##
using .Fractals
using Plots

## exponential
@time expfrac = Fractal(
	"f: z ↦ eᶻ",
	z -> exp(z),
	10_000,
	5LinRange(-1, 1, 701),
	4LinRange(-1, 1, 699)
)

pexp = plot(expfrac)

savefig(pexp, "./img/exp.png")

## fractions
@time fracfrac = Fractal(
	"f: z ↦ 1/(1 + z)",
	z -> 1/(1 + z),
	10_000,
	LinRange(-12, 2, 701),
	4LinRange(-1, 1, 699)
)

pfrac = plot(fracfrac)

savefig(pfrac, "./img/frac.png")

## 
@time atanfrac = Fractal(
	"f: z ↦ atan(z)",
	z -> atan(z),
	10_000,
	LinRange(-1.5, 1.5, 701),
	LinRange(-2, 2, 699)
)

patan = plot(atanfrac)

savefig(patan, "./img/atan.png")

##
