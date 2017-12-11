Calculate more accurate standard deviation as quarters are added

see
https://goo.gl/m1mYhd
https://communities.sas.com/t5/General-SAS-Programming/Estimate-standard-deviation-quarter-by-quarter/m-p/420065

PeterC profile
https://communities.sas.com/t5/user/viewprofilepage/user-id/15174


Estimate standard deviation quarter by quarter

INPUT
=====

 WORK.HAVE total obs=7                 |    RULES Progessive standard deviations
                                       |
 COMPANY    YEAR    QUARTER    COGSQ   |    COGSTD
                                       |
    A       1983       1       1.258   |    .
    A       1983       2       1.400   |   0.10041   std(1.258,1.4) = 0.1004091629
    A       1983       3       1.500   |   0.12161   std(1.258,1.4,1.5) = 0.1216059209
    A       1983       4       1.600   |   0.14597   std(1.258,1.4,1.5,1.6) = 0.1459714584
    A       1986       1       2.300   |   0.40506   std(1.258,1.4,1.5,1.6,2.3) = 0.405059008
                                       |
    B       1984       2       3.500   |    .
    B       1984       3       6.500   |   2.12132   std(3.5,6.5) = 2.1213203436


WORKING CODE
=======+====

     COMPILE TIME META DATA (DOSUBL)
       * get max number of quarters;
           do i=1 by 1 until(last.company);
              set have end=dne;
              by company;
           end;
           if i > maxqtrs then maxqtrs=i;
           if dne then call symputx('maxqtrs',maxqtrs);

     MAINLINE
        do item= 1 by 1 until( last.company) ;
           set have;
           by company ;
           array cogX(&maxqtrs.) ;
           cogX(item) = cogsq ;
           n_cogs = n( of cogX(*) ) ;
           if n_cogs > 1 then COGSTD = std( of cogX(*) ) ;
           output ;
        end ;

OUTPUT
======

Up to 40 obs WORK.WANT total obs=7

Obs    COMPANY    YEAR    QUARTER    ITEM    COGSQ    N_COGS     COGSTD

 1        A       1983       1         1     1.258       1       .
 2        A       1983       2         2     1.400       2      0.10041
 3        A       1983       3         3     1.500       3      0.12161
 4        A       1983       4         4     1.600       4      0.14597
 5        A       1986       1         5     2.300       5      0.40506
 6        B       1984       2         1     3.500       1       .
 7        B       1984       3         2     6.500       2      2.12132


*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

data have;
retain company year quarter cogsq;
input gvkey$ datadate:yymmdd10. Company$ COGSQ;
quarter=qtr(datadate);
year=year(datadate);
format datadate yymmdd10.;
drop datadate gvkey;
cards4;
1001 19830331 A 1.258
1001 19830630 A 1.4
1001 19830930 A 1.5
1001 19831231 A 1.6
1001 19860331 A 2.3
1002 19840430 B 3.5
1002 19840731 B 6.5
;;;;
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

data want ;
  if _n_=0 then do;
    %let rc=%sysfunc(dosubl('
        * get the maximum number of quarters;
        data _null;
           retain maxqtrs .;
           do i=1 by 1 until(last.company);
              set have end=dne;
              by company;
           end;
           if i > maxqtrs then maxqtrs=i;
           if dne then call symputx('maxqtrs',maxqtrs);
        run;quit;
    '));
  end;

  retain company year quarter item cogsq;
  do item= 1 by 1 until( last.company) ;
     set have;
     by company ;
     array cogX(&maxqtrs.) ;
     cogX(item) = cogsq ;
     n_cogs = n( of cogX(*) ) ;
     if n_cogs > 1 then COGSTD = std( of cogX(*) ) ;
     output ;
  end ;
  drop cogX: ; run ;

run;quit;

