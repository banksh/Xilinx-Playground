# SHA256 with AXI interface

## Description

This project demonstrates hardware accelerated sha256 hashing on a PYNQ board. The actual sha256 computation is fully combinational (doesn't require a clock input) and doesn't use any intermediate buffers, so it requires huge chip area but runs quite quickly. Unfortunately the bandwidth is very much gated by how quickly data can be moved into and out of the module.

## Usage

A bitstream file [sha256_axi_test.bit](sha256_axi_test.bit) is included and can be flashed onto the board. Make sure you keep the `sha256_axi_test.bit` and `sha256_axi_test.hwh` files in the same directory on the PYNQ. An example python driver [sha256.py](sha256.py) shows how to interface with the module.

### Using python:
```python
import sha256
message = "test"
padded_message = sha256.pad(message)
decoder = sha256.Decoder()
hash = decoder.get_hash(padded_message)
print(sha256.prettify(hash))
```

### Using command line:
```
$ sudo ./sha256.py test
9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
$ echo -n test | sha256sum
9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08  -
```

The command line interface for [sha256.py](sha256.py) is quite slow because it reloads the full bitstream onto the PYNQ each time it's run.

### General notes

Hashes of more than 1 chunk (55 message bytes) are not supported by the python driver, but the hardware module is able to hash repeated chunks.

A simulation file [testbench_sha256.v](testbench_sha256.v) is included. Try it out with `iverilog -o main sha256.v testbench_sha256.v; ./main`.

Here's the block diagram for the project:
![diagram](block_diagram.png?raw=true)

If you implement it yourself, make sure that the custom module is mapped into memory at `0x43C0_0000` (or change the python driver to match your address offset).

## Future

The project currently uses a (slow) AXI4-LITE interface between the PL and the PS. Eventually it should be upgraded to a faster AXI4-FULL interface.

It's hard to realize any speed/efficiency improvements with this hardware accelerated module as long as it's being fed data with a slow python driver. I'd like to swap that out with a faster memory-mapped c interface (first user-space, eventually kernel driver).

The reset behavior of the module is quite weird (it only responds to `reset` on a rising `start` edge). This is due to the fact that Verilog fails at the implementation step when adding a subscription to `negedge reset`. I'm not sure why.
