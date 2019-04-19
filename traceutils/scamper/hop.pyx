from traceutils.utils.net cimport inet_pton_auto_str

cdef class Hop:

    def __init__(self, str addr, unsigned char probe_ttl, double rtt, unsigned char reply_ttl, int reply_tos, int reply_size, unsigned char icmp_type, unsigned char icmp_code, unsigned char icmp_q_ttl, int icmp_q_tos):
        self.addr = addr
        self.probe_ttl = probe_ttl
        self.rtt = rtt
        self.reply_ttl = reply_ttl
        self.reply_tos = reply_tos
        self.reply_size = reply_size
        self.icmp_type = icmp_type
        self.icmp_code = icmp_code
        self.icmp_q_ttl = icmp_q_ttl
        self.icmp_q_tos = icmp_q_tos

    def __repr__(self):
        return '{ttl:02d}: {addr}'.format(addr=self.addr, ttl=self.probe_ttl)

    cpdef bytes set_packed(self):
        self.packed = inet_pton_auto_str(self.addr)
        return self.packed


cdef class Trace:

    def __init__(self, str src, str dst, list hops):
        self.src = src
        self.dst = dst
        self.hops = hops
        self.loop = None

    def __repr__(self):
        return '\n'.join(repr(hop) for hop in self.hops)

    cpdef list addrs(self):
        cdef Hop h
        return [h.addr for h in self.hops]

    cpdef void prune_dups(self) except *:
        cdef str prev = None, haddr
        cdef list hops = []
        cdef int i
        for i in range(len(self.hops)):
            hop = self.hops[i]
            haddr = hop.addr
            if haddr != prev:
                hops.append(hop)
                prev = haddr
        self.hops = hops

    cpdef void prune_loops(self) except *:
        cdef set seen = set()
        cdef int end = len(self.hops), i
        cdef str addr
        prev = None
        for i in range(len(self.hops) - 1, -1, -1):
            addr = self.hops[i].addr
            if addr in seen and addr != prev:
                end = i
            else:
                seen.add(addr)
            prev = addr
        if end < len(self.hops):
            self.loop = self.hops[end+1:]
            self.hops = self.hops[:end+1]


    cpdef void set_packed(self) except *:
        for hop in self.hops:
            hop.set_packed()


cdef class Reader:

    def __enter__(self):
        self.open()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()
        return False

    cpdef void open(self) except *:
        raise NotImplementedError()

    cpdef void close(self) except *:
        raise NotImplementedError()
