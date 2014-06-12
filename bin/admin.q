/ This file is part of Game of Life with Enterprise Components demo application.
/ Copyright (C) 2014  Slawomir Kolodynski. 
/ Licensed under the Apache License, Version 2.0 (the "License");
/ you may not use this file except in compliance with the License.
/ You may obtain a copy of the License at
/ http://www.apache.org/licenses/LICENSE-2.0

system"l ",getenv[`EC_QSL_PATH],"/sl.q";

.sl.init[`admin];
.sl.lib["cfgRdr/cfgRdr"];

.sl.main:{
  .log.info[`admin] "starting grid admin";
  .admin.gridi:.cr.getCfgField[`THIS;`group;`cfg.gridi];
  .admin.gridj:.cr.getCfgField[`THIS;`group;`cfg.gridj];
  .admin.gridCount:.admin.gridi*.admin.gridj;
  };
  
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
    .log.info[`admin] "step ",(string t)," completed";
    `.admin.frames insert (t;.z.p;.admin.states t);
    if[.admin.wsh<0;.admin.wsh ","sv{{$[x;"1";"0"]} each x} each .admin.states t];
    .admin.states _:t;
    .admin.updCount _:t;
    ];
  :t;
  };
  
.admin.cellsReady:([] ts:`timestamp$();ci:`long$();cj:`long$();server:`$());
.admin.cellReady:{[ci;cj]
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
  
.admin.wsh:0;

.z.ws:{
  .log.info[`admin] "web socket connection, command ",.Q.s1 x;
  .admin.wsh:neg .z.w;
  s:","sv{{$[x;"1";"0"]} each x} each (.admin.gridi;.admin.gridj)#1b;
  .log.info[`admin] "sending ",s;
  .admin.wsh s;
  };

.admin.states:()!();
.admin.updCount:()!();

//.admin.updates:([] t:`long$();ci:`long$();cj:`long$();state:`boolean$());

/ table that collects the results of the simulation
.admin.frames:([] t:`long$();ts:`timestamp$();frame:());

.sl.run[`admin; `.sl.main;`];
