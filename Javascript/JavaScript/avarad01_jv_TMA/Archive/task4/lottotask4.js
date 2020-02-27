
//Task 4. Loops
//author: Andreina Varady
//date: June,1,2018

//create variable for customer number
var customerNumber = 12;

//create variable for winning number
var winningNumber = [];
	winningNumber.push(12, 17, 24, 37, 38, 43);

//create sample message
var message = "This Week's Winning Numbers are: " + winningNumber + "\n" + "The Customer Number is " + customerNumber;

var match = false
var i = 0


//Loop to find if customerNumber matches with a number in the winningNumber array
for (i = 0; i < winningNumber.length && !match; i++) {

	//if customerNumber is within the winningNumber range, match = TRUE
	if (customerNumber == winningNumber[i]) {
			match = true
		}
}

//print message based on output from match variable.
//if match = true, output message 1 ocurrs, else message 2 occurs

if (match == true) {

			//message 1
			alert (message + "\n" + "We have a match and a winner!")

		} else {

			//message 2
			alert (message + "\n" + "Sorry, you are not a winner this week")
		}
