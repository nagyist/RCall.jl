@doc "Create a function call from a list of arguments"->
function lang(f::SEXPREC,args...;kwargs...)
    argn = length(args)+length(kwargs)
    l = preserve(sexp(ccall((:Rf_allocVector,libR),Ptr{Void},(Cint,Int),6,argn+1)))
    s = l.p
    ccall((:SETCAR,libR),Ptr{Void},(Ptr{Void},Ptr{Void}),s,f)
    for argv in args
        s = ccall((:CDR,libR),Ptr{Void},(Ptr{Void},),s)
        ccall((:SETCAR,libR),Ptr{Void},(Ptr{Void},Ptr{Void}),s,sexp(argv))
    end
    for (key,argv) in kwargs
        s = ccall((:CDR,libR),Ptr{Void},(Ptr{Void},),s)
        ccall((:SET_TAG,libR),Ptr{Void},(Ptr{Void},Ptr{Void}),s,sexp(key))
        ccall((:SETCAR,libR),Ptr{Void},(Ptr{Void},Ptr{Void}),s,sexp(argv))
    end
    l
end
lang(s::Symbol,args...;kwargs...) = lang(sexp(s),args...;kwargs...)

@doc """
Evaluate a function in the global environment. The first argument corresponds
to the function to be called. It can be either a RFunction type, a SymSxp or
a Symbol."""->
rcall(f::SEXPREC,args...;kwargs...) = reval(lang(f,args...;kwargs...))
rcall(f::Symbol,args...;kwargs...) = reval(lang(f,args...;kwargs...))

if VERSION >= v"v0.4-"
    Base.call(f::Union(SymSxp,LangSxp,RFunction),args...;kwargs...) = rcall(f,args...;kwargs...)
end
