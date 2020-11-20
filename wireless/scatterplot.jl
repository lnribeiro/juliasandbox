using Plots

include("modulation.jl")

modOrder = 16
numSymbols = 100
noiseVar = 0.1

# generate message symbols
symbols = rand(0:(modOrder-1), numSymbols)

# modulate symbols
qammod = QAM(modOrder)
pskmod = PSK(modOrder)

xqam = modulate(qammod, symbols)
xpsk = modulate(pskmod, symbols)

# corrupt modulated symbols
n = (1/sqrt(2)).*(randn(numSymbols) + im*randn(numSymbols))

yqam = xqam .+ sqrt(noiseVar)*n
ypsk = xpsk .+ sqrt(noiseVar)*n

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

scatter(real(xqam), imag(xqam), label = "Noiseless")
scatter!(real(yqam), imag(yqam), label = "Noisy QAM")
xlabel!("In-phase")
ylabel!("Quadrature")

scatter(real(xpsk), imag(xpsk), label = "Noiseless", reuse=false)
scatter!(real(ypsk), imag(ypsk), label = "Noisy PSK")
xlabel!("In-phase")
ylabel!("Quadrature")