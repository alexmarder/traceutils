from traceutils.radix.ip2as cimport IP2AS
cdef extern from '<arpa/inet.h>':
    cdef int AF_INET, AF_INET6

cpdef enum ICMPType:
    echo_reply = 1
    dest_unreach = 2
    ptb = 3
    time_exceeded = 4
    echo_request = 5
    spoofing = 6
    portping = 7

cpdef ICMPType gettype(int family, int icmp_type, int icmp_code) except *;

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
    cdef public int family
    cdef public ICMPType type

    cpdef bytes set_packed(self);


cdef class Trace:
    cdef public str src
    cdef public str dst
    cdef public list hops, allhops
    cdef public list loop
    cdef public int family

    cpdef list addrs(self);
    cpdef void prune_dups(self) except *;
    cpdef void prune_loops(self, bint keepfirst=*) except *;
    cpdef void prune_private(self, IP2AS ip2as) except *
    cpdef void set_packed(self) except *;

cdef class Reader:
    cdef public str filename
    cdef public p

    cpdef void open(self) except *;
    cpdef void close(self) except *;

# cpdef unsigned long iptoint(str addr) except -1;