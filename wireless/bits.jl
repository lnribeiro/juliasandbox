
function generateBitstream(numBits::Int)
    return rand(0:1, numBits)
end

function bit2symbol(bitvector::Vector{Int})
    symlen = length(bitvector)
    exps = exp2.(0:(symlen-1))
    symbol = Int(bitvector'*exps)
    return symbol
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
    # symbolstream = [ bit2Symbol(bitmatrix[:, sym]) for sym = 1:numsymbols ]
    
    # return symbolstream, bitmatrix
    return symbolstream
end