import ujson as json
from subprocess import Popen, PIPE

from traceutils.scamper.hop cimport Hop, Trace, Reader

cdef list create_hops(list hops):
        cdef dict h
        if hops is not None:
            return [WartsHop(**h) for h in hops]
        return []


cdef class WartsTrace(Trace):

    def __init__(
            self, str type='', str version='', int userid=-1, str method='', str src='', str dst='',
            int icmp_sum=-1, str stop_reason='', int stop_data=-1, dict start=None, int hop_count=-1,
            int attempts=-1, unsigned char hoplimit=0, unsigned char firsthop=1, double wait=-1,
            int wait_probe=-1, int tos=-1, unsigned short probe_size=0, unsigned char probe_count=0,
            list hops=None, str list_name='', int id=-1, str hostname='', long start_time=0
    ):
        self.src = src
        self.dst = dst
        self.hops = create_hops(hops)

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


cdef class WartsHop(Hop):

    def __init__(
            self, str addr='', unsigned char probe_ttl=0, int probe_id=-1, unsigned short probe_size=0,
            double rtt=-1, unsigned char reply_ttl=0, int reply_tos=-1, unsigned short reply_size=0,
            int reply_ipid=-1, unsigned char icmp_type=0, unsigned char icmp_code=0, unsigned char icmp_q_ttl=1,
            int icmp_q_ipl=-1, int icmp_q_tos=-1, list icmpext=None, int icmp_nhmtu=-1, **kwargs
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


cdef class WartsReader(Reader):
    def __init__(self, str filename):
        self.filename = filename
        self.p = None

    def __iter__(self):
        cdef str line
        cdef dict j
        for line in self.p.stdout:
            j = json.loads(line)
            if j['type'] == 'trace':
                yield WartsTrace(**j)

    cpdef void open(self) except *:
        cdef str cmd
        if self.filename.endswith('.bz2') or self.filename.endswith('.bzip2'):
            cmd = 'lbzip2 -d -c {} | sc_warts2json'
        elif self.filename.endswith('.gz'):
            cmd = 'pigz -d -c {} | sc_warts2json'
        else:
            cmd = 'sc_warts2json {}'
        self.p = Popen(cmd.format(self.filename), stdout=PIPE, shell=True, universal_newlines=True)

    cpdef void close(self) except *:
        self.p.stdout.close()
        self.p.wait()
        self.p = None
