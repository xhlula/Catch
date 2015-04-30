# Catch v1.0
Catch v1.0 is a simple desktop application wich allows catching parameters sent via http post request.
After receiving the request it generates unique text files holding parameters and additional information about the client.
Accepts only authorized requests based on a password known by the client.

# Usage
Start Catch.exe 
Set Target Directory and Password

Simulate http post request with a form submission
<form action="http://localhost:8889/doPost" method="POST">
  <input type="hidden" name="data" value="data to send"/>
  <input type="hidden" name="password" value="password">
  <input type="submit" value="Submit">
</form>

