<<<<<<< HEAD
def func():
    print ("I'm inside")
    print ("ident added" )   

#list
a=[4,10000,'a',3,"dd",2,'2',4]
b = a.sort()
print (a.sort())
b=a

ind=a.index("dd")
if ind !=0 :
    print (a.pop(ind))
    
if "dd" in a:
    print ("In list")
    

#from PIL import Image, ImageTk
from Tkinter import Tk, Label, BOTH
from ttk import Frame, Style

class Example(Frame):
  
    def __init__(self, parent):
        Frame.__init__(self, parent)   
         
        self.parent = parent
        
        self.initUI()
        
    def initUI(self):
      
        self.parent.title("Absolute positioning")
        self.pack(fill=BOTH, expand=1)
        
        Style().configure("TFrame", background="#333")
        
        #bard = Image.open("bardejov.jpg")
        #bardejov = ImageTk.PhotoImage(bard)
        #label1 = Label(self, image=bardejov)
        #label1.image = bardejov
        #label1.place(x=20, y=20)
        #
        #rot = Image.open("rotunda.jpg")
        #rotunda = ImageTk.PhotoImage(rot)
        #label2 = Label(self, image=rotunda)
        #label2.image = rotunda
        #label2.place(x=40, y=160)        
        #
        #minc = Image.open("mincol.jpg")
        #mincol = ImageTk.PhotoImage(minc)
        #label3 = Label(self, image=mincol)
        #label3.image = mincol
        #label3.place(x=170, y=50)        
              

def main():
  
    root = Tk()
    root.geometry("300x280+300+300")
    app = Example(root)
    root.mainloop()  


if __name__ == '__main__':
    main()  








=======
def func():
    print "I'm inside"
    print "ident added"    

#list
a=[4,10000,'a',3,"dd",2,'2',4]
b = a.sort()
print a.sort()
b=a

ind=a.index("dd")
if ind !=0 :
    print a.pop(ind)
    
if "dd" in a:
    print "In list"
    

#from PIL import Image, ImageTk
from Tkinter import Tk, Label, BOTH
from ttk import Frame, Style

class Example(Frame):
  
    def __init__(self, parent):
        Frame.__init__(self, parent)   
         
        self.parent = parent
        
        self.initUI()
        
    def initUI(self):
      
        self.parent.title("Absolute positioning")
        self.pack(fill=BOTH, expand=1)
        
        Style().configure("TFrame", background="#333")
        
        #bard = Image.open("bardejov.jpg")
        #bardejov = ImageTk.PhotoImage(bard)
        #label1 = Label(self, image=bardejov)
        #label1.image = bardejov
        #label1.place(x=20, y=20)
        #
        #rot = Image.open("rotunda.jpg")
        #rotunda = ImageTk.PhotoImage(rot)
        #label2 = Label(self, image=rotunda)
        #label2.image = rotunda
        #label2.place(x=40, y=160)        
        #
        #minc = Image.open("mincol.jpg")
        #mincol = ImageTk.PhotoImage(minc)
        #label3 = Label(self, image=mincol)
        #label3.image = mincol
        #label3.place(x=170, y=50)        
              

def main():
  
    root = Tk()
    root.geometry("300x280+300+300")
    app = Example(root)
    root.mainloop()  


if __name__ == '__main__':
    main()  








>>>>>>> e55f97114d0da06a25cf60393f67b0e16521bd92
