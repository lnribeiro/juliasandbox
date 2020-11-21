using Plots

include("modulation.jl")
include("bits.jl")
include("utils.jl")

modOrderVec = [4, 16, 64, 256]
numBits = 9600
SNRdBvec = -20:5:30 # Eb/N0
numRuns = 10

# initialize modulators
modulators = Vector{PSK}(undef, length(modOrderVec))
for ii = 1:length(modOrderVec)
    modulators[ii] = PSK(modOrderVec[ii])
end

errArray = zeros(Int, numRuns, length(modOrderVec), length(SNRdBvec))
for rr = 1:numRuns

    # generate bitstream...
    bits = generateBitstream(numBits)

    for mm = 1:length(modOrderVec)

        # modulate bits
        modulator = modulators[mm]
        modOrder = modOrderVec[mm]
        modBits = Int(log2(modOrder))
        numSymbols = Int(numBits/modBits)
        symbols = bitstream2symbolstream(bits, modBits)
        x = modulate(modulator, symbols)

        # generate noise term
        noi = (1/sqrt(2)).*(randn(numSymbols) + im*randn(numSymbols))

        for ss = 1:length(SNRdBvec)

            println("run $rr/$numRuns, PSK-$(modOrder) point $ss/$(length(SNRdBvec))")

            # set noise power
            SNRdB = SNRdBvec[ss]
            SNRlin = 10^(SNRdB/10)
            N0 = modulator.avgEb/SNRlin

            # contaminate transmitted signals
            y = x + sqrt(N0)*noi

            # demodulate
            symbolsDemod = demodulate(modulator, y)
            estbits = symbolstream2bitstream(symbolsDemod, modBits)

            # count error
            err = sum(bits .!= estbits)
            errArray[rr, mm, ss] = err

        end # snr loop
         
    end # modulation loop

end # monte carlo loop

# average errors
BER = dropdims(sum(errArray, dims=1), dims=1) / (numRuns*numBits)

# Caveat: The input of log plot should not start from 0, because it requires the log plot to start from -inf. That's why we filter the BER vectors
# https://github.com/JuliaPlots/Plots.jl/issues/1607#issuecomment-427664782
pl = plot(SNRdBvec, filterZeros(BER[1, :]), yaxis=:log10, label="4", lw=2, marker=:circle)
plot!(pl, SNRdBvec, filterZeros(BER[2, :]), label="16", lw=2, marker=:rect)
plot!(pl, SNRdBvec, filterZeros(BER[3, :]), label="64", lw=2, marker=:diamond)
plot!(pl, SNRdBvec, filterZeros(BER[4, :]), label="256", lw=2, marker=:utriangle)
xlabel!("Eb/N0 [dB]")
ylabel!("BER")
title!("PSK BER Performance")