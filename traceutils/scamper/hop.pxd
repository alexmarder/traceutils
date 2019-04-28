from traceutils.radix.ip2as cimport IP2AS

cdef class Hop:
    cdef public str addr
    cdef public unsigned char probe_ttl
    cdef public double rtt
    cdef public unsigned char reply_ttl
    cdef public int reply_tos
    cdef public int reply_size
    cdef public unsigned char icmp_type
    cdef public unsigned char icmp_code
    cdef public unsigned char icmp_q_ttl
    cdef public int icmp_q_tos
    cdef public bytes packed
    cdef public bint ismpls

    cpdef bytes set_packed(self);


cdef class Trace:
    cdef public str src
    cdef public str dst
    cdef public list hops
    cdef public list loop

    cpdef list addrs(self);
    cpdef void prune_dups(self) except *;
    cpdef void prune_loops(self) except *;
    cpdef void prune_private(self, IP2AS ip2as) except *
    cpdef void set_packed(self) except *;

cdef class Reader:
    cdef public str filename
    cdef public p

    cpdef void open(self) except *;
    cpdef void close(self) except *;

# cpdef unsigned long iptoint(str addr) except -1;