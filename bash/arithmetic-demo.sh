#!/bin/bash
#
# this script demonstrates doing arithmetic

# Task 1: Remove the assignments of numbers to the first and second number variables. Use one or more read commands to get 3 numbers from the user.
read -p "Enter the first number: " firstnum
read -p "Enter the second number: " secondnum
read -p "Enter the third number: " thirdnum

# Task 2: Change the output to only show:
# the sum of the 3 numbers with a label
# the product of the 3 numbers with a label

sum=$((firstnum + secondnum + thirdnum))
product=$((firstnum * secondnum * thirdnum))

cat <<EOF
Sum of the three numbers is: $sum
Product of the three numbers is: $product
EOF

