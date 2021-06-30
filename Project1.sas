/* 200B Project 1 */

/* Our research question is to characterize how mode
of transportation, departure time, day of week and 
presence of rain are related to average speed (miles/hour)
during a commute to the UCLA campus. Optional: you may use other
variables in the model if you chose, e.g., use the zip code 
variable to create some interesting predictor, and/or include 
interactions if appropriate*/

/* data myset;
infile "/folders/myfolders/200B_DATA/BS200Bdataproject.xlsx" dsd firstobs=2;
run;
*/
data a;
infile "/folders/myfolders/200B_DATA/BS200Bdataproject.csv" dsd firstobs=2;
length UID $30
       Date $40
       Day_of_Week $12
       Comments $90
       Mode_of_Transport $30;

input UID
      Travel_Time
      Date
      Starting_ZIP_Code
      Distance
      Mode_of_Transport
      Departure_Time :stimer8.
      Day_of_Week $
      Rain $
      Comments $;
run;
       
/* import data */
/* PROC IMPORT datafile="/folders/myfolders/200B_DATA/BS200Bdataproject.csv"
DBMS=csv
OUT= mySet
REPLACE;
getnames=yes;
RUN;*/
PROC FORMAT;
value d_time low-420 = "Before 7AM"
		   421-480 = "7AM - 8AM"
		   481-540 = "8AM - 9AM"
           541-600 = "9AM - 10PM"
           601-660 = "10AM - 11AM"
           661-720 = "11AM - 12PM"
           721-780 = "12PM - 1PM"
           781-high = "After 1PM";
value rain 0 = "No Rain"
           1 = "Rain";
run;


/* proc datasets library=WORK;
  delete d2;
run;*/

DATA myset;
SET a;
/* DROP VAR11-VAR25;*/
IF UID = . THEN delete;
RENAME Mode_of_Transport = Trans;
RUN;

DATA myset;
SET myset;
Travel_Time_Hour = Travel_Time / 60;
Ave_Speed = Distance / Travel_Time_Hour;
log2speed = log2(Ave_Speed);
if Trans = 'walk' then trans_dum = 0;
else if Trans = 'car' or (Trans = 'Car/walk') then trans_dum = 1;
else if Trans = 'bus' or (Trans ='Bus') then trans_dum = 2;
else if Trans = 'ride share' or (Trans = 'walk/ride share') then trans_dum = 3;
else if Trans = 'bike' then trans_dum = 4;
else if Trans = 'uber' or (Trans = 'Lyft') or (Trans = 'lyft') then trans_dum = 5;
else trans_dum = 6; /* other */

if Departure_Time <= 420 then departure_time_interval = 0; /* before 7 */
if Departure_Time > 420 and Departure_Time <= 480 then departure_time_interval = 1; /* 7-8 */
if Departure_Time >480 and Departure_Time <= 540 then departure_time_interval = 2; /* 8-9 */
if Departure_Time >540 and Departure_Time <= 600 then departure_time_interval = 3; /* 9-10 */
if Departure_Time >600 and Departure_Time <= 660 then departure_time_interval = 4; /* 10-11 */
if Departure_Time >660 and Departure_Time <= 720 then departure_time_interval = 5; /* 11-12 */
if Departure_Time >720 and Departure_Time <= 780 then departure_time_interval = 6; /* 12-1 */
if Departure_Time >780 then departure_time_interval = 7; /* after */

if Rain = 'N' then rain_or_not = 0;
if Rain = 'Y' then rain_or_not = 1;

if Day_of_Week = 'Monday' then what_day = 1;
if Day_of_Week = 'Tuesday' then what_day = 2;
if Day_of_Week = 'Wednesday' then what_day = 3;
if Day_of_Week = 'Thursday' then what_day = 4;
if Day_of_Week = 'Friday' then what_day = 5;
RUN;

/* set dummy variables */
data d2;
set myset;
/* before 7 am as reference group */
/* if Departure_Time <= 420 then d1 = 1; else d1 = 0; *//* before 7 */
if Departure_Time > 420 and Departure_Time <= 480 then d2 = 1; else d2 = 0; /* 7-8 */
if Departure_Time >480 and Departure_Time <= 540 then d3 = 1; else d3 = 0; /* 8-9 */
if Departure_Time >540 and Departure_Time <= 600 then d4 = 1; else d4 = 0; /* 9-10 */
if Departure_Time >600 and Departure_Time <= 660 then d5 = 1; else d5 = 0; /* 10-11 */
if Departure_Time >720 and Departure_Time <= 780 then d7 = 1; else d7 = 0; /* 12-1 */
if Departure_Time > 780 then d8=1; else d8=0;

/* Trans = 'walk' reference group */
if Trans = 'car' or (Trans = 'Car/walk') then t1 = 1; else t1 = 0;
if Trans = 'bus' or (Trans ='Bus') then t2 = 1; else t2 = 0;
if Trans = 'ride share' or (Trans = 'walk/ride share')then t3 = 1; else t3 = 0;
if Trans = 'bike' then t4 = 1; else t4 = 0;
if Trans = 'uber' or (Trans = 'Lyft') or (Trans = 'lyft') then t5 = 1; else t5 = 0;
if trans_dum = 6 then t6 = 1; else t6 = 0;

/* rain as reference group */
if Rain_or_not = 0 then r = 1; 
if Rain_or_not = 1 then r = 0;

