module Fractals

import RecipesBase
import ProgressMeter:
	Progress,
	update!,
	next!
import Base.Threads:
	@threads,
	SpinLock,
	lock,
	unlock,
	nthreads

export LimitsGrid

struct LimitsGrid
	f::Function
	z::Matrix{Complex}
	N::Matrix{Int64}

	function LimitsGrid(f::F, z::Matrix{C}) where {
		F <: Function, C <: Complex
	}

		function count_limits(z₀::Complex)
			zn = [f(z₀)]
		
			for n ∈ length(zn):100_000
				Z = zn[end]
				zₙ = f(z₀ * Z)
		
				zₙ ∈ zn && return length(zn) - findlast(isequal(zₙ), zn)
				push!(zn, zₙ)
			end
		
			return 0
		end
		
		function LimitsGrid!(N)
			desc = "Limits Grid ($(nthreads()) threads): "
			prog = Progress(length(N), desc = desc)
			update!(prog, 0)
			l = SpinLock()

			@threads for i ∈ eachindex(N, z)
				@inbounds N[i] += count_limits(z[i])
				lock(l)
				next!(prog, step = 1)
				unlock(l)
			end

			return N
		end

		N = zeros(Int32, size(z))

		return new(f, z, LimitsGrid!(N))
	end
end

function LimitsGrid(f::F, x::Vector{Rx}, y::Vector{Ry}) where {
	F <: Function, Rx <: Real, Ry <: Real
}
	return LimitsGrid(f, [x′ + y′ * 1im for x′ ∈ x, y′ ∈ y])
end

end