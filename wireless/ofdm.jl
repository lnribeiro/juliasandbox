module ofdmSISO

    import LinearAlgebra
    import FFTW

    struct Param

        Wfft
        Tcp
        Rcp
        Nfft::Int
        Ncp::Int
        Nblocks::Int

        function Param(Nfft::Int, Ncp::Int, Nblocks::Int)
            Isc = Matrix{Float64}(LinearAlgebra.I(Nfft));
            Icp = Isc[Nfft-Ncp+1:end,:];
            Wfft = (1/sqrt(Nfft))*FFTW.fft(LinearAlgebra.I(Nfft),1);
            Tcp = vcat(Icp, Isc);                # insert CP
            Rcp = hcat(zeros(Nfft, Ncp), Matrix{Float64}(LinearAlgebra.I(Nfft)) );    # remove CP
            new(Wfft, Tcp, Rcp, Nfft, Ncp, Nblocks) 
        end

    end

    function modulator(param::Param, X::Array)
        Xcp = param.Tcp*(param.Wfft')*X;
        return Xcp
    end

    function demodulator(param::Param, Ycp::Array)
        Y = (param.Wfft)*(param.Rcp)*Ycp;
        return Y
    end

    function formPerfectCSI(param::Param, Hcirc::Array)
        Hest = zeros(Complex, param.Nblocks, param.Nfft, param.Nfft)
        for kk = 1:param.Nblocks
            Hest[kk,:,:] = param.Wfft*param.Rcp*Hcirc[kk,:,:]*param.Tcp*(param.Wfft')
        end
        return Hest
    end

    function equalizerOneTap(param::Param, Hest::Array, Y::Array)
        Xest = zeros(Complex, param.Nfft, param.Nblocks)
        for kk = 1:param.Nblocks
            equalizer = inv(LinearAlgebra.diagm(LinearAlgebra.diag(Hest[kk,:,:])))
            Xest[:,kk] = equalizer*Y[:,kk]
        end  
        return Xest
    end

end