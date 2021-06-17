from traceutils.utils.dicts cimport StrDict, EmptyDict

cdef class AS2Org:
    cdef:
        public StrDict orgs
        public StrDict asn_names
        public StrDict asn_org_names
        readonly EmptyDict siblings
        public dict org_cc

    cpdef str name(self, int asn);
    cpdef str asn_name(self, int asn);
    cpdef str asn_cc(self, int asn);