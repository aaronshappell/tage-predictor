# Simple script to fix file format of a few traces
for i in range(8, 13):
    with open("traces/addresses" + str(i)) as file:
        addresses = file.readlines()
    for index, address in enumerate(addresses):
        if address[0] == ".":
            address = address[1:]
        addresses[index] = hex(int(address))[2:] + str("\n")
    with open("traces/addresses" + str(i), "w") as file:
        file.writelines(addresses)
    