"""Assume s is a string of lower case characters.

Write a program that prints the longest substring of s in which the letters occur in alphabetical order. For example, if s = 'azcbobobegghakl', then your program should print

Longest substring in alphabetical order is: beggh
In the case of ties, print the first substring. For example, if s = 'abcbcd', then your program should print

Longest substring in alphabetical order is: abc
"""
def longestOrderedSubstring(s):
    # "result" with contain the answer
    result=''
    # Prepopulate the temp string "ordlist" with first character of the string
    ordlist=s[0:1]

    # Look throught the length of the string - 1 (to avoid index error)
    for i in range(len(s) -1):
        # For each character of the string, compare it with the next character of the string
        # If the ascii value of the next character is higher, add it the the "ordlist" (keep building the list)
        if ord(s[i]) <= ord(s[i+1]):
            ordlist=ordlist + s[i+1]
        # If the ascii value of the next character is lower, compare the length of "ordlist" created so far with the
        # length of "result" string.
    else:
        # If the new ordlist is longer, swap the result with it.
        if len(ordlist) > len(result):
            result=ordlist
        # Reset the temp "ordlist" to the next character
        ordlist=s[i+1]
    # As we skipped the last string iteration before, do a final check of the lenght of temp "ordlist" with final "result".
    # If it's bigger, swap it.
    if len(ordlist) > len(result):
        result=ordlist
        
    return(result)

if __name__ == "__main__":
    s = ['fxvwecnuzndoplffbzi',
         'xxvqruqbq',
         'lryxjhhqwscxvhk',
         'xyrnfyhgrnvzgdd',
         'qricuqbgvuxhnm',
         'kggfmlxqoyukudyxew',
         'fghrofgqxiyhjgwooe',
         'abcdefghijklmnopqrstuvwxyz',
         'zaiidjfpiho',
         'xzwyrfym',
         'zyxwvutsrqponmlkjihgfedcba',
         'tizenmmhph',
         'tdeyfvnssyklirckbkdxfwvf',
         'ywryiyhcdfffscdxol',
         'vvodscmwvwv',
         'myqmgtapttccfaydixxzamfi',
         'suatqdgejdnufsahcimp',
         'zqhgngwukhtjf',
         'fxwhjyuednveyxyeniwkiyqx',
         'zyxwvutsrqponmlkjihgfedcba']
    for items in s:
        print ('Longest substring in alphabetical order in "' + items + '" is: ' + '"' + longestOrderedSubstring(items) + '"')
