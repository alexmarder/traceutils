import json
from typing import List, Any, Dict

from jsonschema import validate
from traceutils.scamper.hop import Hop, Trace, Reader

from traceutils.file2.file2 import File2


class AtlasErrorException(Exception):
    pass


class AtlasHop(Hop):
    def __init__(self, hop=-1, rtt=float('nan'), size=-1, ttl=-1, err=None, itos=0, ittl=1, flags=None, icmpext=None, late=0, dup=0, edst=None, hdropts=None, **kwargs):
        if err is None:
            icmp_type = 11
            icmp_code = 0
        else:
            icmp_type = 3
            if isinstance(err, str):
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
                else:
                    raise AtlasErrorException('Unknown error code: {}'.format(err))
            elif isinstance(err, int):
                icmp_code = err
            else:
                raise AtlasErrorException('Unknown error code: {}'.format(err))
        self.addr = kwargs.get('from')
        self.probe_ttl = hop
        self.rtt = rtt
        self.reply_ttl = ttl
        self.reply_size = size
        self.icmp_type = icmp_type
        self.icmp_code = icmp_code
        self.icmpext = icmpext
        self.ismpls = bool(icmpext)
        self.reply_tos = itos
        self.icmp_q_ttl = ittl

        self.flags = flags
        self.late = late
        self.dup = dup
        self.edst = edst
        self.hdropts = hdropts


class AtlasTrace(Trace):
    def __init__(self, af=0, dst_addr='', dst_name='', endtime=0, fw=0, group_id=0, lts=0, msm_id=0, msm_name='', paris_id=0, prb_id=0, proto='', result=None, size=0, src_addr='', timestamp=0, type='', **kwargs):
        print('in AtlasTrace: {}'.format(result))
        super().__init__(src_addr, dst_addr, create_hops(result))
        # self.src = src_addr
        # self.dst = dst_addr
        # self.hops = create_hops(result)

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


def create_hops(hops: List[Dict[str, Any]]):
    hopslist = []
    if hops is not None:
        for i in range(len(hops)):
            h = hops[i]
            results = h.get('result')
            if not results:
                continue
            for result in h['result']:
                if 'from' in result:
                    hop = AtlasHop(hop=h['hop'], **result)
                    hopslist.append(hop)
                    break
    return hopslist


class AtlasReader(Reader):
    def __init__(self, filename):
        super().__init__()
        self.filename = filename
        self.f = None
        with open('../traceutils/scamper/schema1.json') as f:
            self.schema = json.load(f)

    def __iter__(self):
        for line in self.f:
            j = json.loads(line)
            # print(j)
            if isinstance(j, list):
                for result in j:
                    if not 'type' in result or result['type'] == 'traceroute':
                        validate(j, self.schema)
                        yield AtlasTrace(**result)
            else:
                result = j
                if not 'type' in result or result['type'] == 'traceroute':
                    print('Validating')
                    validate(j, self.schema)
                    yield AtlasTrace(**result)

    def open(self):
        self.f = File2(self.filename)
        self.f.open()

    def close(self):
        self.f.close()
