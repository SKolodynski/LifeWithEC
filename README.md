Conway'a Game of Life with KDB+ and Enterprise Components
=========================================================

1. Download KDB+, yak and DEVnet's Enterprise Components:

```bash
  $ wget http://www.devnet.de/fileadmin/downloads/ec_v3.0.0_DemoSystem_Linux32bit_Lessons_1-3.tgz
  $ tar -xvf ec_v3.0.0_DemoSystem_Linux32bit_Lessons_1-3.tgz
```

2. Set up directory structure expected by the configuration in any empty directory

```bash
  $ mkdir bin
  $ ln -s ../DemoSystem/bin/ec/ bin/ec
  $ ln -s ../DemoSystem/bin/q/  bin/q
  $ ln -s ../DemoSystem/bin/yak/  bin/yak
  $ ln -s <path to the LifeWithEC distribution> bin/life
  $ ln -s <path to the LifeWithEC distribution>/etc/ etc
  Note the last command has to be done from the same directory where the bin directory was created above.
```

3. Source the environment

```bash
  $ source etc/env.sh
```

4. Check if yak is working

```bash
  yak info life
```
  Yak distributed with ec_v3.0.0_DemoSystem_Linux32bit_Lessons_1-3.tgz is a 32bit application. If you are running a 64-bit system you may have to install some compatibility libraries.


5. Start the admin process

```
  $ yak start life
  Starting components...                                                                                                                                                                                                                 
        life.admin                      OK    
```

6. Start the grid cells	

```bash
  $ yak start grid
  Starting components...                                                                                                                                                                                                                 
        grid.cell_0                     OK                                                                              
        grid.cell_1                     OK                                     
        grid.cell_2                     OK                                                         
  ...
        grid.cell_96                    OK
        grid.cell_97                    OK
        grid.cell_98                    OK
        grid.cell_99                    OK
```

7. check the status of the grid processes

```bash
  $ yak info grid
  uid                pid   port   status      started             stopped            
  -----------------------------------------------------------------------------------
  grid.cell_0        2600  17000  RUNNING     2014.05.27 14:02:49                    
  grid.cell_1        2606  17001  RUNNING     2014.05.27 14:02:49                    
  grid.cell_10       2652  17010  RUNNING     2014.05.27 14:02:51
  ...
  grid.cell_98       3431  17098  RUNNING     2014.05.27 14:04:11                    
  grid.cell_99       3434  17099  RUNNING     2014.05.27 14:04:11
```

8. Check the port the life.admin process is listening at

```bash
  $ yak info life
  uid                pid   port   status      started             stopped            
  -----------------------------------------------------------------------------------
  life.admin         2579  17100  RUNNING     2014.05.27 14:01:56

```

You can connect to the life.admin component with KDBstudio or a similar application to have a look at the result of the simulation.

All processes can be stopped with
  
```bash
  $ yak stop \*
```

