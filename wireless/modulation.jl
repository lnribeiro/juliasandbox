using Statistics

abstract type DigitalModulation end

mutable struct PSK <: DigitalModulation
    modOrder::Int                   # constelation order (number of symbols)
    modBits::Int                    # bits per symbol
    constellation::Vector{Complex}  # constellation mapping vector
    avgEs::Float64                    # symbol average energy
    avgEb::Float64                   # bit average energy

    function PSK(modOrder::Int, dphi=pi/4)
        @assert modOrder > 0 || error("Constellation order must be positive")
        @assert modOrder % 2 == 0 || error("Constellation order must be a multiple of 2")

        modBits = Int(log2(modOrder))
        
        # build constellation
        constellation = Vector{Complex}(undef, modOrder)
        for i = 1:modOrder
            constellation[i] = exp(im*((2*pi/modOrder)*(i-1) + dphi))
        end

        # calculate average symbol and bit energies
        avgEs = Statistics.mean(abs.(constellation).^2)
        avgEb = avgEs/modBits

        new(modOrder, modBits, constellation, avgEs, avgEb)
    end

end # PSK struct

mutable struct QAM <: DigitalModulation
    modOrder::Int                   # constelation order (number of symbols)
    modBits::Int                    # bits per symbol
    constellation::Vector{Complex}  # constellation mapping vector
    avgEs::Float32                   # symbol average energy
    avgEb::Float32                   # bit average energy

    function QAM(modOrder::Int)
        @assert modOrder > 0 || error("Constellation order must be positive")
        @assert modOrder % 2 == 0 || error("Constellation order must be a multiple of 2")

        modBits = Int(log2(modOrder))

        # build constellation
        M = convert(Int, sqrt(modOrder))
        m = 1:M        
        I = (2*m.-(1+M))
        Q = (2*m.-(1+M))
        constellation = Vector{Complex}(undef, modOrder)
        for i = 1:M, j = 1:M 
            constellation[j + (i-1)*M] = I[i] + im*Q[j]
        end

        # calculate average symbol and bit energies
        avgEs = mean(abs.(constellation).^2)
        avgEb = avgEs/modBits

        new(modOrder, modBits, constellation, avgEs, avgEb)
    end

end # QAM struct

function modulate(scheme::DigitalModulation, symbols::Vector)
    @assert !isempty(symbols) || error("Symbols vector must not be empty")
    vmin, imin = findmin(symbols)
    vmax, imax = findmax(symbols) 
    @assert (vmin >= 0 && vmax <= (scheme.modOrder-1)) || error("Symbols must be in the interval [0, scheme.modOrder-1]")

    modSymbols = [ scheme.constellation[symbol+1] for symbol in symbols ]

    return modSymbols
end

function demodulate(scheme::DigitalModulation, modSymbols::Vector)
    @assert !isempty(modSymbols) || error("modSymbols vector must not be empty")

    demodSymbols = Vector{Int}(undef, length(modSymbols))
    for i = 1:length(modSymbols)
        s = modSymbols[i]
        dist = map(abs, s .- scheme.constellation)
        vmin,imin = findmin(dist)
        demodSymbols[i] = Int(imin - 1);
    end

    return demodSymbols
end
