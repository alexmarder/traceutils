from traceutils.file2.file2 cimport File2
from traceutils.scamper.hop cimport Hop, Trace, Reader

cdef class AtlasHop(Hop):
    cdef public dict icmpext
    cdef public str flags
    cdef public int late
    cdef public int dup
    cdef public str edst
    cdef list hdropts

cdef class AtlasTrace(Trace):
    cdef public int af, fw, group_id, lts, msm_id, paris_id, prb_id, size
    cdef public str dst_addr, dst_name, msm_name, proto, src_addr, type
    cdef public long endtime, timestamp
    cdef public list result

cdef class AtlasReader(Reader):
    # cdef str filename
    cdef File2 f
