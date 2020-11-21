
function generateBitstream(numBits::Int)
    return rand(0:1, numBits)
end

function bit2symbol(bitvector::Vector{Int})
    symlen = length(bitvector)
    exps = exp2.(0:(symlen-1))
    symbol = Int(bitvector'*exps)
    return symbol
end

function symbol2bit(symbol::Int, symLen::Int)
    bits = Int[]
    for i in 0:(symLen-1)
        push!(bits, (symbol >> i) & 1)
    end
    return bits
end

function bitstream2symbolstream(bitstream::Vector{Int}, symlen::Int)
    @assert length(bitstream) % symlen == 0
    numsymbols = Int(length(bitstream)/symlen)
    bitmatrix = reshape(bitstream, (symlen, numsymbols))
    symbolstream = Vector{Int}(undef, numsymbols)
    for n = 1:numsymbols
        bitvector = bitmatrix[:, n]
        symbolstream[n] = bit2symbol(bitvector)
    end
    return symbolstream
end

function symbolstream2bitstream(symbolstream::Vector{Int}, symlen::Int)
    numsymbols = length(symbolstream)
    bitmatrix = zeros(Int, symlen, numsymbols)
    for n = 1:numsymbols
        bitvector = symbol2bit(symbolstream[n], symlen)
        bitmatrix[:,n] = bitvector
    end
    bitstream = vec(bitmatrix)
    return bitstream
end