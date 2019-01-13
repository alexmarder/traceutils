from traceutils.utils.net cimport inet_pton_auto_str

cdef class Hop:

    def __repr__(self):
        return '{ttl:02d}: {addr}'.format(addr=self.addr, ttl=self.probe_ttl)

    cpdef bytes set_packed(self):
        self.packed = inet_pton_auto_str(self.addr)
        return self.packed


cdef class Trace:

    def __repr__(self):
        return '\n'.join(repr(hop) for hop in self.hops)

    cpdef list addrs(self):
        cdef Hop h
        return [h.addr for h in self.hops]

    cpdef void prune_dups(self) except *:
        cdef str prev = None
        cdef list hops = []
        cdef int i
        for i in range(len(self.hops)):
        # for hop in self.hops:
            hop = self.hops[i]
            if hop.addr != prev:
                hops.append(hop)
                prev = hop.addr
        self.hops = hops

    cpdef void prune_loops(self) except *:
        cdef set seen = set()
        cdef int end = len(self.hops), i
        cdef str addr
        for i in range(len(self.hops) - 1, -1, -1):
            addr = self.hops[i].addr
            if addr in seen:
                end = i
            else:
                seen.add(addr)
        if end < len(self.hops):
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
