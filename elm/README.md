Web browser view of LifeWithEC
==============================
 
This is elm source for the app that allows viewing the result of the LifeWithEC simulation in your web browser.
Compile the `life.elm` file with 
 
```bash
elm-make life.elm --output life.html
```
This produces the `life.html` file that one can load in a web browser after starting the `life.admin` process (but before starting the grid cells).
The app opens a web socket to the KDB+ process that runs on port 17400 (the process of the `life.admin` component) and displays the strings that come from there. The strings are parsed and displayed as squares - '0' is displayed as a white square, '1' as a black square, with ',' (comma) separating the rows of the grid. Right after the connection `life.admin` sends the "all ones" string that you can see a big black rectangle. That's how you know the connection has been successuf. When all cells in the grid are up, the admin sends "all zeroes" string, and which changes one cell at a time back to "all ones" as the cells report having succesful connection to all their neighbours. After the square turns all black (all cells are connected to neighbors) the simulation starts. In the simulation a black square shows an alive cell and a white square corresponds to a dead cell.
Last tested with EC 3.2.3 and Elm Platform 0.14.1.
