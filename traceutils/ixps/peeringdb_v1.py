import sqlite3

from traceutils.ixps.peeringdb_base import AbstractIX, AbstractPeeringDB


class IX(AbstractIX):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

class PeeringDB(AbstractPeeringDB):
    def __init__(self, filename):
        super().__init__(filename)
        con = sqlite3.connect(self.filename)
        con.row_factory = sqlite3.Row
        cur = con.cursor()
        result = cur.execute('SELECT * FROM mgmtPublics')
        self.ixs = {row['id']: IX(**row) for row in result}
        result = cur.execute('select * from mgmtPublicsIPs')
        self.prefixes = {row['address']: row['public_id'] for row in result}
        result = cur.execute(
            'select asn, local_ipaddr from peerParticipants p join peerParticipantsPublics pp on (p.id = pp.participant_id)')
        self.addrs = {row['local_ipaddr']: row['asn'] for row in result}
