module Fractals

import DoubleFloats:
	Double64
	import Base.Threads:
		@threads,
		SpinLock,
		lock,
		unlock,
		nthreads
import ProgressMeter:
	Progress,
	update!,
	next!
import RecipesBase: RecipesBase, @recipe
import Plots: RGB, distinguishable_colors, palette

export Fractal

struct Fractal
	name::String
	fcn::Function
	max_period::UInt32
	zreal::Vector{zr} where zr <: Double64
	zimag::Vector{zi} where zi <: Double64
	periods::Matrix{pg} where pg <: UInt32

	function Fractal(
		name::String,
		f::Function,
		max_period::UInt32,
		zreal::Vector{zr},
		zimag::Vector{zi}) where {zr <: Double64, zi <: Double64}

		z = [x + im*y for x ∈ zreal, y ∈ zimag]

		function count_period(z₀::Complex)
			ztraj = [f(z₀)]
			
			for n ∈ length(ztraj):max_period
				zₙ₋₁ = ztraj[end]
				zₙ = f(z₀ * zₙ₋₁)
		
				zₙ ∈ ztraj &&
					return UInt32(length(ztraj) - findlast(isequal(zₙ), ztraj))
				push!(ztraj, zₙ)
			end
		
			return UInt32(0)
		end

		nth = nthreads()

		function Fractal!(periods)
			desc = "$name Period Grid ($nth thread" * "s"^min(nth - 1, 1) * "): "
			prog = Progress(length(periods), desc = desc)
			update!(prog, 0)
			l = SpinLock()

			@threads for i ∈ eachindex(periods, z)
				@inbounds periods[i] += count_period(z[i])
				lock(l)
				next!(prog, step = 1)
				unlock(l)
			end

			return periods
		end

		periods = zeros(UInt32, size(z))

		return new(name, f, max_period, zreal, zimag, Fractal!(periods))
	end
end

Fractal(f::Function, args...) = Fractal("", f, args...)

Fractal(
	name::String,
	f::Function,
	max_period::Integer,
	x::AbstractVector{xR},
	y::AbstractVector{yR}
) where {xR <: Real, yR <: Real} = Fractal(
	name,
	f,
	UInt32(max_period),
	Double64.(x),
	Double64.(y)
)

@recipe function f(frac::Fractal, name::String = frac.name)
	seriestype := :heatmap
	clims := (0, 51)
	seriescolor := palette([distinguishable_colors(51, RGB(0, 0, 0)); :white])
	colorbar_title := "Periods"
	title := string("Fractal", ": "^sign(length(name)), name)
	Nx = length(frac.zreal)
	Ny = length(frac.zimag)
	xguide --> "Re(z₀) ($Nx points)"
	yguide --> "Im(z₀) ($Ny points)"
	frac.zreal, frac.zimag, frac.periods'
end

end