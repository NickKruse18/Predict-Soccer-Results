
c(142,154,359,378,381,435,536,646,942,1055,1563,1628,1718,1724,1823,1845,2328,2590,2802,2848)


RetrieveH2H = function(TeamID){
  url = "https://www.soccerbase.com/teams/team.sd?";  n = length(TeamID)
  Games = matrix(0,0,5)
  for(i in 1:(n-1)){
    for(j in (i+1):n){
      suppressMessages({
        download.file(url=paste0(url,"team_id=",TeamID[i],"&team2_id=",TeamID[j],"&teamTabs=h2h"),"D:/Projects/R/Football/D.txt")
      })
      
      suppressWarnings({
        fil = paste(readLines("D:/Projects/R/Football/D.txt"), collapse="\n")
      })
      
      matches = unlist(gregexpr("Show full match details",fil))
      I1 = unlist(gregexpr(paste0("team_id=",TeamID[i]),fil))
      I2 = unlist(gregexpr(paste0("team_id=",TeamID[j]),fil))
      Score = unlist(gregexpr("</em>&nbsp;-&nbsp;<em>",fil))
      Season = numeric(11)
      for(k in 1:11){
        Season[k] = unlist(gregexpr(paste0(2023-k,"/",2024-k),fil))[1]
      }
      k1 = 1
      games = matrix(0,0,5)
      for(k in 2:11){
        if(Season[k1] == -1){ k1 = k;  next }
        if(Season[k] == -1){ next }
        match = matches[(matches>Season[k1])&(matches<Season[k])]
        for(k2 in match){
          g = numeric(5);  i1 = I1[I1>k2][1];  i2 = I2[I2>k2][1]
          if(i1<i2){ g[1] = TeamID[i];  g[2] = TeamID[j] }
          else{ g[1] = TeamID[j];  g[2] = TeamID[i] }
          sH = Score[Score>k2][1]; d = sH-1
          while(substr(fil,d,d)!='>'){
            d = d - 1
          }
          g[3] = as.integer(substr(fil,d+1,sH-1))
          sA = Score[Score>k2][1]+21; d = sA+1
          while(substr(fil,d,d)!='<'){
            d = d + 1
          }
          g[4] = as.integer(substr(fil,sA+1,d-1))
          g[5] = k1
          games = rbind(games,g)
        }
        k1 = k
      }
      print(c(TeamID[i],TeamID[j],nrow(games)))
      Games = rbind(Games,games)
    }
  }
  return(Games)
}

teams = c(142,154,359,378,381,435,536,646,942,1055,1563,1628,1718,1724,1823,1845,2328,2590,2802,2848)

Games = RetrieveH2H(teams)










































