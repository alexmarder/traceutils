import bz2
import gzip
import orjson as json
from subprocess import Popen, PIPE

from traceutils.scamper.hop cimport Hop, Trace, Reader, gettype
from traceutils.utils.net cimport find_family

cdef list create_hops(list hops, int family):
        cdef dict h
        if hops is not None:
            return [WartsHop(family=family, **h) for h in hops]
        return []


cdef class WartsTrace(Trace):

    def __init__(
            self, str type='', str version='', userid=-1, str method='', str src='', str dst='',
            int icmp_sum=-1, str stop_reason='', int stop_data=-1, dict start=None, int hop_count=-1,
            int attempts=-1, unsigned char hoplimit=0, unsigned char firsthop=1, double wait=-1,
            int wait_probe=-1, int tos=-1, unsigned short probe_size=0, unsigned int probe_count=0,
            list hops=None, str list_name='', int id=-1, str hostname='', long start_time=0,
            int dport=0, int sport=0, str rtr=None, str jdata=None
    ):
        self.src = src
        self.dst = dst
        self.family = find_family(dst.encode())
        self.allhops = create_hops(hops, self.family)
        self.hops = self.allhops
        self.jdata = jdata

        self.type = type
        self.version = version
        self.userid = userid
        self.method = method
        self.icmp_sum = icmp_sum
        self.stop_reason = stop_reason
        self.stop_data = stop_data
        self.start = start
        self.hop_count = hop_count
        self.attempts = attempts
        self.hoplimit = hoplimit
        self.firsthop = firsthop
        self.wait = wait
        self.wait_probe = wait_probe
        self.tos = tos
        self.probe_size = probe_size
        self.probe_count = probe_count
        self.dport = dport
        self.sport = sport
        self.rtr = rtr


cdef class WartsHop(Hop):

    def __init__(
            self, str addr='', unsigned char probe_ttl=0, int probe_id=-1, unsigned short probe_size=0,
            double rtt=-1, unsigned char reply_ttl=0, int reply_tos=-1, unsigned short reply_size=0,
            int reply_ipid=-1, unsigned char icmp_type=0, unsigned char icmp_code=0, unsigned char icmp_q_ttl=1,
            int icmp_q_ipl=-1, int icmp_q_tos=-1, list icmpext=None, int icmp_nhmtu=-1, int family=0, **kwargs
    ):
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
        self.icmpext = icmpext
        if icmpext:
            self.ismpls = 'mpls_labels' in icmpext[0]
        else:
            self.ismpls = False
        # self.num = iptoint(addr)

        self.probe_id = probe_id
        self.probe_size = probe_size
        self.reply_ipid = reply_ipid
        self.icmp_q_ipl = icmp_q_ipl
        self.icmp_nhmtu = icmp_nhmtu
        self.family = family
        self.type = gettype(family, icmp_type, icmp_code)


cdef class WartsPing:
    def __init__(
            self, str type='ping', str version=None, str method=None, str src=None, str dst=None, dict start=None,
            int ping_sent=-1, int probe_size=-1, int userid=-1, int ttl=-1, double wait=-1, int wait_us=-1,
            double timeout=-1, list responses=None, dict statistics=None,
            int dport = 0, int sport = 0, int tcp_seq = 0, int tcp_ack = 0, list flags = None, list probe_tsps = None
    ):
        self.type = type
        self.version = version
        self.method = method
        self.src = src
        self.dst = dst
        self.family = find_family(dst.encode())
        self.start = start
        self.ping_sent = ping_sent
        self.probe_size = probe_size
        self.userid = userid
        self.ttl = ttl
        self.wait = wait
        self.timeout = timeout
        self.responses = create_responses(responses, self.family)
        self.statistics = statistics
        self.dport = dport
        self.sport = sport
        self.tcp_seq = tcp_seq
        self.tcp_ack = tcp_ack
        self.flags = flags
        self.probe_tsps = probe_tsps

    def __repr__(self):
        result = ['Src={src}, Dst={dst}:'.format(src=self.src, dst=self.dst)]
        for resp in self.responses:
            result.append('\t{}'.format(repr(resp)))
        result.append(repr(self.statistics))
        return '\n'.join(result)


cdef list create_responses(list responses, int family):
    cdef dict resp
    resps = []
    for resp in responses:
        resp['src'] = resp.pop('from', None)
        resps.append(WartsPingResponse(family=family, **resp))
    return resps


cdef class WartsPingResponse:
    def __init__(
            self, str src=None, int seq=-1, int reply_size=-1, int reply_ttl=-1, str reply_proto=None, dict tx=None, dict rx=None,
            double rtt=-1, int probe_ipid=-1, int reply_ipid=-1, int icmp_type=-1, int icmp_code=-1, int family=0,
            list tsandaddr = None, RR=None
    ):
        self.src = src
        self.seq = seq
        self.reply_size = reply_size
        self.reply_ttl = reply_ttl
        self.reply_proto = reply_proto
        self.tx = tx
        self.rx = rx
        self.rtt = rtt
        self.probe_ipid = probe_ipid
        self.reply_ipid = reply_ipid
        self.icmp_type = icmp_type
        self.icmp_code = icmp_code
        self.family = family
        self.tsandaddr = tsandaddr
        self.RR = RR
        self.type = gettype(family, icmp_type, icmp_code)

    def __repr__(self):
        return 'RTT={rtt}'.format(rtt=self.rtt)

