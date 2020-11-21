
function filterZeros(vec::Vector)
    return [ x == 0 ? NaN : x for x in vec]
end