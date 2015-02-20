local AddOn, ns = ...
local E, M = ns.E, ns.M

print("Val! Current TOC number is", select(4, GetBuildInfo()))
print("oUF: LS", GetAddOnMetadata(AddOn, "Version"))
