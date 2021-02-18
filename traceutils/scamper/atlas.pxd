from traceutils.file2.file2 cimport File2
from traceutils.scamper.hop cimport Hop, Trace, Reader

cdef extern from '<arpa/inet.h>':
    cdef int AF_INET, AF_INET6

cdef class AtlasHop(Hop):
    cdef:
        public dict icmpext
        public str flags
        public int late
        public int dup
        public str edst
        list hdropts

cdef class AtlasTrace(Trace):
    cdef:
        public int af
        public str dst_name, proto, type
        public long endtime, timestamp
        public list result

cdef class AtlasReader(Reader):
    cdef File2 f
