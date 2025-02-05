Set
   bus        / 1*24   /
   slack(bus) / 13     /
   Gen        / g1*g12 /
   t          / t1*t24 /;

Scalar
   Sbase /   100 /
   VOLL  / 10000 /
   VOLW / 50 /
   Nmax  / 15 /;

Alias (bus,node);

Table GD(Gen,*) 'generating units characteristics'
        Pmax Pmin   b      RU   RD    
   g1   400  100    5.47   47   47    
   g2   400  100    5.47   47   47    
   g3   152  30.4   13.32  14   14   
   g4   152  30.4   13.32  14   14   
   g5   155  54.25  16     21   21   
   g6   155  54.25  10.52  21   21   
   g7   310  108.5  10.52  21   21    
   g8   350  140    10.89  28   28    
   g9   350  75     20.7   49   49    
   g10  591  206.85 20.93  21   21    
   g11  60   12     26.11  7    7    
   g12  300  0      0      35   35 ;
* -----------------------------------------------------

Set GB(bus,Gen) 'connectivity index of each generating unit to each bus'
/
   18.g1
   21.g2
   1. g3
   2. g4
   15.g5
   16.g6
   23.g7
   23.g8
   7. g9
   13.g10
   15.g11
   22.g12
/;

Table BusData(bus,*) 'demands of each bus in MW'
       Pd    
   1   108   
   2   97    
   3   180   
   4   74   
   5   71    
   6   136   
   7   125   
   8   171   
   9   175   
   10  195   
   13  265   
   14  194  
   15  317  
   16  100   
   18  333   
   19  181   
   20  128  ;
****************************************************

Table branch(bus,node,*) 'network technical characteristics'
              x        b       limit
   1 .2       0.0139   0.4611  175
   1 .3       0.2112   0.0572  175
   1 .5       0.0845   0.0229  175
   2 .4       0.1267   0.0343  175
   2 .6       0.192    0.052   175
   3 .9       0.119    0.0322  175
   3 .24      0.0839   0       400
   4 .9       0.1037   0.0281  175
   5 .10      0.0883   0.0239  175
   6 .10      0.0605   2.459   175
   7 .8       0.0614   0.0166  175
   8 .9       0.1651   0.0447  175
   8 .10      0.1651   0.0447  175
   9 .11      0.0839   0       400
   9 .12      0.0839   0       400
   10.11      0.0839   0       400
   10.12      0.0839   0       400
   11.13      0.0476   0.0999  500
   11.14      0.0418   0.0879  500
   12.13      0.0476   0.0999  500
   12.23      0.0966   0.203   500
   13.23      0.0865   0.1818  500
   14.16      0.0389   0.0818  500
   15.16      0.0173   0.0364  500
   15.21      0.0245   0.206   1000
   15.24      0.0519   0.1091  500
   16.17      0.0259   0.0545  500
   16.19      0.0231   0.0485  500
   17.18      0.0144   0.0303  500
   17.22      0.1053   0.2212  500
   18.21      0.0130   0.109   1000
   19.20      0.0198   0.1666  1000
   20.23      0.0108   0.091   1000
   21.22      0.0678   0.1424  500 ;
* ----------------------------------------------

Table WD(t,*)
        w                   d
   t1   0.0786666666666667  0.684511335492475
   t2   0.0866666666666667  0.644122690036197
   t3   0.117333333333333   0.61306915602972
   t4   0.258666666666667   0.599733282530006
   t5   0.361333333333333   0.588874071251667
   t6   0.566666666666667   0.5980186702229
   t7   0.650666666666667   0.5980186702229
   t8   0.566666666666667   0.651743189178891
   t9   0.484               0.706039245570585
   t10  0.548               0.787007048961707
   t11  0.757333333333333   0.839016955610593
   t12  0.710666666666667   0.852733854067441
   t13  0.870666666666667   0.870642027052772
   t14  0.932               0.834254143646409
   t15  0.966666666666667   0.816536483139646
   t16  1                   0.819394170318156
   t17  0.869333333333333   0.874071251666984
   t18  0.665333333333333   1
   t19  0.656               0.983615926843208
   t20  0.561333333333333   0.936368832158506
   t21  0.565333333333333   0.887597637645266
   t22  0.556               0.809297008954087
   t23  0.724               0.74585635359116
   t24  0.84                0.733473042484283;

Parameter Wcap(bus) / 8 200, 19 150, 21 100 /;

