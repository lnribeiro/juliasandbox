using Plots

include("modulation.jl")
include("bits.jl")

modOrder = 16
modBits = Int(log2(modOrder))
numBits = 25600
numSymbols = Int(numBits/modBits)

SNR_dB = 30 # Eb/N0
SNR_lin = 10^(SNR_dB/10)

# generate message symbols
bits = generateBitstream(numBits)
symbols = bitstream2symbolstream(bits, modBits)

# modulate symbols
qammod = QAM(modOrder)
pskmod = PSK(modOrder)

xqam = modulate(qammod, symbols)
xpsk = modulate(pskmod, symbols)

# corrupt modulated symbols
n = (1/sqrt(2)).*(randn(numSymbols) + im*randn(numSymbols))

N0_qam = qammod.avgEb/SNR_lin
N0_psk = pskmod.avgEb/SNR_lin

yqam = xqam .+ sqrt(N0_qam)*n
ypsk = xpsk .+ sqrt(N0_psk)*n

# demodulate noisy symbols
demodSymbolsQAM = demodulate(qammod, yqam)
demodSymbolsPSK = demodulate(pskmod, ypsk)

numErrorsQAM = sum(demodSymbolsQAM .!= symbols)
numErrorsPSK = sum(demodSymbolsPSK .!= symbols)

SERQAM = numErrorsQAM/numSymbols
SERPSK = numErrorsPSK/numSymbols

println("Number of errors [QAM]: $numErrorsQAM")
println("SER [QAM]: $SERQAM")
println("Number of errors [PSK]: $numErrorsPSK")
println("SER [PSK]: $SERPSK")

p1 = scatter(real(xqam), imag(xqam), label = "Noiseless")
p1 = scatter!(real(yqam), imag(yqam), label = "Noisy QAM")
p1 = xlabel!("In-phase")
p1 = ylabel!("Quadrature")

p2 = scatter(real(xpsk), imag(xpsk), label = "Noiseless")
p2 = scatter!(real(ypsk), imag(ypsk), label = "Noisy PSK")
p2 = xlabel!("In-phase")
p2 = ylabel!("Quadrature")

plot(p1, p2, layout=2)