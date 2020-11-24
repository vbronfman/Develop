#!/usr/bin/python
import re

class TestImpl:        
    def validatePasswords(self,passwords): #passwords array of 
        out = []
        password=""
        pwds=passwords.split(',')

        #regex = '^[a-z0-9]+[\._]?[a-z0-9]+[@]\w+[.]\w{2,3}$'
        #pat=re.compile(r"(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!#%*?&]{6,20}")
        #pat=re.compile(r"(?=.*[@$!%*#?&])[A-Za-z\d@$!#%*?&]{6,20}")
        reg=re.compile(r"(?=.*[@#$])[A-Za-z\d@#$]{6,12}")
        for password in pwds:
            #if re.fullmatch(r'[A-Za-z0-9@#$%^&+=]{6,12}', password):
            #if re.fullmatch(r'[A-Za-z0-9@#$]{6,12}', password):
            #if re.fullmatch(pat, password):
            if re.fullmatch(reg, password):
    # match
                print ("FOUND")
                out.append(password)
        else:
    # no match
            pass
        
        return out
    
n=TestImpl ()
print (n.validatePasswords("ABd1234@1,a F1#,2w3E*,2We3345,ABd$2341"))

