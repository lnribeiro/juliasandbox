
#### Bit and symbol generation ####

function generateBitstream(numBits::Int)
    return rand(0:1, numBits)
end

function bitstream2symbolstream(bitstream::Vector{Int}, pad::Int)
    @assert length(bitstream) % pad == 0
    numsymbols = Int(length(bitstream)/pad)
    bitmatrix = reshape(bitstream, (pad, numsymbols))
    symbolstream = Vector{Int}(undef, numsymbols)
    for n = 1:numsymbols
        digits = bitmatrix[:, n]
        symbolstream[n] = sum([digits[k]*2^(k-1) for k = 1:length(digits)])
    end
    return symbolstream
end

function symbolstream2bitstream(symbolstream::Vector{Int}, pad::Int)
    numsymbols = length(symbolstream)
    bitmatrix = zeros(Int, pad, numsymbols)
    for n = 1:numsymbols
        digits = Base.digits(symbolstream[n], base=2, pad=pad)
        bitmatrix[:,n] = digits
    end
    bitstream = vec(bitmatrix)
    return bitstream
end

#### Coding ####

# https://rosettacode.org/wiki/Gray_code#Julia
function encodeGray(n::Integer) 
    return n ⊻ (n >> 1)
end

function decodeGray(n::Integer)
    r = n
    while (n >>= 1) != 0
        r ⊻= n
    end
    return r
end
