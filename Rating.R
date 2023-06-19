

Likelihood = function(stats,Scores){
  a = 0.8;  n = nrow(Scores);  k = length(stats)%/%2
  l = -sum(abs(stats[1:k]-mean(stats[1:k]))-abs(stats[k+1:k]-mean(stats[k+1:k])))
  for(i in 1:n){
    p = 1/(1+exp(stats[k+Scores[i,2]]-stats[Scores[i,1]]+stats[length(stats)]))
    l = l + (Scores[i,3]*log(p) - 90*p)*a^Scores[i,5]
    p = 1/(1+exp(stats[k+Scores[i,1]]-stats[Scores[i,2]]-stats[length(stats)]))
    l = l + (Scores[i,4]*log(p) - 90*p)*a^Scores[i,5]
  }
  return(-l)
}

Fit = function(Games,teams){
  n = nrow(Games);  Games[1:(2*n)] = match(Games[1:(2*n)],teams)
  stats = numeric(2*length(teams)+1);  O = Inf;  W = T
  while(W){
    Opt = optim(stats,Likelihood,Scores = Games, control = list(maxit=1000))
    stats = Opt$par
    if(O-0.01<=Opt$value){ W = F }
    O = Opt$value
    print(O)
  }
  return(stats)
}

GoalsHist = function(Games){
  H = matrix(0,11,11);  n = nrow(Games)
  l1 = sum(Games[,3])/n;  l2 = sum(Games[,4])/n
  for(i in 1:n){
    H[Games[i,3]+1,Games[i,4]+1] = H[Games[i,3]+1,Games[i,4]+1] + 1
  }
  P = outer(dpois(0:10,l1),dpois(0:10,l2))
  D = qbinom(0.99,n,P)
  B = (D+qbinom(0.01,n,P))/2
  D = D-qbinom(0.01,n,P);  D[D==0] = 1
  H2 = 2*(H-B)/D;  H2[(H2==-1)&(P<10^(-4))] = 0
  H2[(H2==1)&(P<10^(-4))] = 0
  B = round((n*P+abs(H2)*H)/(1+abs(H2))/n/P,2)
  return(B)
}

GH = GoalsHist(Games)

stats = Fit(Games,teams)

stats

#-1.5597885 -1.8735341 -2.0631044 -1.8851911 -1.8647461 -2.0867587 -1.7660094 -2.0523949 -1.9721860 -2.0513449
#-1.4502427 -2.2484161 -1.2774974 -1.6812097 -1.9242840 -2.1680922 -2.1708953 -1.6603950 -1.9036309 -2.1368635
# 2.4635964  2.2890260  2.0737496  2.4296683  2.3547388  2.2507737  2.7011515  2.2966609  2.2466909  2.1855273
# 2.6495809  2.0338510  2.8473440  2.5478330  2.3784336  2.1150326  2.2761787  2.4591493  2.2820475  2.4625172
#-0.1295006

teams

Chances = function(stats,Games){
  n = nrow(Games);  k = length(stats)%/%2;  Chances = matrix(0,n,4)
  for(i in 1:n){
    Chances[i,] = c(Games[i,1],Games[i,2],
                    1/(1+exp(stats[k+Games[i,2]]-stats[Games[i,1]]+stats[length(stats)])),
                    1/(1+exp(stats[k+Games[i,1]]-stats[Games[i,2]]-stats[length(stats)])))
  }
  return(Chances)
}

PredictGame = function(Game){
  R = numeric(3)
  H = A = numeric(11)
  for(j in 0:10){
    H[j+1] = dpois(j,90*Game[1])
    A[j+1] = dpois(j,90*Game[2])
  }
  for(j1 in 1:11){
    for(j2 in 1:11){
      if(j1>j2){ R[1] = R[1] + H[j1]*A[j2] }
      if(j1==j2){ R[2] = R[2] + H[j1]*A[j2] }
      if(j1<j2){ R[3] = R[3] + H[j1]*A[j2] }
    }
  }
  return(R/sum(R))
}

Predict = function(Teams,Games,stats,points,m=10000){
  n = nrow(Games)
  Games[1:(2*n)] = match(Games,Teams)
  Chances = Chances(stats,Games)
  Ranks = matrix(0,length(Teams),length(Teams))
  for(j in 1:m){
    P = points
    for(i in 1:n){
      p = PredictGame(Chances[i,3:4])
      u = runif(1)
      if(u<p[1]){ P[Games[i,1]] = P[Games[i,1]] + 3 }
      else if(u<p[1]+p[2]){ P[Games[i,1]] = P[Games[i,1]] + 1;  P[Games[i,2]] = P[Games[i,2]] + 1 }
      else{ P[Games[i,2]] = P[Games[i,2]] + 3 }
    }
    P = sort(P,index.return=TRUE)$ix
    for(i in 1:length(Teams)){ Ranks[i,P[i]] = Ranks[i,P[i]] + 1 }
  }
  return(Ranks/m)
}

Ranks = Predict(teams,SetGames(teams),stats,numeric(20))



(1:20)%*%Ranks
Ranks

Compare = function(teams,stats,Games){
  n = nrow(Games)
  Games[1:(2*n)] = match(Games[1:(2*n)],teams)
  Chances = Chances(stats,Games)
  M = M2 = x = numeric(3); S = 0
  for(i in 1:n){
    p = PredictGame(Chances[i,3:4])
    M = M + p;  M2 = M2 + p
    if(Games[i,3]>Games[i,4]){ x[1] = x[1] + 1;  S = S + p[1] }
    if(Games[i,3]==Games[i,4]){ x[2] = x[2] + 1;  S = S + p[2] }
    if(Games[i,3]<Games[i,4]){ x[3] = x[3] + 1;  S = S + p[3] }
  }
  V = 2*n*sqrt((M2/n - (M/n)^2)/n)
  print(M-V)
  print(x)
  print(M+V)
  print(c(S,n/3,sum(x^2/n)))
}

Compare(teams,stats,Games)

Bet = function(p,B,n=100){
  w = B*qbinom(0.05,n,p)/n
  return(round(w-1,2))
}

SetGames = function(teams,type="RR"){
  Games = 0;  k = length(teams)
  if(type == "RR"){
    Games = matrix(0,(k-1)*k,2)
    i = 1
    for(i1 in 1:k){
      for(i2 in 1:k){
        if(i1 == i2){ next }
        Games[i,] = c(teams[i1],teams[i2])
        i = i + 1
      }
    }
  }
  return(Games)
}

Bets = function(teams,stats,Games,Odds){
  n = nrow(Games); Bets = Odds
  Games[1:(2*n)] = match(Games[1:(2*n)],teams)
  Chances = Chances(stats,Games)
  for(i in 1:n){
    p = PredictGame(Chances[i,3:4])
    Bets[i,] = Bet(p,Odds[i,])
  }
  return(Bets)
}

teams
Bets(teams,stats,matrix(teams,10,2),matrix(3,10,3))

Bet(c(0.4,0.6),c(1/0.5,1/0.5))

teams

cor(Games[,3],Games[,4])





















































