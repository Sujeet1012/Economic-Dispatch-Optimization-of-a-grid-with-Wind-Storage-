Set t   hours           /t1*t24/
Set g   thermal units   /p1*p4/ ;

Table gendata (g,*) generator cost characteristics and limits - 
    a       b       c       d       e       f       Pmin    Pmax    RU0     RD0
p1  0.12    14.80   89      1.2     -5      3       28      200     40      40
p2  0.17    16.57   83      2.3     -4.24   6.09    20      290     30      30
p3  0.15    15.55   100     1.1     -2.15   5.69    30      190     30      30
p4  0.19    16.21   70      1.1     -3.99   6.2     20      260     50      50;

Table data (t ,*)
        load    
t1      510      
t2      530      
t3      516     
t4      510     
t5      515      
t6      544      
t7      646      
t8      686      
t9      741      
t10     734      
t11     748      
t12     760      
t13     754      
t14     700      
t15     686     
t16     720     
t17     714      
t18     761     
t19     727      
t20     714      
t21     618      
t22     584      
t23     578     
t24     544;

scalar
SOC0 /100/ , SOCmax /300/ , eta_c /0.95/ , eta_d /0.9/;

variables
costThermal Cost of thermal units
p(g , t ) Power generated by thermal power plant
EM Emission calculation
SOC( t ) , Pd ( t ) , Pc ( t );

p.up ( g , t ) = gendata ( g , "Pmax") ;
p.lo ( g , t ) = gendata ( g , "Pmin") ;

SOC.up ( t ) =SOCmax ;
SOC.lo ( t ) =0.2*SOCmax ;

Pc.up ( t ) =0.2*SOCmax ;
Pc.lo( t ) =0;

Pd.up ( t ) =0.2*SOCmax ;
Pd.lo ( t ) =0;


SOC.fx ( 't24' ) =SOC0 ; 
 
Equations
Genconst3  ,
Genconst4 ,
costThermalcalc,
balance, 
constESS1,
EMcalc
;

costThermalcalc ..
costThermal=e=sum (( t ,g) , gendata (g, 'a')*power (p(g , t ) ,2)+gendata (g , 'b' )* p(g, t ) +gendata (g, 'c') ) ;

Genconst3 (g , t ) .. p(g , t+1 ) -p ( g , t ) =l= gendata ( g , 'RU0' ) ;

*Genconst3 (g , t ) .. p(g , t ) -p ( g , t-1 ) =l= gendata ( g , 'RU0' ) ;

Genconst4 (g , t ) ..  p(g , t -1) -p ( g , t ) =l= gendata ( g , 'RD0' ) ;

constESS1 ( t ) ..
SOC( t ) =e=SOC0$ (ord(t)=1)+ SOC(t -1) $( ord(t)>1) + Pc ( t )* eta_c -Pd(t)/eta_d ;

balance ( t ) .. sum (g , p (g,t) )+Pd (t)=e=data ( t , 'load' )+Pc ( t ) ;

EMcalc.. EM =e= sum((t, g), gendata(g, 'd') * power(p(g, t), 2) + gendata(g, 'e') * p(g, t) + gendata(g, 'f'));

Model DEDESScostbased / all / ;

Solve DEDESScostbased us qcp min costThermal;

display costThermal.l, p.l, SOC.l, Pd.l, Pc.l, EM.l;
 














