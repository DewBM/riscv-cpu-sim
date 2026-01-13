Uses little-endian encoding.

Instructions are stored in memory as a sequence of 16-bit little-endian parcels, regardless of memory system endianness.
Parcels forming one instruction are stored at increasing halfword addresses, with the lowest-addressed parcel holding the lowest-numbered bits in the instruction specification.

Byte addressable memory with a WORD beign 4 bytes(32 bits).

The memory address space is circular

-- Need to handle address misalignment in load/store operations.

* This assumes the host system is little-endian.
