import pyotherside
import sys
import os
import time

here = os.path.abspath(os.path.dirname(__file__))

vendored = os.path.join(here, '..', 'vendored')
sys.path.insert(0, vendored)

import transmission_rpc

c = transmission_rpc.Client(protocol='https', host='transmission.test.dev', port=443)

ONE_TB = 2 ** 40
ONE_GB = 2 ** 30
ONE_MB = 2 ** 20

def list_torrents(name=None, status=None):
    ti = time.time()
    torrents = {}
    keys = ['id', 'name', 'status', 'leftUntilDone', 'progress', 'sizeWhenDone', 'isFinished', 'isStalled', 'ratio', 'uploadRatio']
    # leftUntilDone & sizeWhenDone are data dependencies for `progress`
    all_torrents = c.get_torrents(arguments=None)
    for _t in all_torrents:
        t = {k: getattr(_t, k) for k in keys}
        if t['isFinished']:
            t['status'] = 'finished'
        if name is not None and name.lower() not in _t.name.lower():
            continue
        if status is not None and t['status'] != status:
            continue
        torrents[_t.id] = t
        t['eta'] = _t.format_eta()
        t['sizeWhenDone'] = to_human_size(_t.sizeWhenDone)
    print(time.time() - ti, flush=True)
    return sorted(torrents.values(), key=lambda x: x['status'] == 'stopped')

def list_files(id):
    ret = []
    files = c.get_files(id)[id]
    for file_id, file in files.items():
        file['bname'] = os.path.basename(file['name'])
        file['finished'] = file['size'] == file['completed']
        file['id'] = file_id
        ret.append(file)
    return ret

def to_human_size(size):
    if size >= ONE_TB:
        return str(round(size / ONE_TB, 2)) + "TB"
    if size >= ONE_GB:
        return str(round(size / ONE_GB, 2)) + "GB"
    if size >= ONE_MB:
        return str(round(size / ONE_MB, 2)) + "MB"
    return str(size) + "B"

def free_space(path):
    try:
        space = to_human_size(c.free_space(path))
        return True, space
    except transmission_rpc.error.TransmissionError as e:
        return False, e.message.replace("Query failed with result ", "")

def add_torrent(path, download_dir):
    try:
        c.add_torrent('file://' + path, download_dir=download_dir)
    except transmission_rpc.error.TransmissionError as e:
        return e.message.replace("Query failed with result ", "")

def add_magnet(magnet, download_dir):
    try:
        c.add_torrent(magnet, download_dir=download_dir)
    except transmission_rpc.error.TransmissionError as e:
        return e.message.replace("Query failed with result ", "")