branch(bus,node,'x')$(branch(bus,node,'x')=0)=branch(node,bus,'x');
branch(bus,node,'Limit')$(branch(bus,node,'Limit')=0)=branch(node,bus,'Limit');
branch(bus,node,'bij')$branch(bus,node,'Limit')=1/branch(bus,node,'x');

parameter SOCMax(bus);
SOCMax(bus) =20;

scalar eta_c/0.95/ ,
eta_d /0.9/,
VWC /50/;

parameter SOC0( bus ) ;
SOC0( bus ) =0.2*SOCMax( bus ) / sbase ;


parameter conex(bus,node);
conex(bus,node)$(branch(bus,node,'limit')and branch(node,bus,'limit'))=1;
conex(bus,node)$(conex(node,bus))=1;

Variable OF, Pij(bus,node,t), Pg(Gen,t), delta(bus,t), lsh(bus,t), Pw(bus,t),
pwc(bus,t),SOC(bus,t) , Pd(bus,t) , Pc(bus,t);

Integer variable NESS(bus);
 
Equations const1, const2, const3, const4, const5, const6, constESS,
constESS2, constESS3, constESS4, constESS5, constESS6 ;






const1(bus,node,t)$(conex(bus,node)).. Pij(bus,node,t) =e= branch(bus,node, 'bij')*(delta(bus,t) - delta(node,t));

const2(bus,t).. lsh(bus,t)$BusData(bus,'pd') + Pw(bus,t)$Wcap(bus) + sum(Gen$GB(bus,Gen), Pg(Gen,t)) - WD(t,'d')*BusData(bus,'pd')/Sbase =e= sum(node$conex(node,bus), Pij(bus,node,t));

const3.. OF =e= sum((bus,Gen,t)$GB(bus,Gen), Pg(Gen,t)*GD(Gen,'b')*Sbase) + sum((bus,t), VOLL*lsh(bus,t)*Sbase$BusData(bus,'pd') + VWC*Pc(bus,t)*sbase$Wcap(bus));

const4(gen,t)..   pg(gen,t+1) - pg(gen,t) =l= GD(gen,'RU')/Sbase;

const5(gen,t)..   pg(gen,t-1) - pg(gen,t) =l= GD(gen,'RD')/Sbase;

const6(bus,t)$Wcap(bus)..   pwc(bus,t) =e= WD(t,'w')*Wcap(bus)/Sbase - pw(bus,t);

constESS(bus,t) .. SOC(bus,t) =e= (0.2 * NESS(bus) * SOCMax(bus) / Sbase)$(ord(t)=1) + SOC(bus,t-1) $(ord(t) >1) + Pc(bus,t) *eta_c - Pd(bus,t)/eta_d;

constESS2(bus,t) .. SOC(bus,t) =l= NESS(bus) * SOCMax(bus) / Sbase;
constESS3(bus,t) .. Pc(bus,t)  =l= 0.2*NESS(bus)* SOCMax(bus) / Sbase;
constESS4(bus,t) .. Pd(bus,t)  =l= 0.2*NESS(bus)* SOCMax(bus) / Sbase;
constESS5.. sum ( bus, NESS(bus) ) =l= Nmax;
constESS6(bus).. SOC(bus, 't24') =e= 0.2* NESS(bus) * SOCMax(bus) / Sbase;

 
Pg.lo(Gen,t) = GD(Gen,'Pmin')/Sbase;
Pg.up(Gen,t) = GD(Gen,'Pmax')/Sbase;

delta.up(bus,t)   = pi/2;
delta.lo(bus,t)   =-pi/2;
delta.fx(slack,t) = 0;

Pij.up(bus,node,t)$((conex(bus,node))) =  branch(bus,node,'Limit')/Sbase;
Pij.lo(bus,node,t)$((conex(bus,node))) = -branch(bus,node,'Limit')/Sbase;


lsh.up(bus,t) = WD(t,'d')*BusData(bus,'pd')/Sbase;
lsh.lo(bus,t) = 0;

Pw.up(bus,t)  = WD(t,'w')*Wcap(bus)/Sbase;
Pw.lo(bus,t)  = 0;
pwc.up(bus,t) = WD(t ,'w')*Wcap(bus)/Sbase;
Pwc.lo(bus,t) =0;
SOC.lo(bus,t) =0 ;
Pc.lo(bus,t)  = 0;
Pd.lo(bus,t)  = 0;

NESS.up(bus) = 5;

Model loadflow / all / ;
Solve loadflow minimizing OF using mip;











