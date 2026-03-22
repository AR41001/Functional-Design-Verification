**Functional Design Verification**

- A portfolio of different systemverilog techniques used in desgin verification for better and modular testing.
- These projects are done on **Questa Sim-64 10.7c** and **Cadence Xcelium**

**interface_with_modports**
  -  The given design was a small memory module which needed testing
  -  An interface was made with all the signals for better and modular usage
  -  Among the signals some tasks i.e. read and write were created which were eventually imported
  -  This interface was then called inside the testbench further

**randomization_fork_events**
  -  This is a continuation of the above mentioned module with the memory
  -  The memory is changed to 4kB and then 2 such memories are made i.e Instruction Memory and Data Memory
  -  Both are working with different clocks and that is where the advantage of modular and interface based approach was advantageous
  -  Testing was done using randomization and different constraints such as the dist, inside etc
  -  FORK was learnt and applied to test different behavior as to which fork can give better simulation time
