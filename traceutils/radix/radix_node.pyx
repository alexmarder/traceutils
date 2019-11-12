from traceutils.radix.radix_prefix cimport RadixPrefix


cdef class RadixNode:
    def __init__(self, RadixPrefix prefix=None, unsigned char prefix_size=0, RadixNode parent=None):
        if prefix is not None:
            self.prefix = prefix
            self.bitlen = self.prefix.bitlen
        else:
            self.prefix = None
            self.bitlen = prefix_size
            self.parent = parent
        self.left = None
        self.right = None
        self.asn = 0
        # self.data = None

    def __str__(self):
        return str(self.prefix)

    def __repr__(self):
        return '<{} AS{}>'.format(self.prefix, self.asn)

    @property
    def network(self):
        return self.prefix.network()

    @property
    def prefixlen(self):
        return self.bitlen

    @property
    def family(self):
        return self.prefix.family

    @property
    def packed(self):
        return self.prefix.packed
