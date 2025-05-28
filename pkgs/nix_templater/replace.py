# replace occurrences of a magic string in a template file
import sys
from pathlib import Path

template_file = sys.argv[1]
magic_string = sys.argv[2]
outfile = sys.argv[3]

if Path(outfile).exists():
    print(f"{outfile} already exists, aborting")
    sys.exit(1)

template_bytes = Path(template_file).read_bytes()
loc = 0
output = b""


while True:
    magic_start = template_bytes[loc:].find(f"<{magic_string}".encode())
    if magic_start == -1:
        output += template_bytes[loc:]
        break
    magic_end = template_bytes[loc + magic_start :].find(f"{magic_string}>".encode())
    magic_file = template_bytes[
        (loc + magic_start + len(magic_string) + 1) : loc + magic_start + magic_end
    ]
    output += template_bytes[loc : loc + magic_start]
    # TODO handle errors better here
    output += Path(magic_file.decode()).read_bytes()
    loc = loc + magic_start + magic_end + len(magic_string) + 1

Path(outfile).write_bytes(output)
