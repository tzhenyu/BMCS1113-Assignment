System Functionalities/Modules

Module 1: Log In
Handles user authentication. Supports multiple user IDs with different names and membership status. Prompts for username and password, validates credentials, and displays personalized greeting.

Module 2: Main Menu
Displays the main menu after login. Shows available flight options in an ASCII-style table, allows user to select a flight, view booking history, or log out.

Module 3: Book A Flight
Allows the user to select a flight from the menu. Loads flight details including airline, origin, destination, departure date, trip type, and price.

Module 4: Select Ticket Type
Prompts user to choose travel class (Economy or Business) and optionally add insurance. 
- Economy: base price.
- Business: base price × 1.4.
- Insurance: +RM100 if selected.

Module 5: Passenger Information
Captures number of passengers (1-5) and collects each passenger's name and passport number with validation.

Module 6: Booking Summary and Discount Calculation
Displays booking summary including passenger details, membership status, and price breakdown.
- Total per passenger = class price + insurance.
- Grand total = total per passenger × number of passengers.
- If member: discount = 15% of grand total.
- Final price formula:  
  `Final Price = (class price + insurance) × passengers × (1 - 0.15 if member)`

Module 7: Payment
Handles payment processing. Supports Credit Card and E-wallet payments. Validates payment amount, calculates change (`change = payment - final price`), and confirms booking.

Module 8: Ticket Printing
Prompts user to print a formatted ticket with all booking details after successful payment.

Module 9: Booking History
Allows user to view previous bookings including flight, total price, and passenger count.

Module 10: Book Another Flight
After payment, prompts user to book another flight or exit the system. Supports multiple bookings in a single session.
