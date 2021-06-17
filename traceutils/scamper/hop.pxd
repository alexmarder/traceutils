from traceutils.radix.ip2as cimport IP2AS
cdef extern from '<arpa/inet.h>':
    cdef int AF_INET, AF_INET6

cpdef enum TraceFType:
    none = 0
    warts = 1
    wartsjson = 2
    atlas = 3

cpdef enum ICMPType:
    echo_reply = 1
    dest_unreach = 2
    ptb = 3
    time_exceeded = 4
    echo_request = 5
    spoofing = 6
    portping = 7
    net_unreach = 8
    host_unreach = 9

cpdef ICMPType gettype(int family, int icmp_type, int icmp_code) except *;

cdef class Hop:
    cdef:
        public str addr
        public unsigned char probe_ttl
        public double rtt
        public unsigned char reply_ttl
        public int reply_tos
        public int reply_size
        public unsigned char icmp_type
        public unsigned char icmp_code
        public unsigned char icmp_q_ttl
        public int icmp_q_tos
        public bytes packed
        public bint ismpls
        public int family
        public ICMPType type

    cpdef bytes set_packed(self);


cdef class Trace:
    cdef:
        public str src
        public str dst
        public list hops, allhops
        public list loop
        public int family
        public str jdata

    cpdef list addrs(self);
    cpdef unsigned char mark_loop(self) except? -1;
    cpdef void prune_dups(self) except *;
    cpdef void prune_loops(self, bint keepfirst=*) except *;
    cpdef void prune_private(self, IP2AS ip2as) except *
    cpdef void prune_src(self, str src2=*) except *;
    cpdef void set_packed(self) except *;

cdef class Reader:
    cdef:
        public str filename
        public p

    cpdef void open(self) except *;
    cpdef void close(self) except *;

# cpdef unsigned long iptoint(str addr) except -1;