# MPM-Pacific-Linear-model-w-Google-API
Terms: 
MPM - Man Power Model, the name given to this report
Pacific - the name of one of six regions within the united states. 
Project Manager - John Cooper

Problem: 
The equipment managed was highly sensitive and required regular maintenance and repairs. Each piece of equipment was permanently assigned to a repairman which was loosley based on proximaty, all maintenance and repairs where expected to be completed by one repairman. as repair men came and went over the years, the distribution became inefficient and repairmen had ownership of equipment that was much closer in proximity to other repair men. As a result, we needed a way to assign between 80 and 140 pieces of equipment to each repairman while being sure that each repairman was assigned to the closest pieces of machinery possible. 

Solution: 
It quickly became apparent that this was a linear optimization problem. The previous solution was to create a linear optimization model that worked as the crow flies. This provided significant savings, but also suggested some inefficient assignments. In order to maximize the efficiency of this model I the developed a way to use a google maps API and measure the distance between equipment and repairmen by googles estimated driving time. in an effort to minimize the number of calculations we stripped the addresses down to just the zip code which produced results that where 98% the same as using the full address but required far less time and money to calculate. These new measurements where then used to create a new distribution that where almost perfectly optimized. Each repair men were assigned between 80 and 140 pieces of equipment and each piece of equipment was the closest piece of equipment to that repairmen according to Google's estimated driving time. The output was a CSV file that we could then load into Tableau and visualize each of the repairmen’s regions represented by colored dots on a map. 

Outcome: 
This solution was implemented into production. The model took several hours to run, but produced fantastic results. After one quarter, we were able to validate that the number of logged driving hours by the repairmen had dropped by 15% y/y as expected, which validated our estimated department saving ins of $1,500,000 annually (for all six regions combined). Because I was the only person in my department who knew how to code, the company hired an outside consulting group to manage this report. I worked closely with the consulting group to help them implement my scripts and mimic my report exactly.
