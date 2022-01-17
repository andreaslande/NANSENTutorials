## Introduction
The core idea of NANSEN is to easily structure and process your neuroscience data. Its functionality centers around the individual sessions that you have recorded. In this tutorial we go through the steps of installing NANSEN and setting up your first project. As an example, we will use data from mice that run on a linear track headfixed while two-photon calcium-imaging data is recorded. We will go through the whole process from defining your project, to computing the percentage of spatially tuned cells in the recorded sessions.


## Installing NANSEN

## Setting up a project






## The Metatable
The core idea of NANSEN is to easily structure and process your neuroscience data. Its functionality centers around the individual sessions that you have recorded. Each session is listed in the NANSEN *Metatable*, and user-defined custom functions can be applied to any of these sessions.

Because every project is different and often require custom pipelines for processing and analysis, NANSEN allow you to create custom fields in the table to show relevant data for each session. In NANSEN these columns are called **table functions**. 

### Table functions 
*Table functions* are text variables or functions that will render output in the NANSEN *Metatable*. 
When a table function is defined, the corresponding column in the metatable will be updated for any new session that you add to your project. These functions can also easily be shared with others for them to use in their project. 

You can add a new column to your table by either 
1. Go to **Table > Add New Variabel ...**
2. Add a function to the project folder: **[ProjectFolder] > Metadata Tables > +tablevar > +session**


### Session tasks
More complex operations, such as motion correction of two-photon data, automatic R.O.I. segmentation, spike-sorting or highly specific task such as 
comparing the % of place tuned cells in sessions before and after noon can be implemented in what is refered to as **session tasks**. Such tasks can either be defined as functions or as class definitions.

You can add a new session task by either:
1. Go to **Table > Create New Session Task**
2. Add a function or class definition inside your project folder: **[ProjectFolder] > Session Methods > +[ProjectName] > +[subFolder]**.
