<<<<<<< HEAD
# Rock-paper-scissors-lizard-Spock template


# The key idea of this program is to equate the strings
# "rock", "paper", "scissors", "lizard", "Spock" to numbers
# as follows:
#
# 0 - rock
# 1 - Spock
# 2 - paper
# 3 - lizard
# 4 - scissors

import random

# helper functions

def number_to_name(number):
    if number == 0:
      guess="rock"
    elif number == 1:
       guess="Spock"
    elif number == 2:
       guess = "paper"
    elif number ==3:
       guess= "lizard"
    elif number == 4:
       guess="scissors"
    else:
       print "Got a false expression value"
 
    return guess;
    
    # convert number to a name using if/elif/else
    # don't forget to return the result!

    
    

def name_to_number(name):
    #0 — rock
    #1 — Spock
    #2 — paper
    #3 — lizard
    #4 — scissors   
    if name == "rock":
      num=0
    elif name == "Spock":
       num=1
    elif name == "paper":
       num=2
    elif name == "lizard":
       num=3
    elif name == "scissors":
       num=4
    else:
       print "Got a false expression value"
 
    return num;


def rpsls(name):
    res=0;
    # convert name to player_number using name_to_number
    player_number=name_to_number(name);
        
    # compute random guess for comp_number using random.randrange()
    comp_number=random.randrange(0,5,1);
    
    # compute difference of player_number and comp_number modulo five
    res=player_number-comp_number
    res=res%2
    
    # use if/elif/else to determine winner
    if res==0:
        winner="Player"
    elif res==1:
        winner="Computer"
    else:
        print "something wrong happen"
        
    # convert comp_number to name using number_to_name
    comp_name=number_to_name(comp_number);
    
    # print results
    print "Player chooses ", name;
    print "Computer chooses ", comp_name; 
    print winner, " wins!\n\n";
    


# test your code
rpsls("rock")
rpsls("Spock")
rpsls("paper")
rpsls("lizard")
rpsls("scissors")

# always remember to check your completed program against the grading rubric
    

=======
# Rock-paper-scissors-lizard-Spock template


# The key idea of this program is to equate the strings
# "rock", "paper", "scissors", "lizard", "Spock" to numbers
# as follows:
#
# 0 - rock
# 1 - Spock
# 2 - paper
# 3 - lizard
# 4 - scissors

import random

# helper functions

def number_to_name(number):
    if number == 0:
      guess="rock"
    elif number == 1:
       guess="Spock"
    elif number == 2:
       guess = "paper"
    elif number ==3:
       guess= "lizard"
    elif number == 4:
       guess="scissors"
    else:
       print "Got a false expression value"
 
    return guess;
    
    # convert number to a name using if/elif/else
    # don't forget to return the result!

    
    

def name_to_number(name):
    #0 — rock
    #1 — Spock
    #2 — paper
    #3 — lizard
    #4 — scissors   
    if name == "rock":
      num=0
    elif name == "Spock":
       num=1
    elif name == "paper":
       num=2
    elif name == "lizard":
       num=3
    elif name == "scissors":
       num=4
    else:
       print "Got a false expression value"
 
    return num;


def rpsls(name):
    res=0;
    # convert name to player_number using name_to_number
    player_number=name_to_number(name);
        
    # compute random guess for comp_number using random.randrange()
    comp_number=random.randrange(0,5,1);
    
    # compute difference of player_number and comp_number modulo five
    res=player_number-comp_number
    res=res%2
    
    # use if/elif/else to determine winner
    if res==0:
        winner="Player"
    elif res==1:
        winner="Computer"
    else:
        print "something wrong happen"
        
    # convert comp_number to name using number_to_name
    comp_name=number_to_name(comp_number);
    
    # print results
    print "Player chooses ", name;
    print "Computer chooses ", comp_name; 
    print winner, " wins!\n\n";
    


# test your code
rpsls("rock")
rpsls("Spock")
rpsls("paper")
rpsls("lizard")
rpsls("scissors")

# always remember to check your completed program against the grading rubric
    

>>>>>>> e55f97114d0da06a25cf60393f67b0e16521bd92
