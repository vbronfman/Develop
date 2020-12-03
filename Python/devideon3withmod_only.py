# long number comprises of 1,2,3 . Allowed operations are 
# devide by 10 and get mod of 10

# by Vladimir Rotkin  9:06 PM
# BOOL IsDividedOn_3 (int Number)
# {
# if(Number == 0)
#   return TRUE
# 
# int LastDigit = Number mod 10;
# if(LastDigit== 1 || LastDigit == 2 || LastDigit == 3)
# {
# return IsDividedOn_3(Number div 10);
# }
# 
# return FALSE;
# }

def getmod (n: int):
  a=int(n)  
  if a == 0 or a == 3 :
      return 1 
  print ("a=",a)
  
  if a > 10 :
    getLastDigit = a%10 
    print ("getLastDigit = ",int(getLastDigit)," ",int(getLastDigit) )

    if int(getLastDigit) == 1 or int(getLastDigit) ==2 or int(getLastDigit)==3:
        print ("Going to call ", a, " ", int(a / 10))
        return getmod (int(a)/10)
  elif a == 1 or a == 2:
    print ("less 10 and a =", a)
    return 0


input = 123
print (getmod(input))




