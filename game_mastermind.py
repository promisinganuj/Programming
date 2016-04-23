# This is simplified version of the famous boardgame "Mastermind" which is based on logical guessing.
# In this game, user is asked to input four numbers between 1 and 7. These numbers and the order in which they are 
# entered is then evaluated against a pre-initialized array with four number elements each between 1-7. Lets call it the base. 
# The idea is to guess this base in as few steps as possible. 
# Every time a guess is made, a result is displayed back in terms of an array. For Example: ['', 'N', 'N, 'P']
# A 'N' value means that a number is in the base but it's location is incorrect.
# A 'P' value means that a number is in the base and it's at the correct location.
# Please note that the displayed result set is randomized. For instance, in the above example, there are 3 digits which are present
# in the base but only one of them is at it's correct place. Actual tracking of the digits is part of user logic.

import random
print ("**************************************************")
print ("*** Enter 4 numbers between 1 and 7            ***")
print ("*** For quitting, enter 0 as one of the number ***")
print ("**************************************************")
# Initialize the base
a = random.sample([1, 2, 3, 4, 5, 6, 7], 4)
b = [0, 0, 0, 0]
c = ['', '', '', '']
# Variable to count total number of attempts made
no_of_tries = 0
v_quit = False

# Loop until the guess array doesn't match the base
while a != b:
    print ("Enter your guess:")
# Take user input
    b = [int(input()), int(input()), int(input()), int(input())]
# If number 0 is entered as one of the input, quite the game
    if b.count(0) > 0:
        v_quit = True
        break
# If the input is not in the valid range of 0-7, ask for the valid input
    if sorted(b)[0] >= 0 and sorted(b)[3] <= 7:
        pass
    else:
        print ('Valid input range is 1-7')
        continue
# Check for the presence and correct placement of each digit
    for i in range(4):
        if b[i] == a[i]:
            c[i] = 'P'
        elif a.count(b[i]) > 0:
            c[i] = 'N'
# Shuffle the result before displaying it to the user
    random.shuffle(c)
    print (c)
# Reset the display array
    c = ['', '', '', '']
# Increment the attempt count
    no_of_tries = no_of_tries + 1;

# Check if the user has quit or guessed the base
if bool(v_quit):
    print ("The answer is %s" % a)
    print ("You quit after %s attempts" % no_of_tries)
else:
    print ("Game finished. You took %s tries..." % no_of_tries)
