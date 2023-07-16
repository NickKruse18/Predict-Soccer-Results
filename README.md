# Predict the results of a Soccer/Football League

This package provides some functions to easily scrape game results from www.soccerbase.com and also provides a model for predicting future results along with the results of customized leagues.
Please note that the predictions made in this package are in no way guaranteed to be accurate and they should not be taken as betting advice. This package is primarily a demonstration.


To install the package in R use: install.packages("directory/poissoc_1.0.0.tar.gz",  repos = NULL,  type = "source"), where 'directory' should be replaced with the file destination. Remember to replace any '\\' with '/'


To access the functions of the package it may be necessary to start every function call with poissoc::,  fx. to use the function SetupLeague type poissoc::SetupLeague.


Every function has Rdocumentation so for more information about a function type fx. ?poissoc::FitTeams. 


Example for finding odds for the 2023/2024 Premier League:


install.packages("directory/poissoc_1.0.0.tar.gz",  repos = NULL,  type = "source") # Change "directory" to match


library(poissoc)


Prem23 = poissoc::RetrieveLeague(2039)    #2039 is the ID in Soccerbase for Premier League 2023/2024. This can be changed to correspond to any league in any season.


Matches = poissoc::RetrieveH2H(Prem23,2017,2022)    #Downloads every H2H match played between the teams in Premier League in the seasons from 2017/2018 to 2022/2023. This is quite slow because of Soccerbases loading times.


Ratings = poissoc::FitTeams(Matches,Prem23)    #Fits the Poisson model to the games and gives every team a rating


ToPlay = poissoc::SetGames(Prem23)    #Sets games in the standard league format: Every team plays twice against every other team, once as home and once as away.


Odds = poissoc::PredictGames(Ratings,ToPlay,Prem23)    #Gives odds for every game in ToPlay and odds for the final standings
