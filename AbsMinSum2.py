# From Lesson 17 - Dynamic Programming of the Codility Lessons Page

# To solve this, we can use the Tabulation method
from math import floor

# for this problem, we can't use the 'sum' function, otherwise we will create an
# empty table if the average is negative. So, we have to loop through each element
# in the 'A' array and sum the absolute value of each
# We also want to create a hashmap containing the count of the absolute values in 'A'

def solution(A):
    sumA = 0
    countOfNums = {}
    for num in A:
        absNum = abs(num)
        sumA += absNum
        countOfNums[absNum] = countOfNums.get(absNum,0) + 1
      
    # Now generate the table
    centre = int(floor(sumA/2))
    table = [-1] * (centre+1)
    table[0] = 0
        
    for key in countOfNums:
        table[0] = countOfNums[key]
        for i in range(len(table)):
            if table[i] >= 0:
                table[i] = countOfNums[key] # set the value to be equal to the count of the number we are focusing on
            else:
                if i-key >= 0: # check we don't go out of bounds when backtracking
                    table[i] = table[i-key] - 1
                            
    # now we have to backtrack through the updated table, and find the first occurence when the value in the table is greater than or equal to zero
    # when we do, we perform the calculation: minDiff = sum - (2*index)
            
    for i in range(len(table)-1, -1, -1):
        if table[i] >= 0:
            return sumA - (2*i)
        
