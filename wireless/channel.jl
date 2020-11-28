module sisoChannel

    function calculateChannelOutput(X::Array, Hcirc::Array{Complex,3}, Hisi::Array{Complex,3}, Nsps::Int, Nblocks::Int, N0::Float64)
        Y = zeros(Complex, Nsps, Nblocks)
        for kk = 1:Nblocks
            noi = (sqrt(N0)/sqrt(2)).*(randn(Nsps) + im*randn(Nsps))
            if kk == 1
                Y[:,kk] = Hcirc[kk,:,:]*X[:,kk] + noi
            else
                Y[:,kk] = Hcirc[kk,:,:]*X[:,kk] + Hisi[kk,:,:]*X[:,kk-1] + noi
            end
        end
        return Y
    end

    function generateRayleighCIR(Nsamples::Int, idxTapDelays::Vector, powTapDelaysDb::Vector, static=true)  
        Ntaps = maximum(idxTapDelays)
        powTapDelaysLin = [ 10^(p/10) for p in powTapDelaysDb ]  
        Hcir = zeros(Complex, Nsamples, Ntaps)
        for ii = 1:length(idxTapDelays)
            if static
                h = sqrt(powTapDelaysLin[ii]/2) * ( randn(Float64) + im*randn(Float64) )
                Hcir[:,idxTapDelays[ii]] = h*ones(Nsamples,1)
            else
                Hcir[:,idxTapDelays[ii]] = sqrt(powTapDelaysLin[ii]/2) * ( randn(Float64, Nsamples, 1) + im*randn(Float64, Nsamples, 1) )
            end
        end
        return Hcir
    end

    function generateCirculantChannelMatrix(Hcir::Array{Complex,2}, Nblocks::Int, Nsps::Int, Ntaps::Int)
        # convolution
        Hcirc = zeros(Complex, Nblocks, Nsps, Nsps)
        Hisi = zeros(Complex, Nblocks, Nsps, Nsps)
        for kk = 1:Nblocks, nn = 1:Nsps, mm = 1:Nsps
                    ii = (kk-1)*Nsps + nn
                    jj0 = nn - mm
                    jj1 = Nsps + nn - mm

                    if jj0 < 0 || jj0 > Ntaps - 1
                        Hcirc[kk, nn, mm] = 0;
                    else
                        Hcirc[kk, nn, mm] = Hcir[ii, jj0+1];
                    end

                    if jj1 < 0 || jj1 > Ntaps - 1
                        Hisi[kk, nn, mm] = 0;
                    else
                        Hisi[kk, nn, mm] = Hcir[ii, jj1+1];
                    end
        end
        return Hcirc, Hisi
    end

end