/ This file is part of Game of Life with Enterprise Components demo application.
/ Copyright (C) 2014  Slawomir Kolodynski. 
/ Licensed under the Apache License, Version 2.0 (the "License");
/ you may not use this file except in compliance with the License.
/ You may obtain a copy of the License at
/ http://www.apache.org/licenses/LICENSE-2.0


system"l ",getenv[`EC_QSL_PATH],"/sl.q";

.sl.init[`cell];
.sl.lib["cfgRdr/cfgRdr"];

.sl.main:{
  .log.info[`cell] "Starting the Game of Life with Enterprise Components Demo Application";
  gridi:.cr.getCfgField[`THIS;`group;`cfg.gridi];
  gridj:.cr.getCfgField[`THIS;`group;`cfg.gridj];
  .cell.maxGenerations:.cr.getCfgField[`THIS;`group;`cfg.generations];
  instance:value .cr.getCfgField[`THIS;`group;`EC_COMPONENT_INSTANCE];
  .cell.i:floor instance%gridj;
  .cell.j:instance mod gridj;
  / get names of neigbors
  .cell.neighbors:.cell.getNeighbors[gridi;gridj;.cell.i;.cell.j];
  .log.info[`cell] "coordinates " .Q.s1 (.cell.i;.cell.j);
  .log.info[`cell] "neighbors " .Q.s1 .cell.neighbors;
  .cell.initState:.cell.state:.cell.getInitState[.cell.i;.cell.j];
  .log.info[`cell] "initial state: ",.Q.s1 .cell.initState;
  / init some counters
  .cell.updCount:()!(); / time step keyed dictionary of number of neighbor updates 
  .cell.nactive:()!();  / time step keyed dictionary of active neighbors
  / init game rules
  .cell.rules:()!();
  .cell.rules[0b]:00010000b;
  .cell.rules[1b]:00110000b;
  / add a callback to run when conection to the admin is open
  .hnd.poAdd[`life.admin;`.cell.onAdminConnection];
  / open connection to the admin with timeout set to 500ms
  .hnd.hopen[`life.admin;500i;`eager];
  };
  
/ figures out the neibors' names from the grid dimensions and cell coordinates
.cell.getNeighbors:{[gi;gj;ci;cj]
  {[gi;gj;n]`$"grid.cell_",string (n[1]mod gj)+gj*n[0]mod gi}[gi;gj]each(ci;cj)+/:((-1;0;1)cross(-1;0;1))except enlist(0 0)
  };

/ generates a random initial cell state. The arguments are ignored here.
.cell.getInitState:{[ci;cj] system "S ",string `int$.z.t;:0~rand 3};

//.cell.getInitState:{[ci;cj] (ci in 1 2) and cj in 0 1};
  
/ function that runs on successful admin connection
.cell.onAdminConnection:{[admin]
  .log.info[`cell] "successful admin connection";
  .hnd.ah[`life.admin](`.admin.cellUp;.cell.i;.cell.j);
  / tell the admin the timestep, cooordinates and initial state
  .hnd.ah[`life.admin](`.admin.upd;0;.cell.i;.cell.j;.cell.initState);
  / set up the callbacks and open the connections to neighbors
  .hnd.poAdd[;`.cell.onCellConnection] each .cell.neighbors;
  .log.info[`cell] "opening connections to neighbors";
  .hnd.hopen[.cell.neighbors;10i;`eager];
  };
  
/ function that runs on successful neighbor connection
.cell.onCellConnection:{[neighbor]
  .cell.connected+:1;
  .log.info[`cell] "successful neighbor connection to ",(.Q.s1 neighbor)," total ",.Q.s1 .cell.connected;
  if[(.cell.connected~8);
    /notify admin that the cell is ready
    .hnd.ah[`life.admin](`.admin.cellReady;.cell.i;.cell.j);
    ];  
  };

/ function called by the admin when all cells are ready
.cell.start:{[x]
  .log.info[`cell] "signal from admin to start";
  (.hnd.ah each .cell.neighbors) @\: (`.cell.upd;.cell.i;.cell.j;0;.cell.initState);
  };

/ neighbors call this function to notify about their current state
.cell.upd:{[ci;cj;t;state]
  if[not t in key .cell.updCount;
    .cell.updCount[t]:1;
    .cell.nactive[t]:`long$state;
    :();
    ];
  .cell.updCount[t]+:1;
  .cell.nactive[t]+:state;
  if[.cell.updCount[t]~8; / we know the state of all neighbors for this time step
    .cell.state:.cell.rules[.cell.state;.cell.nactive[t]];
    / notify admin
    .hnd.ah[`life.admin](`.admin.upd;t+1;.cell.i;.cell.j;.cell.state);
    / clean up
    .cell.updCount _:t;
    .cell.nactive _:t;
    if[t>.cell.maxGenerations;:()];
    / tell the neighbors our new state 
    (.hnd.ah each .cell.neighbors) @\: (`.cell.upd;.cell.i;.cell.j;t+1;.cell.state);
    ];
  };

.sl.run[`cell; `.sl.main;`];
