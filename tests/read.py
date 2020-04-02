#!/usr/bin/python3

counter = 0

inst_counter = 0
inst_bytes_bin = []
inst_bytes_hex = []

with open("bin/main.bin","rb") as f:
    data = f.read()
    for line in data:
        if counter >= 0 and counter < 600:
            inst_bytes_bin.append(format(int(line),'#010b')[2:])
            inst_bytes_hex.append(hex(line)[2:].zfill(2))
            inst_counter += 1
            if inst_counter == 4:
                inst_bytes_bin.reverse()
                inst_bytes_hex.reverse()
                print(hex(counter - 3 + 512),"\t", ''.join(inst_bytes_bin), "\t", ''.join(inst_bytes_hex))
                inst_bytes_bin.clear()
                inst_bytes_hex.clear()
                inst_counter = 0
        counter += 1
