#!/usr/bin/env python3

from pynq import Overlay, MMIO
import numpy as np
import copy
import struct

def pad(msg):
    if type(msg) == str:
        msg = bytes(msg, 'utf8')
    msg_len = len(msg)
    msg += b'\x80'
    while len(msg) < 60:
        msg += b'\x00'
    msg += struct.pack('>I', msg_len * 8)
    return msg

def prettify(hash_result):
    fmt = lambda n: "{:0x}".format(n)
    return np.array2string(hash_result,
            formatter={"all": fmt},
            separator='',
            max_line_width=256)[1:-1]

class Decoder():
    START_REG = 24
    RESET_REG = 25
    INPUT_START = 0
    INPUT_END = 15
    OUTPUT_START = 16
    OUTPUT_END = 23

    def __init__(self):
        self.overlay = Overlay("sha256_axi_test.bit")
        self.mem_map = MMIO(0x43C00000, 4*26)
        self.mem_map.array[self.RESET_REG] = 1

    def _start(self):
        self.mem_map.array[self.START_REG] = 0
        self.mem_map.array[self.START_REG] = 1

    def _reset(self):
        self.mem_map.array[self.RESET_REG] = 0
        self.mem_map.array[self.START_REG] = 0
        self.mem_map.array[self.START_REG] = 1
        self.mem_map.array[self.RESET_REG] = 1

    def _get_result(self):
        return self.mem_map.array[self.OUTPUT_START:self.OUTPUT_END+1]

    def get_hash(self, padded_msg):
        self._reset()
        buf = np.frombuffer(padded_msg, np.dtype('>u4'), len(padded_msg)>>2, 0)
        for i,v in enumerate(buf):
            self.mem_map.array[self.INPUT_START + i] = v
        self._start()
        result = self._get_result()
        return copy.deepcopy(result)

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("msg", help="Message to hash (maximum 55 characters)")
    args = parser.parse_args()
    decoder = Decoder()
    hashed_message = decoder.get_hash(pad(args.msg))
    print(prettify(hashed_message))
