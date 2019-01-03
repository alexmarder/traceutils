from traceutils.scamper.hop import Hop


class AtlasErrorException(Exception):
    pass


class AtlasTrace:
    def __init__(self, af=None, dst_addr=None, dst_name=None, endtime=None, fw=None, group_id=None, lts=None, msm_id=None, msm_name=None, paris_id=None, prb_id=None, proto=None, result=None, size=None, src_addr=None, timestamp=None, type=None, **kwargs):
        self.af = af
        self.dst_addr = dst_addr
        self.dst_name = dst_name
        self.endtime = endtime
        self.fw = fw
        self.group_id = group_id
        self.lts = lts
        self.msm_id = msm_id
        self.msm_name = msm_name
        self.paris_id = paris_id
        self.prb_id = prb_id
        self.proto = proto
        self.result = result
        self.size = size
        self.src_addr = src_addr
        self.timestamp = timestamp
        self.type = type


class AtlasHop(Hop):
    def __init__(self, hop=-1, addr=None, rtt=float('nan'), size=-1, ttl=-1, err=None, itos=0, ittl=1, flags=None, icmpext=None, late=0, dup=0, edst=None, hdropts=None):
        if err is None:
            icmp_type = 11
            icmp_code = 0
        else:
            icmp_type = 3
            if err == 'N':
                icmp_code = 0
            elif err == 'H':
                icmp_code = 1
            elif err == 'A':
                icmp_code = 13
            elif err == 'P':
                icmp_code = 2
            elif err == 'p':
                icmp_code = 3
            elif isinstance(err, int):
                icmp_code = err
            else:
                raise AtlasErrorException('Unknown error code: {}'.format(err))
        super().__init__(addr=addr, probe_ttl=hop, rtt=rtt, reply_ttl=ttl, reply_size=size, icmp_type=icmp_type, icmp_code=icmp_code, icmpext=icmpext, reply_tos=itos, icmp_q_ttl=ittl)
        self.flags = flags
        self.late = late
        self.dup = dup
        self.edst = edst
        self.hdropts = hdropts
