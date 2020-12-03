# you can write to stdout for debugging purposes, e.g.
# print("this is a debug message")
# 
# You are given a list of names of new employees in a company. You need to generate a company email address for each of them. The name of each person consists of two or three parts: a first name, an optional middle name, and a last name, separated by spaces, Each part can include only English letters (but the last name may additionally contain hyphens). The name of the company also consists only of English letters. 
# Each address must use the format "First Last@Company.com" where 
# • First is the first name, 
# • Last is the last name, 
# • company is the company name. 
# The address should be in lower case and should not contain hyphens. Additionally, if more than one person would have the same email address, differentiate their addresses by adding subsequent integers (starting from ihe second address and number 2) before the "@"" sign. For example, if there are three people who would have the address " jd@company.com", they should be assigned addresses "jd@company.com', 'jd2@company.com" and " jd3@company . con" respectively 
# Mile a function: 
# def 5olution(S, C) 
# that given a siring S containing a list of names separated by the characters ', ' (a comma followed by a space) and a string C specifying the name of the company, returns a string containing the list of email addresses separated by the characters ", '' in the same order as they were in the input. Each entry on the list should be of the form "Name <address>" 
# For example, given C "Example" and siring S as follows: 
#  "John Doe, Peter Benjamin Parker, Mary Jane Watson-Parker, John Elvis Doe, John Evan Doe, Jane Doe, Peter Brian Parker" 
# 
# the function should return: 
# "John Doe <johndoe@example.com>, Peter Benjamin Parker <peter.parker@example.com>, Mary Jane Watson-Parker <mary.watsonparker@example.com>, John Elvis Doe <john.doe2@example.com>, John Evan Doe <john.doe3@example.com>, Jane Doe <jane. doe@example.com>, Peter Brian Parker <peter.parker2@example.com>
# Assume that: 
# • N is an integer within the range 10..1,000]; 
# • M is an integer within the range [1..100]; 
# • string S consists only of letters (a-z and/or A-7)), spaces, hyphens and commas; 
# • string S contains valid names; no name appears more than once; 
# • string C consists only of letters (a-z and/or A-7)
# In your solution, focus on correctness. The perfomhance of your solution will not be the focus of the assessment


# first.last@company.com
#S='al m. aa, '

import re

def solution(S, C):
    # write your code in Python 3.6
     res=''
    
    C+='.com'
    C = C.lower()
    a_dict={}
    
    
    l = S.split(', ') #get list of full names
    #map()
    
    for person in l:
        addr=re.sub(r"(\w*).*(w*) ", r"\1.\2", person)  #fet name-last
        addr=addr.lower()
        addr=re.sub(r'(?<=[a-z])-(?=[a-z])', '',addr)
        
        if addr in a_dict:
            a_dict[addr] += 1
        else:
            a_dict[addr] = 1
        
        if a_dict[addr] > 1: # add number
            res+=person+" <"+addr+str(a_dict[addr])+"@"+C+">, "
        else:
            res+=person+" <" +addr +"@"+C+">, "
    return res[:-2]


C='Example'
S='John Doe, Peter Benjamin Parker, Mary Jane Watson-Parker, John Elvis Doe, John Evan Doe, Jane Doe, Peter Brian Parker'
print solution(S,C)