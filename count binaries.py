import re
#count binaries

N=12324234223
search_str='1'
binary_string = str(bin(N))[2:] #cut off '0b' of binary representation
print (binary_string)
#matches = re.findall(r'(?:\b%s\b\s?)+' % search_str, polymer_str) #https://stackoverflow.com/a/1155805/2961448
matches = re.findall(r'%s+' % search_str,binary_string)
print (matches)
longest_match = max(matches)

print (longest_match)
#for i in binary_string:


