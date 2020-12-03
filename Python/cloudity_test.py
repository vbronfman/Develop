# you can write to stdout for debugging purposes, e.g.
# print("this is a debug message")
#@ Cloudity test: find min number not presented .

def solution(A):
    # write your code in Python 3.
    A.sort()
    min=1
    
    if A[-1] < 0:
        return 1
        
    for i,value in enumerate(A):
        if A[i] < 0 :
            continue
        
        if A[i]>=min and ( i != len(A)-1 and A[i+1] != A[i]+1):
            min = A[i]+1
        
    
    if min==1:
        return A[-1]+1
        
    return min
    
    
solution ([1, 3, 6, 4, 1, 2])