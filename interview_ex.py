import sys


class Things:
     def __init__(self,n,t):
          self.namething = n
          self.total = t
 


def stringoverturn(name):
    array=list(name)
    length=len(array)
    pivotid=int(length/2)
    i=0
     
    while i != pivotid:
        tmp=name[i]
        array[i]=array[length-1-i]
        array[length-1-i]=tmp
        i+=1
    print(''.join(array))
    
    
def convert(name):
        import re
        return re.sub('(.)([A-Z]+)', r'\1 \2', name)

def main(argv):
    
    
    th1 = Things("table", 5)
    th2 = Things("computer", 7)
    print (locals() )
    print (th1.namething,th1.total) #  : table 5
    print (th2.namething,th2.total) #  : computer 7
     
    th1.color = "green" #   th1
    th2.coc=1
     
    print (th1.color) #  : green
    print (th2.coc) #  :     th2     color!

def mysort(myarr):
    
    for i in range(len(myarr)):
        tmp=myarr[i]
        j=i
        while j > 0 and myarr[j]<myarr[j-1]:
           myarr[j]=myarr[j-1]
           myarr[j-1]=tmp
           j-=1
        
        
        
    stringoverturn("Cat Dog Fish Sun")
    
    print (convert("CatDogFishSun"))
    print ("Hello world")
    myarr=[4,2,0,9]
    mythat={3,2}
    mysort(myarr)
    print (myarr)
   
if __name__ == '__main__':
    main(sys.argv)
