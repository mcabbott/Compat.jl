# The @compat macro is used to implement compatibility rules that require
# syntax rewriting rather than simply new function/constant/module definitions.

export @compat

_compat(inref::Bool) = ex -> _compat(ex, inref)

function _compat(ex::Expr, inref::Bool=false)
    if ex.head === :quote && isa(ex.args[1], Symbol)
        # Passthrough
        return ex
    elseif ex.head === :ref
        return Expr(:ref, _compat(ex.args[1]), map(_compat(true), ex.args[2:end])...)
    end
    return Expr(ex.head, map(_compat(inref), ex.args)...)
end

function _compat(ex::Symbol, inref::Bool=false)
    if ex === :begin && inref
        return :($FirstIndex())
    end
    return ex
end

struct FirstIndex end

Base.to_indices(A::AbstractArray, ax::Tuple, I::Tuple{FirstIndex, Vararg}) =
    (first(first(ax)), Base.to_indices(A, Base.tail(ax), Base.tail(I))...)

_compat(ex, inref::Bool=false) = ex

macro compat(ex)
    ex = macroexpand(__module__, ex)
    esc(_compat(ex))
end
