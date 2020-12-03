import os

with open("file.dat", 'w') as f:
    f.write('hello world !') 


def print_chess (hight,wight):

  #if_null= lambda 1 if a % 2 else 0
  
  for i in range (hight):
    if i%2:
      print ( [0 if j%2 else 1 for j in range(wight)])
    else:
      print ( [1 if j%2 else 0 for j in range(wight)])
    

  print (end='\n')

print ("Hello")
print_chess(10,10)

#print sum(x*(5+x) for x in xrange(10,20))

 

 




