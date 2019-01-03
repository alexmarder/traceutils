from cscamper.hop cimport Hop, Trace, Reader

cdef class WartsHop(Hop):
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

cdef class WartsReader(Reader):
    cpdef void open(self) except *;
    cpdef void close(self) except *;
