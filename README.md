# Network Formation Model for BEHAVE-SummerSchool (September 2023, Brescia) 

**Verbose Pseudo-Algo**

1. Start from an empty network with N nodes/agents (N is fixed throughout simulations)
2. Assign breeds i.e., "networkers" and "satisficers". Use the "prop-networkers" slider to determine the proportion of "networkers" in
   the population
3. Assign gender (binary variable) and seniority (integer; drawn from a Poisson distribution) to agents (currently: randomly; possible modifications: induce correlation between the two)
4. Decide T (#of iterations) and stopping condition (max #of links the network can have)
5. Do some graphics/plotting
6. End setup

7. t <- 0 (start tick counter)
8. for {t from 0 till T or stopping condition if reached before T}:
   a. pick a random agent (i.e., a random network node)
   b. consider all possibilities the agent has to change the current out-neighborhood i.e., consider what happens if the agent sends a link one by one to other agents that are not its current out-neighbors ("potential-advisors"), and consider what happens if the agent destroys a link one by one to other agents that are instead its current out-neighbors ("current-advisors")
   c. to perform these calculations, new links must be formed and existing links must be destroyed; after this evaluation phase, the added links are removed again and the destroyed links are added again (the same outer neighborhood is maintained for the time being)
   d. quantify "happiness" with resulting networks from each potential change with an objective function
   e. the objective function is a linear combination of counts of network configurations (called "network effects") that are formed by each choice, weighted by _betas_ (parameters in the GUI)
   f. add a shock to the objective function
   g. basically what happens in steps 8.b. to 8.f. is that the selected agent evaluates every possible 1-link modification of its own current out-neighborhood. To do this, these modified out-neighborhoods must first be formed and then evaluated. After evaluation, the marginal link is either destroyed or added again (re-store current neighborhood)
   h. calculate objective function of current out-neighborhood (of doing nothing, current "happiness")
   i. select the move maximizing objective function from possible 1-link modifications
   j. choose the index of the move that maximizes the objective function to find out which is the target agent of the move
   k. if utility/happiness from move max obj. funct. > from keeping current neighborhood
   l. drop tie if the target agent is among current-advisors, add tie if is among potential-advisors
10. t <- t + 1