/* Monday as a reference group */
if what_day = 2 then w1=1; else w1 = 0;
if what_day = 3 then w2=1; else w2 = 0;
if what_day = 4 then w3=1; else w3 = 0;
if what_day = 5 then w4=1; else w4 = 0;
run;

data d2; set d2;
format rain_or_not rain.;

run;

/* examine the univariate distribution of variables */
proc univariate data = d2;
var what_day Ave_Speed rain_or_not;
run;

proc sgplot data=d2;
    histogram Ave_Speed / fillattrs=(color=CX4DBF81) binwidth=1;
    xaxis label="Average Speed (miles/hour)";
    title "Distribution of Average Speed";
run;

proc sgplot data=d2;
	histogram trans_dum / fillattrs=(color=CX4DBF81);
	xaxis label="Mode of Transportation" values=(-1 to 7 by 1);
	title "Distribution of Different Methods of Transportation";
run;
proc sgplot data=d2;
	histogram departure_time_interval / binwidth=1 binstart=0 fillattrs=(color=CX4DBF81);
	xaxis label="Departure Time";
	title "Distribution of Different Departure Time";
run;
proc sgplot data=d2;
	histogram what_day / fillattrs=(color=CX4DBF81) binwidth=1 binstart=1;
	xaxis values = (1 to 5 by 1);
	xaxis label = "Day of the Week";
	title "Distributioin of Days of the week";
run;
proc sgplot data=d2;
    histogram rain_or_not / fillattrs=(color=CX4DBF81) binwidth=1 binstart=0;
    xaxis label = "Rain or not" values=(0 to 1 by 1);
    title "Distribution of Rain";
run;

proc sgplot data = d2;
    loess y = Ave_Speed x = rain_or_not;
    xaxis label="Rain or not";
	yaxis label= "Average Speed (miles/hour)";
run;

proc sgplot data=d2;
	loess y = Ave_Speed x = trans_dum;
	xaxis label="Mode of Transportations";
	yaxis label= "Average Speed (miles/hour)";
run;

proc sgplot data = d2;
    loess y = log2speed x = what_day;
    xaxis label="Day of the Week";
	yaxis label="Average Speed (miles/hour)";
run;

proc sgplot data=d2;
	loess y = Ave_Speed x = departure_time_interval;
	xaxis label="Departure Time Intervals" values = (0 to 7 by 1);
	yaxis label="Average Speed (miles/hour)";
run;

/* examine bivariate distributions of variables */
proc corr data=d2;
	var Ave_Speed d2 d3 d4 d5 d7 d8;
run;

proc corr data=d2;
	var log2speed d2 d3 d4 d5 d7 d8;
run;

proc corr data=d2;
    var Ave_Speed t1 t2 t3 t4 t5 t6;
run;

proc corr data=d2;
    var Ave_Speed w1 w2 w3 w4;
run;

proc corr data=d2;
    var Ave_Speed r;
run;

/* regress on average speed of depature time */

proc reg data=d2;
	model log2speed = d2 d3 d4 d5 d7 d8;
	test d2=d3=d4=d5=d7=d8;
	test d2 = d3;
	test d2 = d4;
	test d2 = d5;
	test d2 = d7;
	test d2 = d8;
	test d3 = d4;
	test d3 = d5;
	test d3 = d7;
	test d3 = d8;
	
	test d4 = d5;
	test d4 = d7;
	test d4 = d8;
	test d5 = d7;
	test d5 = d8;
	test d7 = d8;
run; quit;

proc loess data=d2;
    model log2speed = d2 d3 d4 d5 d7 d8;
run;

/* regress on average speed of mode of transportation */
/* log y has better model assumption */
proc reg data=d2;
	model log2speed = t1 t2 t3 t4 t5 t6;
	test t1=t2=t3=t4=t5=t6;
run; quit;

proc loess data=d2;
    model Ave_Speed = t1 t2 t3 t4 t5 t6;
run;

proc loess data=d2;
    model log2speed = t1 t2 t3 t4 t5 t6;
run;
/* regress on average speed of day of week */
proc reg data=d2;
    model Ave_Speed = w1 w2 w3 w4;
    test w1=w2=w3=w4;
run;

/* model assumption better, pick this one */
proc reg data=d2;
    model log2speed = w1 w2 w3 w4;
run;

proc loess data=d2;
model Ave_Speed = w1 w2 w3 w4;
run;

proc loess data=d2;
model log2speed = w1 w2 w3 w4;
run;

/* regress on average speed of rainy day or not */
/* neither good */
proc reg data=d2;
	model Ave_Speed = r;
run; quit;

proc reg data=d2;
model log2speed = r;
run;

proc loess data=d2;
model Ave_Speed = r;
run;

proc loess data=d2;
model log2speed = r;
run;

/* multiple regression on average speed of all 4 predictors */
proc reg data = d2;
model Ave_Speed = t1 t2 t3 t4 t5 t6 d2 d3 d4 d5 d7 d8 w1 w2 w3 w4 r;
run;

proc reg data = d2;
model log2speed = t1 t2 t3 t4 t5 t6 d2 d3 d4 d5 d7 d8 w1 w2 w3 w4 r;
run;

proc loess data = d2;
model Ave_Speed = t1 t2 t3 t4 t5 t6 d2 d3 d4 d5 d7 d8 w1 w2 w3 w4 r;
run;

proc loess data = d2;
model log2speed = t1 t2 t3 t4 t5 t6 d2 d3 d4 d5 d7 d8 w1 w2 w3 w4 r;
run;








