from traceutils.scamper.hop cimport Hop, Trace, Reader, ICMPType

cdef class WartsHop(Hop):
    cdef public list icmpext
    cdef public int probe_id
    cdef public unsigned short probe_size
    cdef public int reply_ipid
    cdef public int icmp_q_ipl
    cdef public int icmp_nhmtu


cdef class WartsTrace(Trace):
    cdef public str type
    cdef public str version
    cdef public int userid
    cdef public str method
    cdef public int icmp_sum
    cdef public str stop_reason
    cdef public int stop_data
    cdef public dict start
    cdef public int hop_count
    cdef public int attempts
    cdef public unsigned char hoplimit
    cdef public unsigned char firsthop
    cdef public double wait
    cdef public int wait_probe
    cdef public int tos
    cdef public unsigned char probe_size
    cdef public unsigned char probe_count
    cdef public int dport
    cdef public int sport

cdef class WartsPing:
    cdef public str type, version, method, src, dst
    cdef public dict start, statistics
    cdef public int ping_sent, probe_size, userid, ttl, wait_us
    cdef public double wait, timeout
    cdef public list responses
    cdef public int family
    cdef public int dport
    cdef public int sport
    cdef public int tcp_seq
    cdef public int tcp_ack
    cdef public list flags
    cdef public list probe_tsps

cdef list create_responses(list responses, int family);

cdef class WartsPingResponse:
    cdef public int seq, reply_size, reply_ttl, probe_ipid, reply_ipid, icmp_type, icmp_code
    cdef public str reply_proto
    cdef public dict tx, rx
    cdef public double rtt
    cdef public int family
    cdef public ICMPType type
    cdef public list tsandaddr

cdef class WartsReader(Reader):
    cdef bint trace
    cdef bint ping

    cpdef void open(self) except *;
    cpdef void close(self) except *;
