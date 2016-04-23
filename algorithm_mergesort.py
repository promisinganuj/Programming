# ----------------------------------------------------------------------------------
# References:
# List Pop function:
#    https://docs.python.org/3/tutorial/datastructures.html
# '__main__':
#    http://stackoverflow.com/questions/419163/what-does-if-name-main-do
# List slicing:
#    http://www.dotnetperls.com/slice
#    http://stackoverflow.com/questions/509211/explain-pythons-slice-notation
# ----------------------------------------------------------------------------------

# The main function to merge and sort the array recursively
def mergeSort(toSort):
# Base condition
    if len(toSort) <= 1:
        return toSort
    mIndex = len(toSort) // 2
# Recursively sorting 1st half of array
    left = mergeSort(toSort[:mIndex])
# Recursively sorting 2nd half of array
    right = mergeSort(toSort[mIndex:])

# Merging the two arrays
    result = []
# Loop until one of the array is empty
    while len(left) > 0 and len(right) > 0:
# Out of the first values in two arrays, insert the lower value in the resulting array.
# Pop with remove that elements from respective array as well.
        if left[0] > right[0]:
            result.append(right.pop(0))
        else:
            result.append(left.pop(0))

# Pick the remaining elements from the non-empty array and append them to the result
    if len(left) > 0:
        result.extend(left)
    else:
        result.extend(right)
# Return the final result as sorted array
    return result

# Defining the input array.
def init():
    global larr
    larr = [37, 7, 2, 14, 35, 47, 10, 24, 44, 17, 34, 11, 16, 48, 1, 39, 6, 33, 43, 26, 40, 4, 28, 5, 38, 41, 42, 12, 13, 21, 29, 18, 3, 19, 0, 32, 46, 27, 31, 25, 15, 36, 20, 8, 9, 49, 22, 23, 30, 45 ]
#    larr = [int(line) for line in open('IntegerArray.txt')]
#    larr = [1, 6, 7, 2, 76, 45, 23, 4, 8, 12, 11]

# For stand-alone running
if __name__ == '__main__':
    init()
    print (mergeSort(larr))
