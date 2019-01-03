from traceutils.scamper.hop cimport Hop

cdef class AtlasHop(Hop):
    cdef public str flags
    cdef public int late
    cdef public int dup
    cdef public str edst
    cdef dict hdropts
