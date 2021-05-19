# Simple script to fix file format of a few traces
for i in range(0, 5):
    addresses = []
    branchresults = []
    with open("traces-old/trace" + str(i)) as file:
        trace = file.readlines()
    for line in trace:
        chunks = line.split(" ")
        addresses.append(chunks[0] + "\n")
        branchresults.append(chunks[1])
    with open("traces/address" + str(i + 8), "w") as file:
        file.writelines(addresses)
    with open("traces/branchresult" + str(i + 8), "w") as file:
        file.writelines(branchresults)
    