/ This file is part of Game of Life with Enterprise Components demo application.
/ Copyright (C) 2014  Slawomir Kolodynski. 
/ Licensed under the Apache License, Version 2.0 (the "License");
/ you may not use this file except in compliance with the License.
/ You may obtain a copy of the License at
/ http://www.apache.org/licenses/LICENSE-2.0

system"l ",getenv[`EC_QSL_PATH],"/sl.q";

.sl.init[`admin];
.sl.lib["cfgRdr/cfgRdr"];

/ dictionary keyed by timestamp for storing current grid state
.admin.states:()!();

/ dictionary keyed by timestamp counting cell state updates
.admin.updCount:()!();

/ table that collects the results of the simulation
.admin.frames:([] t:`long$();ts:`timestamp$();frame:());

/ stores information on when cells become ready i.e. connections to all neighbors are up
.admin.cellsReady:([] ts:`timestamp$();ci:`long$();cj:`long$();server:`$());

/ main initialization code
.sl.main:{
  .log.info[`admin] "starting grid admin";
  .admin.gridi:.cr.getCfgField[`THIS;`group;`cfg.gridi];
  .admin.gridj:.cr.getCfgField[`THIS;`group;`cfg.gridj];
  .admin.gridCount:.admin.gridi*.admin.gridj;
  .admin.gridUp:(.admin.gridi;.admin.gridj)#0b;
  .admin.gridReady:(.admin.gridi;.admin.gridj)#0b;
  };

/ function called by grid cells to notify about the new state
.admin.upd:{[t;ci;cj;state]
  .log.info[`admin] "update:", .Q.s1 (t;ci;cj;state);
  // `.admin.updates insert (t;ci;cj;state);  
  if[not t in key .admin.states;
    .admin.states[t]:(.admin.gridi;.admin.gridj)#0b;
    .admin.updCount[t]:0;
    ];
  .admin.updCount[t]+:1;
  .admin.states[t;ci;cj]:state;
  if[.admin.updCount[t]~.admin.gridCount;
    //.log.info[`admin] "step ",(string t)," completed";
    `.admin.frames insert (t;.z.p;.admin.states t);
    if[.admin.wsh<0;.admin.wsh .admin.bToString .admin.states t];
    .admin.states _:t;
    .admin.updCount _:t;
    ];
  :t;
  };
    
/ records information when a cell connects to admin 
.admin.cellsUp:([] ts:`timestamp$();ci:`long$();cj:`long$();server:`$());
.admin.cellUp:{[ci;cj]
    .admin.gridUp[ci;cj]:1b;
    / send up state info to GUI
    if[.admin.wsh<0;.admin.wsh .admin.bToString .admin.gridUp];
    server:`$"grid.cell_",string cj+ci*.admin.gridj;
    `.admin.cellsUp insert (.z.p;ci;cj;server);
    };
  
/ function called by a grid cell to notify that all its connections are up
.admin.cellReady:{[ci;cj]
  .admin.gridReady[ci;cj]:1b;
  / send ready state info to GUI
  // if[.admin.wsh<0;.admin.wsh .admin.bToString .admin.gridReady];
  server:`$"grid.cell_",string cj+ci*.admin.gridj;
  `.admin.cellsReady insert (.z.p;ci;cj;server);
  .hnd.hopen[server;100i;`eager];
  if[(count .admin.cellsReady)~.admin.gridi*.admin.gridj;
    if[not all `open=1_exec state from .hnd.status;
      .log.error[`admin] "connections to some cells still not open ";
      :()
      ];
    / give cells OK to start
    (.hnd.ah each .admin.cellsReady`server) @\: (`.cell.start;0);
    ];
  };
  
/---------------------- web socket code ----------------------------

/ converts an array of bools into string for sending over web socket
.admin.bToString:{","sv {{$[x;"1";"0"]} each x} each x};
  
.admin.wsh:0;

/ overwrite z.ws
.z.ws:{
  .log.info[`admin] "web socket connection, command ",.Q.s1 x;
  .admin.wsh:neg .z.w;
  .admin.wsh .admin.bToString (.admin.gridi;.admin.gridj)#1b;
  };


/ run the script as an EC component
.sl.run[`admin; `.sl.main;`];
