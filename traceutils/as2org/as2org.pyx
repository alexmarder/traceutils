from traceutils.file2.file2 cimport File2
from traceutils.utils.dicts cimport StrDict, EmptyDict

cdef class AS2Org:

    def __init__(self, str filename, str additional=None):
        cdef dict org_names, siblings
        cdef set v

        self.orgs = StrDict()
        self.asn_names = StrDict()
        self.asn_org_names = StrDict()
        self.siblings = EmptyDict()
        self.org_cc = {}
        org_names = {}
        read_org = False
        read_asn = False
        with File2(filename) as f:
            for line in f:
                line = line.strip()
                # if line == '# format:org_id|changed|org_name|country|source':
                if line.startswith('# format:org_id|changed|org_name|country'):
                    read_org = True
                    read_asn = False
                # elif line == '# format:aut|changed|aut_name|org_id|opaque_id|source':
                elif line.startswith('# format:aut|changed|aut_name|org_id'):
                    read_asn = True
                    read_org = False
                elif read_org:
                    org_id, changed, org_name, country, *extra = line.split('|')
                    org_names[org_id] = org_name
                    self.org_cc[org_id] = country
                elif read_asn:
                    aut, changed, aut_name, org_id, *extra = line.split('|')
                    asn = int(aut)
                    self.orgs[asn] = org_id
                    self.asn_names[asn] = aut_name
        for asn, org_id in self.orgs.items():
            self.asn_org_names[asn] = org_names[org_id]
        if additional:
            with File2(additional) as f:
                for line in f:
                    if line.strip():
                        if not line.startswith('#'):
                            splits = list(map(int, line.split()))
                            asn = splits[0]
                            for other in splits[1:]:
                                self.orgs[other] = self.orgs[asn]
                                self.asn_org_names[other] = self.asn_org_names[asn]
        siblings = {}
        for k in set(self.orgs.values()):
            siblings[k] = set()
        for asn, org_id in self.orgs.items():
            siblings[org_id].add(asn)
        for v in siblings.values():
            for asn in v:
                self.siblings[asn] = v

    def __getitem__(self, item):
        return self.orgs[item]

    cpdef str name(self, int asn):
        return self.asn_org_names[asn]

    cpdef str asn_name(self, int asn):
        return self.asn_names[asn]

    cpdef str asn_cc(self, int asn):
        return self.org_cc.get(self[asn], 'NA')
