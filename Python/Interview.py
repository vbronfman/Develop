# Python interview

arr1=[2,4,5,7,9,11,12,15,17]
arr2=[1,2,4,6]

################################
# merge two sorted arrays

def sortedArrayMerge(arr1,arr2):
    
    res=[]

    while (arr1 and arr2):
        if (arr1[0] < arr2[0]):
            if res and arr1[0] == res[-1]:
                arr1.pop(0)
                continue
            res.append(arr1.pop(0))
        else:
            if res and arr2[0] == res[-1]:
                arr2.pop(0)
            res.append(arr2.pop(0))
            
    
    if (arr1 > arr2):
        res.extend(arr1)
    else:
        res.extend(arr2)
    
    print (res        )
    
sortedArrayMerge(arr1,arr2)
pass


#Matrix: look for the zero-nodes and then replace by 0 the  values in same column and row
Matrix=[
[2,3,5,1,6],
[0,3,5,1,6],
[2,3,5,1,0],
]

def printMatrix(*args):
    for i in args:
        print (i)

    
def cross_zero(a,b,Matrix):
    pass
    for i in range(len(Matrix)):
        for j in range(len(Matrix[i])):
            #if i==node[0] or j==node[1]:
            if i==a or j==b:
                Matrix[i][j]=0
                
    
found=[]

for i in range(len(Matrix)):
    if any (i in node for node in found):
        Matrix[i][j]=0
    for j in range(len(Matrix[i])):
        #print (Matrix[i][j])
        if Matrix[i][j]==0:
            found.append((i,j))
        elif  any (i in node for node in found) or any (j in node for node in found): #if any('apple' in code for code in CODES):
            Matrix[i][j]=0
        

for a in [ b in  cross_zero(i,j,Matrix) for i,j in found]:
    print (a)

    
printMatrix(*Matrix)

