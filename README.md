# MPM-Pacific-Linear-model-w-Google-API

## The data that was used for this project was confidential and is not included in this repo. 

* MPM - Man Power Model, the name given to this report
* Pacific - the name of one of six regions within the united states. 
* Cost Savings - $1.5M Annually 

## Problem: 
The equipment managed was highly sensitive and required regular maintenance and repairs. Each piece of equipment was strictly assigned to one repairman which was loosley based on proximaty, all maintenance and repairs where expected to be completed by one repairman who also managed the relationship with the customer. as repair men came and went over the years, the distribution became inefficient and repairmen had ownership of equipment that was much closer in proximity to other repair men. As a result, we needed a way to assign between 50 and 110 pieces of equipment to each repairman while being sure that each repairman was assigned to the closest pieces of machinery possible given the constraint above. Within the company it was well documented that the repairmen spent about 30% of their time driving from one job to another. This cost the company just under $10,000,000 Annually for about 90 repairmen to manage approximatly 20,000 peices of equipment across 6 US Regions.

## Solution: 
Because of my background and training, it quickly became apparent that this was a linear optimization problem. The first solution that I developed was to create a linear optimization model that worked as the crow flies. This provided significant savings, but also suggested some inefficient assignments due to bodies of water, mountain ranges ext. But it was very simple and easy to run. In order to maximize the efficiency of this model I developed a way to use google map's API and measure the distance between equipment and repairmen by googles estimated driving time. Each of the 6 US regions where ran through google and the LM seperatly due to the vast amount of computing power both of these task require. 

## Outcome: 
The output was a csv file that had the client name and location of every peice of equipment we managed (aproximatly 20000) along with the closest repairmen to that equipment, their location and the estimated driving time from their home or office to the clients location. The model took several hours to run, but produced fantastic results. After one quarter, we were able to validate that the number of logged driving hours by the repairmen had dropped by 15% y/y as expected, which validated our estimated department saving of $1,500,000 annually (for all six regions combined). Because I was the only person in my department who knew how to code, the company hired an outside consulting group to manage this report. I worked closely with the consulting group to help them implement my scripts and mimic my report. 
