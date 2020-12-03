import inspect
import subprocess

print ("Hello World!");

a=lambda x,b : x+b
print (a(2,3))


def mysort():
	a=[10,2,3,5,1,1]

	i=0
	while i < len(a):
		j=i
		while j>=0 and a[j-1] > a[j]:
			t=a[j]
			a[j]=a[j-1]
			a[j-1]=t
			j-=1
		
		i+=1		
	print (a)
mysort()