cdef class AbstractWartsReader(Reader):
    def __init__(self, str filename, bint trace=True, bint ping=True, bint safe=True):
        self.filename = filename
        self.f = None
        self.trace = trace
        self.ping = ping
        self.hostname = None
        self.firstline = None
        self.safe = safe

    def safe_iter(self):
        cdef:
            str line
        if not self.safe:
            return self.f
        fiter = iter(self.f)
        while True:
            try:
                line = next(fiter)
                yield line
            except StopIteration:
                break
            except EOFError as e:
                print(e, self.filename)

    def __iter__(self):
        cdef:
            str line, rtype
            dict j
        if self.firstline is not None:
            rtype = self.firstline['type']
            if rtype == 'trace' and self.trace:
                yield WartsTrace(jdata=str(self.firstline), **self.firstline)
            elif rtype == 'ping' and self.ping:
                yield WartsPing(**self.firstline)
        for line in self.safe_iter():
            j = json.loads(line)
            rtype = j['type']
            if rtype == 'trace':
                if self.trace:
                    yield WartsTrace(jdata=line, **j)
            elif rtype == 'ping':
                if self.ping:
                    yield WartsPing(**j)

    def json(self):
        cdef:
            str line
        if self.firstline is not None:
            yield self.firstline
        for line in self.safe_iter():
            j = json.loads(line)
            yield j

    cdef void set_hostname(self) except *:
        cdef:
            str line
            dict j
        for line in self.f:
            # print(line)
            j = json.loads(line)
            if j['type'] == 'cycle-start':
                self.hostname = j['hostname']
            else:
                self.firstline = j
                # print(self.firstline)
            break

    def raw(self):
        if self.firstline is not None:
            yield self.firstline
        yield from self.safe_iter()

cdef class WartsReader(AbstractWartsReader):
    def __init__(self, str filename, bint trace=True, bint ping=True, bint safe=True):
        super().__init__(filename, trace=trace, ping=ping)
        self.p = None

    cpdef void open(self) except *:
        cdef str cmd
        if self.filename.endswith('.bz2') or self.filename.endswith('.bzip2'):
            cmd = 'bzip2 -d -c {} | sc_warts2json'
        elif self.filename.endswith('.gz'):
            cmd = 'gzip -d -c {} | sc_warts2json'
        else:
            cmd = 'sc_warts2json {}'
        self.p = Popen(cmd.format(self.filename), stdout=PIPE, shell=True, universal_newlines=True)
        self.f = self.p.stdout
        self.set_hostname()

    cpdef void close(self) except *:
        self.f.close()
        self.p.wait()
        self.p = None

cdef class WartsJsonReader(AbstractWartsReader):
    cpdef void open(self) except *:
        cdef str cmd
        if self.filename.endswith('.bz2') or self.filename.endswith('.bzip2'):
            self.f = bz2.open(self.filename, 'rt')
        elif self.filename.endswith('.gz'):
            self.f = gzip.open(self.filename, 'rt')
        else:
            self.f = open(self.filename, 'rt')
        self.set_hostname()

    cpdef void close(self) except *:
        self.f.close()

# cdef class WartsReader(Reader):
#     def __init__(self, str filename, bint trace=True, bint ping=True):
#         self.filename = filename
#         self.p = None
#         self.trace = trace
#         self.ping = ping
#         self.hostname = None
#         self.f = None
#
#     def __iter__(self):
#         cdef str line, rtype
#         cdef dict j
#         for line in self.p.stdout:
#             j = json.loads(line)
#             rtype = j['type']
#             if rtype == 'trace':
#                 if self.trace:
#                     yield WartsTrace(jdata=line, **j)
#             elif rtype == 'ping':
#                 if self.ping:
#                     yield WartsPing(**j)
#
#     def json(self):
#         for line in self.p.stdout:
#             j = json.loads(line)
#             yield j
#
#     def raw(self):
#         return self.p.stdout
#
#     cpdef void open(self) except *:
#         cdef str cmd
#         if self.filename.endswith('.bz2') or self.filename.endswith('.bzip2'):
#             cmd = 'bzip2 -d -c {} | sc_warts2json'
#         elif self.filename.endswith('.gz'):
#             cmd = 'gzip -d -c {} | sc_warts2json'
#         else:
#             cmd = 'sc_warts2json {}'
#         self.p = Popen(cmd.format(self.filename), stdout=PIPE, shell=True, universal_newlines=True)
#         for line in self.f:
#             break
#         j = json.loads(line)
#         if j['type'] == 'cycle-start':
#             self.hostname = j['hostname']
#
#     cpdef void close(self) except *:
#         self.p.stdout.close()
#         self.p.wait()
#         self.p = None
#
# cdef class WartsJsonReader(Reader):
#     def __init__(self, str filename, bint trace=True, bint ping=True):
#         self.filename = filename
#         self.f = None
#         self.trace = trace
#         self.ping = ping
#         self.hostname = None
#
#     def __iter__(self):
#         cdef str line, rtype
#         cdef dict j
#         for line in self.f:
#             j = json.loads(line)
#             rtype = j['type']
#             if rtype == 'trace':
#                 if self.trace:
#                     try:
#                         yield WartsTrace(jdata=line, **j)
#                     except:
#                         print(line)
#                         raise
#             elif rtype == 'ping':
#                 if self.ping:
#                     yield WartsPing(**j)
#
#     def json(self):
#         for line in self.f:
#             j = json.loads(line)
#             yield j
#
#     def raw(self):
#         return self.f
#
#     cpdef void open(self) except *:
#         cdef str cmd
#         if self.filename.endswith('.bz2') or self.filename.endswith('.bzip2'):
#             self.f = bz2.open(self.filename, 'rt')
#         elif self.filename.endswith('.gz'):
#             self.f = gzip.open(self.filename, 'rt')
#         else:
#             self.f = open(self.filename, 'rt')
#         for line in self.f:
#             break
#         j = json.loads(line)
#         if j['type'] == 'cycle-start':
#             self.hostname = j['hostname']
#         else:
#             self.f.seek(0)
#
#     cpdef void close(self) except *:
#         self.f.close()
