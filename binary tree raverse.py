# binary tree raverse

class Node :
    def __init__(self,data):
        self.data=data
        self.left=None
        self.right=None    

def findMax (root): #recursively descent down tree
    if root == None:
        return float('-inf')
    #try:
    max=root.data
    
    rmax=findMax(root.right)
    lmax=findMax(root.left)
   
    if (max < rmax):
        max=rmax
    
    if max < lmax:
        max=lmax
    
    
    return max
    #except:
        #pass

#raise ValueError("Requested file not found") # not found here or in children

if __name__ == "__main__":
	root = Node(2) 
	root.left	 = Node(7) 
	root.right	 = Node(5) 
	root.left.right = Node(6) 
	root.left.right.left=Node(1) 
	root.left.right.right=Node(11) 
	root.right.right=Node(9) 
	root.right.right.left=Node(4) 

	print("Maximum element is", findMax(root)) 
