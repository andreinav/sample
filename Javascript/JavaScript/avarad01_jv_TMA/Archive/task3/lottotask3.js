
//Task 3. Conditionals
//author: Andreina Varady
//date: June,1,2018

//create variable for customer number
var customerNumbers = 13;

//create variable for winning number
var winningNumbers = [12,17,24,37,38,43];

//create sample message
var message = "This Week's Winning Numbers are: " + winningNumbers + "\n" + "The Customer Number is " + customerNumbers;

//conditional statement
///conditional: if customer number is within winning number list
///create bolean variable "match"

//initialize variable match as false
match = false

//check customer number against each number in winning number array (6 numbers),
//if there is a match, then set match = true

if (customerNumbers == winningNumbers [0] ||
	 	customerNumbers == winningNumbers [1] ||
		customerNumbers == winningNumbers [2] ||
		customerNumbers == winningNumbers [3] ||
		customerNumbers == winningNumbers [4] ||
		customerNumbers == winningNumbers [5] ) {
			match = true }


//conditional: if bolean variable is true, then print message 1, else print message 2
if (match) {

			//message 1
			alert (message + "\n" + "We have a match and a winner!")

		} else {
			//message 2
			alert (message + "\n" + "Sorry, you are not a winner this week")
		}
