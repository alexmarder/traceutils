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

    def __str__(self):
        return str(self.prefix)

    def __repr__(self):
        return 'Prefix<{}>'.format(self.prefix)

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

cdef class RadixNodeASN(RadixNode):
    def __init__(self, RadixPrefix prefix=None, unsigned char prefix_size=0, RadixNode parent=None, int asn=0):
        super().__init__(prefix, prefix_size, parent)
        self.asn = asn

    def __repr__(self):
        return '<{} ASN={}>'.format(self.prefix, self.asn)

cdef class RadixNodeASNs(RadixNode):
    def __init__(self, RadixPrefix prefix=None, unsigned char prefix_size=0, RadixNode parent=None, list asns=None):
        super().__init__(prefix, prefix_size, parent)
        self.asns = asns

    def __repr__(self):
        return '<{} ASNs={}>'.format(self.prefix, self.asns)

cdef class RadixNodeData(RadixNode):
    def __init__(self, RadixPrefix prefix=None, unsigned char prefix_size=0, RadixNode parent=None, **kwargs):
        super().__init__(prefix, prefix_size, parent)
        self.data = kwargs

    def __repr__(self):
        return '<{} Data={}>'.format(self.prefix, self.data)
