from traceutils.scamper.hop cimport Hop, Trace, Reader, ICMPType

cdef class WartsHop(Hop):
    cdef:
        public list icmpext
        public int probe_id
        public unsigned short probe_size
        public int reply_ipid
        public int icmp_q_ipl
        public int icmp_nhmtu


cdef class WartsTrace(Trace):
    cdef:
        public str type
        public str version
        public userid
        public str method
        public int icmp_sum
        public str stop_reason
        public int stop_data
        public dict start
        public int hop_count
        public int attempts
        public unsigned char hoplimit
        public unsigned char firsthop
        public double wait
        public int wait_probe
        public int tos
        public unsigned char probe_size
        public unsigned int probe_count
        public int dport
        public int sport
        public str rtr

cdef class WartsPing:
    cdef:
        public str type, version, method, src, dst
        public dict start, statistics
        public int ping_sent, probe_size, userid, ttl, wait_us
        public double wait, timeout
        public list responses
        public int family
        public int dport
        public int sport
        public int tcp_seq
        public int tcp_ack
        public list flags
        public list probe_tsps

cdef list create_responses(list responses, int family);

cdef class WartsPingResponse:
    cdef:
        public int seq, reply_size, reply_ttl, probe_ipid, reply_ipid, icmp_type, icmp_code
        public str src, reply_proto
        public dict tx, rx
        public double rtt
        public int family
        public ICMPType type
        public list tsandaddr
        public list RR

cdef class AbstractWartsReader(Reader):
    cdef:
        bint trace
        bint ping
        public str hostname
        f
        public dict firstline
        bint safe

    cdef void set_hostname(self) except *;

cdef class WartsReader(AbstractWartsReader):
    pass

cdef class WartsJsonReader(AbstractWartsReader):
    pass

# cdef class WartsReader(Reader):
#     cdef:
#         bint trace
#         bint ping
#         str hostname
#
#     cpdef void open(self) except *;
#     cpdef void close(self) except *;
#
# cdef class WartsJsonReader(Reader):
#     cdef:
#         bint trace
#         bint ping
#         str hostname
#         f
#
#     cpdef void open(self) except *;
#     cpdef void close(self) except *;
