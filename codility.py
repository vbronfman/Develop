# you can write to stdout for debugging purposes, e.g.
# print("this is a debug message")

def solution(A):
    # write your code in Python 3.6
    A.sort()
    print (A)
    
    if A[-1] < 0 :
        return 1
    
    b=[]
    for i in range(len(A)):
        #print (i)
        if A[i] < 0:
            continue
        if i+1==len(A):
            continue
    
        
        if (A[i]==A[i+1] or A[i+1] == A[i]+1) or A[i] in b:
            continue
        
        b.append(A[i]+1)
        
     
    if not b and 1 not in A:
        return 1
        
    if not b and 1 in A:
        return A[-1]+1
        
        
    print (b)
    return b[0]

print (solution ([0]))