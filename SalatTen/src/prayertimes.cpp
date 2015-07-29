#include <fstream.h>
#include <stdlib.h>
//#include <iostream> // for linux server
#include <math.h>
#include <stdio.h>

//using namespace std; // for linux server

//g++ open.cpp -o open   //compile on linux

    //longtud=39.83;latud=21.42;Zonh=3; for Makkah
   //prayertimes  latitude longitude timezone aser prayer_method fajr_twilight1 isha_twilight fajr_twilight2 isha_difference dhuhrInterval maghribInterval daily_monthly year month day hour_format daylight  startDay_daylight	startMonth_daylight endDay_daylight endMonth_daylight
    //prayertimes 21.42 39.83 3 1 4 0 0 0 0 0 0 1 2009 1 5 1 0 0 0 0 0 //'prayertimes' is a file name


char  DyWk[][35]	={"Sunday",
		  "Monday",
		  "Tuesday",
		  "Wednesday",
		  "Thursday",
		  "Friday",
		  "Saturday"};

char  Hmonth[][35]={"Muharram",
		"Safar",
		"Rabi Al-Awwal",
		"Rabi Al-Akhar",
		"Jumada Al-Awwal",
		"Jumada Al-Akhirah",
		"Rajab",
		"Shaban",
		"Ramadan",
		"Shawwal",
		"Dhul-Qadah",
		"Dhul-Hijjah"};

/*------------------------------------------------------*/
const double pi = 3.1415926535897932;
#define DToR (pi / 180.0)

#define HStartYear 1420
#define HEndYear 1450

#define RToH (12 / pi)
#define EarthRadius 6378.1


int MonthMap[]={19410
	    ,19396,19337,19093,13613,13741,15210,18132,19913,19858,19110
	    ,18774,12974,13677,13162,15189,19114,14669,13469,14685,12986
	    ,13749,17834,15701,19098,14638,12910,13661,15066,18132,18085
	    };
short gmonth[14]={31,31,28,31,30,31,30,31,31,30,31,30,31,31};/* makes it circular m[0]=m[12] & m[13]=m[1] */
short smonth[14]={31,30,30,30,30,30,29,31,31,31,31,31,31,30}; /* makes it circular m[0]=m[12] & m[13]=m[1]  */


  int OmAlQrahr(int year,int month,int day, double param[], double lst[]);
	void GDateAjust(int *yg,int *mg,int *dg);
      //void Writime(ofstream &dataout, double h);
	  void Writime(double h, int prayerName, int dhuhrInterval, int maghribInterval, int hour_format);
//      void Writime(double h);
	int  BH2GA(int yh,int mh,int *yg,int *mg, int *dg,int *dayweek);
	void  G2HA(int yg,int mg, int dg,int *yh,int *mh,int *dh,int *dayweek);
	int  H2GA(int *yh,int *mh,int *dh,int *yg,int *mg, int *dg,int *dayweek);
	void S2G(int ys,int ms,int ds,int *yg,int *mg,int *dg);
	void G2S(int yg,int mg,int dg,int *ys,int *ms,int *ds);


	double GCalendarToJD(int yg,int mg, double dg );
	double JDToGCalendar(double JD, int *yy,int *mm, int *dd);
	int GLeapYear(int year);

	void GDateAjust(int *yg,int *mg,int *dg);
	int DayWeek(long JulianD);


	void JDToHCalendar(double JD,int *yh,int *mh,int *dh);
	void JDToHACalendar(double JD,int *yh,int *mh,int *dh);
	double HCalendarToJD(int yh,int mh,int dh);
	double HCalendarToJDA(int yh,int mh,int dh);
	int HMonthLength(int yh,int mh);

	double ip(double x);
	int mod(double x, double y);

      void GetRatior(int yg,int mg,int dg,double param[],double *IshRt,double *FajrRt);

/*------------------------- Sun ------------------------------------------*/
     double atanxy(double x,double y);
     void EclipToEquator(double lmdr,double betar,double &alph, double &dltr);
     double RoutinR2(double M,double e);
     double GCalendarToJD(int yg,int mg, double dg );
     double SunParamr(int yg,int mg, int dg,double ObsLon,double ObsLat, double TimeZone,
		double *Rise,double *Transit,double *Setting,double *RA,double *Decl,int *RiseSetFlags);


/*---------------------------------------------------------------------*/

	 int daylightSavings(double latud, int user_day, int user_month, int startDay_daylight, int startMonth_daylight, int endDay_daylight, int endMonth_daylight);
	 void dailyPrayer(double latud, int daylight, int user_month, int startDay_daylight, int startMonth_daylight, int endDay_daylight, int endMonth_daylight, double lst[], double param[], double Zonh, int dg0, int mg0, int yg0, double dhuhrInterval, double maghribInterval, int hour_format);
	 void monthlyPrayer(double latud, int daylight, int user_month, int startDay_daylight, int startMonth_daylight, int endDay_daylight, int endMonth_daylight, double lst[], double param[], double Zonh, int dg0, int mg0, int yg0, double dhuhrInterval, double maghribInterval, int hour_format);

void xyz(double lat, double lon, double tz)
{
   double lst[14],param[12],Zonh;
   double longtud,latud;
   int yg,mg,dg;
   int yg0,mg0,dg0;
   //int yh,mh,dh;
   //double JD,JDH;
   int i;
int hour_format;

   int daily_monthly,aser,daylight,pmethod,startDay_daylight,startMonth_daylight,endDay_daylight,endMonth_daylight;
   int user_year, user_month, user_day;
   double fajrTwilight1, fajrTwilight2, ishaTwilight, ishaInterval, dhuhrInterval, maghribInterval;

    //longtud=39.83;latud=21.42;Zonh=3; for Makkah
   //prayertimes  latitude longitude timezone aser prayer_method fajr_twilight1 isha_twilight fajr_twilight2 isha_difference dhuhrInterval maghribInterval daily_monthly year month day hour_format daylight  startDay_daylight	startMonth_daylight endDay_daylight endMonth_daylight
    //prayertimes 21.42 39.83 3 1 4 0 0 0 0 0 0 1 2009 1 5 1 0 0 0 0 0 //'prayertimes' is a file name



   	latud   = lat;
	longtud   = lon;
	Zonh     = tz; // timezone
	aser     = 1; // Asr ratio, 1 for Standard (Shafi) and 2 for Hanafi
	pmethod  = 3; //prayer method, 1 for Muslim World League, 2 for Eyption Method, 3 for Karachi method, 4 for Ummal Qura and 5 for ISNA.

	/*if pmethod == 6*/
	fajrTwilight1  = 3;
	ishaTwilight  = 0;

	/*if pmethod == 7*/
	fajrTwilight2  = 0;
	ishaInterval  = 1; //difference of Isha time from Maghrib


	dhuhrInterval  = 1; //add minutes in zawal time for dhuhr prayer time
	maghribInterval  = 1; //add minutes in sunset for maghrib prayer time

	daily_monthly  = 1; // 1 for daily and 2 for monthly

	user_year = 2014;
	user_month = 10;
	user_day = 12;

	hour_format = 1; // 0 for no daylight and 1 for yes daylight.

	daylight = 0; // 0 for no daylight and 1 for yes daylight.

	startDay_daylight = 0; //starting date of daylight savings
	startMonth_daylight = 0; //starting month of daylight savings
	endDay_daylight = 0; //end date of daylight savings
	endMonth_daylight = 0; // end month of daylight savings


//qDebug() << "latitide= "<<latud<<",";
//qDebug() << "longitude= "<<longtud<<",";
//qDebug() << "timezone= "<<Zonh<<",";
//qDebug() << "aser= "<<aser<<",";
//qDebug() << "pmethod= "<<pmethod<<",";

 /************************************************************/
 /*        Prayer Calculation Methods                        */
 /* 1- Muslim World League                                   */
 /* 2- Egyptian General Authority of Survey                  */
 /* 3- University Of Islamic Sciences, Karachi               */
 /* 4- Umm Al-Qura                                           */
 /* 5- ISNA                                                  */
 /*                                                          */
 /*         Juristic methods                                 */
 /* 1- Standards (used by imams Shafi, Hanbali, and Maliki)  */
 /* 2- Hanafi                                                 */
 /************************************************************/

	switch(pmethod)
	{
		 //param[6] means fajr twilight angle, param[7] means Isha Twilight angle and param[10] means Isha time Interval from maghrib time.
           case 1 :  /* Muslim World League */
                   param[6]=18*DToR ;   param[7]=17*DToR ;  param[10]=0;
	           break;

           case 2 :   /* Egyptian General Authority of Survey */
                   param[6]=19.5*DToR;    param[7]=17.5*DToR;   param[10]=0;
	           break;

           case 3 :  /* University Of Islamic Sciences, Karachi */
                   param[6]=18*DToR;    param[7]=18*DToR;   param[10]=0;
	           break;

           case 4: /* Umm Al-Qura */
                  param[6]=19*DToR;    param[7]=0;    param[10]=1.5;
                  break;

           case 5 :  /* ISNA  */
                   param[6]=15*DToR;    param[7]=15*DToR;   param[10]=0;
	           break;

           case 6 :  /* Fajr and Isha twilight angles are given */
                   param[6]=fajrTwilight1*DToR ;   param[7]=ishaTwilight*DToR ;  param[10]=0;
	           break;

           case 7 :  /* Fajr twilight and Isha Time interval given */
		ishaInterval = ishaInterval/60;  ////change minutes to hours
                   param[6]=fajrTwilight2*DToR ;   param[7]=0;  param[10]=ishaInterval;
	           break;

	default:
		printf ("Prayer calculation method is not available.\n");
		exit(0);
		break;
        }

   	   param[0]=0.016388;  /* 59seconds, safety time */
	   param[1]=longtud*DToR;  /* Longitude in radians */
	   param[2]=latud*DToR;
	   param[3]=000.0; /* Height dif. East */
	   param[4]=000.0; /* Height dif. West */
	   param[5]=Zonh;     /* Time Zone difference from GMT S.A. +3*/
	   //param[6]=19*DToR; /* Fajer Angle */
	   //param[7]=0; /* Isha Angle  */
	   param[8]= aser; //1;    /* Aser=1,2  OmAlrqah Aser=1*/
	   param[9]=45*DToR;   /* Reference Angle suggested by Rabita */
	   //param[10]=1.5;  /* Isha fixed time from sunset */
	   param[11]=4.2*DToR; /* Eid Prayer Time   */

   yg=user_year;
   mg=user_month;
   dg=user_day;

   dg0=dg;
   mg0=mg;
   yg0=yg;


/*show Hijri Date

   for(day=1;day<=nd;day++)
   {
	   dg0++;
	   GDateAjust(&yg0,&mg0,&dg0);
	   JD=GCalendarToJD(yg0,mg0,dg0);
	  G2HA(yg0,mg0,dg0,&yh1,&mh1,&dh1,&dayweek);
	  JDH=HCalendarToJDA(yh1,mh1,dh1);
	  qDebug()<<yh1<<"-"<<mh1<<"-"<<dh1;
	   JDToHACalendar(JDH,&yh,&mh,&dh);
	   JD=HCalendarToJDA(yh,mh,dh);
	   qDebug()<<"\n";
   }
   	   qDebug()<<"\n\n";
*/


 for(i=0;i<12;i++) lst[i]=0;

	if(daily_monthly == 2)
		monthlyPrayer(latud, daylight, user_month, startDay_daylight, startMonth_daylight, endDay_daylight, endMonth_daylight, lst, param, Zonh, dg0, mg0, yg0, dhuhrInterval, maghribInterval, hour_format);
	else
		dailyPrayer(latud, daylight, user_month, startDay_daylight, startMonth_daylight, endDay_daylight, endMonth_daylight, lst, param, Zonh, dg0, mg0, yg0, dhuhrInterval, maghribInterval, hour_format);


}

void dailyPrayer(double latud, int daylight, int user_month, int startDay_daylight, int startMonth_daylight, int endDay_daylight, int endMonth_daylight, double lst[], double param[], double Zonh, int dg0, int mg0, int yg0, double dhuhrInterval, double maghribInterval, int hour_format)
{
   int yh1,mh1,dh1,dayweek,i;

	   if (daylight == 1){ //if daylight savings is yes then check the daylight savings in the given dates.
		   param[5] = Zonh + daylightSavings(latud, dg0, user_month, startDay_daylight, startMonth_daylight, endDay_daylight, endMonth_daylight);
		   // add one hours for daylight savings in the timezone
	   } else param[5] = Zonh;

	   GDateAjust(&yg0,&mg0,&dg0);

	  G2HA(yg0,mg0,dg0,&yh1,&mh1,&dh1,&dayweek);
	  qDebug() << yh1 << mh1 << dh1;
	  qDebug() << ",";

	   qDebug() << yg0<<"-"<<mg0<<"-"<<dg0;


	   OmAlQrahr(yg0,mg0,dg0,param,lst);
      /*-------------------------------------*/
	    //dataout<<"\n"<<",";
	   qDebug() << ",";
	    for(i=1;i<=6;i++)
	    {
	     //Writime(dataout,lst[i]);
		 Writime(lst[i], i, dhuhrInterval, maghribInterval, hour_format);
	     //dataout<<",";
		 if(i<6)
		     qDebug() << ",";
	    }

	    qDebug() << "\n";
}

void monthlyPrayer(double latud, int daylight, int user_month, int startDay_daylight, int startMonth_daylight, int endDay_daylight, int endMonth_daylight, double lst[], double param[], double Zonh, int dg0, int mg0, int yg0, double dhuhrInterval, double maghribInterval, int hour_format)
{
   int yh1,mh1,dh1,dayweek,i,day,nd;

   	   if((mg0==1)||(mg0==3) || (mg0==5) ||(mg0==7)||(mg0==8)||(mg0==10)||(mg0==12))
           nd=31;
       else if((mg0==4)||(mg0==6)||(mg0==9)||(mg0==11))
           nd=30;
       else if(mg0==2) {
              if(yg0%4==0)
                nd=29;
              else
                  nd=28;
           }



	   dg0 = 0; //start to show the prayer times from first day of the month
	for(day=1;day<=nd;day++)
	{
		dg0++;

	   if (daylight == 1){ //if daylight savings is yes then check the daylight savings in the given dates.
		   param[5] = Zonh + daylightSavings(latud, dg0, user_month, startDay_daylight, startMonth_daylight, endDay_daylight, endMonth_daylight);
		   // add one hours for daylight savings in the timezone
	   } else param[5] = Zonh;


	   GDateAjust(&yg0,&mg0,&dg0);

	  G2HA(yg0,mg0,dg0,&yh1,&mh1,&dh1,&dayweek);
	  qDebug() << yh1 << mh1 << dh1;
	  qDebug() << ",";

	   qDebug()<<yg0<<"-"<<mg0<<"-"<<dg0;


	   OmAlQrahr(yg0,mg0,dg0,param,lst);
      /*-------------------------------------*/
	    //dataout<<"\n"<<",";
		qDebug()<<",";
	    for(i=1;i<=6;i++)
	    {
	     //Writime(dataout,lst[i]);
		 Writime(lst[i], i, dhuhrInterval, maghribInterval, hour_format);
	     //dataout<<",";
		 if(i<6)
		 qDebug() << ",";
	    }

		qDebug() << "\n";
	}

}

//void Writime(ofstream &dataout, double h)
void Writime(double h, int prayerName, int dhuhrInterval, int maghribInterval, int hour_format)
{
    int hour,min;
	int sec;

	     hour=h;
	     min= 60*double(h- hour);

	     sec= 3600.0*double(h-hour-min/60.0);

		 if(sec>30) min=min+1; //go to next minute if secinds are more than 30.

	     if(sec==60)  { min++; sec = 0;}
	     if(sec<0) sec= -sec;

	     if(min<0)
			min= -min;

	     if(hour<0)
			hour= -hour;

		if(prayerName == 3 && dhuhrInterval > 1){ //prayerName=3 means dhuhr. By default dhuhrInterval is 1.
			min = min + dhuhrInterval - 1; //-1 means substract the default 1 first.
		}

		if(prayerName == 5 && maghribInterval > 1){ //prayerName=5 means maghrib. By default maghribInterval is 1.
			min = min + maghribInterval - 1; //-1 means substract the default 1 first.
		}

			for(;min>59;){ //Adjust the minutes. Minutes must be less than 60.
				min = min-60;
				hour++;
			}

			for(;hour>23;){ //Adjust the hours. Hours must be less than 24.
				hour=hour-24;
			}

		if(hour_format == 12){
		if(hour > 12)
		hour = hour-12;
		}

		qDebug() << hour;
		qDebug() << ":";

		if(min<10)   //show zero with minutes if less than 10.
		qDebug() << '0';

		qDebug() << min;

}


int daylightSavings(double latud, int user_day, int user_month, int startDay_daylight, int startMonth_daylight, int endDay_daylight, int endMonth_daylight)
{
 int daylight = 0;
/*
1- If latitude is positive then daylight may be between March and October for upper hemisphere. If latitude negative then daylight may be between September and March.
*/


	if(user_month == startMonth_daylight){ // if strating month is daylight savings month
		if(user_day >= startDay_daylight)
			daylight = 1;
	} else if(user_month == endMonth_daylight){ //if ending month is daylight savings month
		if(user_day < endDay_daylight)
			daylight = 1;
		} else { //if complete months are daylight savings months but not start and end months.
				if(latud >= 0){ // if latitude is positive means upper hemisphere
					if(user_month > startMonth_daylight && user_month < endMonth_daylight)
						daylight = 1;
					else
						daylight = 0;

				} else { //if  latitude is negative means lower hemisphere
						if(user_month > startMonth_daylight) // from starting month to december
							daylight=1;
						else if(user_month < endMonth_daylight) // from january to ending month
							daylight = 1;
						else
							daylight = 0;

					}// end of second else

			}// end of first else

 return daylight;

}

//////////// Hijrah.cpp



/****************************************************************************/
/* Name:    BH2GA                                                            */
/* Type:    Procedure                                                       */
/* Purpose: Finds Gdate(year,month,day) for Hdate(year,month,day=1)  	    */
/* Arguments:                                                               */
/* Input: Hijrah  date: year:yh, month:mh                                   */
/* Output: Gregorian date: year:yg, month:mg, day:dg , day of week:dayweek  */
/*       and returns flag found:1 not found:0                               */
/****************************************************************************/
int  BH2GA(int yh,int mh,int *yg,int *mg, int *dg,int *dayweek)
{

  int flag;
  long JD;
  double GJD;
   /* Make sure that the date is within the range of the tables */
  if(mh<1) {mh=12;}
  if(mh>12) {mh=1;}
  if(yh<HStartYear) {yh=HStartYear;}
  if(yh>HEndYear)   {yh=HEndYear;}

   GJD=HCalendarToJDA(yh,mh,1);
   JDToGCalendar(GJD,yg,mg,dg);
   JD=GJD;
   *dayweek=(JD+1)%7;
   flag=1; /* date has been found */


 return flag;

}
/****************************************************************************/
/* Name:    HCalendarToJDA						    */
/* Type:    Function                                                        */
/* Purpose: convert Hdate(year,month,day) to Exact Julian Day     	    */
/* Arguments:                                                               */
/* Input : Hijrah  date: year:yh, month:mh, day:dh                          */
/* Output:  The Exact Julian Day: JD                                        */
/****************************************************************************/
double HCalendarToJDA(int yh,int mh,int dh)
{
  int flag,Dy,m,b;
  long JD;
  double GJD;

   JD=HCalendarToJD(yh,1,1);  /* estimate JD of the begining of the year */
   Dy=MonthMap[yh-HStartYear]/4096;  /* Mask 1111000000000000 */
   GJD=JD-3+Dy;   /* correct the JD value from stored tables  */
   b=MonthMap[yh-HStartYear];
   b=b-Dy*4096;
   for(m=1;m<mh;m++)
   {
    flag=b%2;  /* Mask for the current month */
    if(flag) Dy=30; else Dy=29;
    GJD=GJD+Dy;   /* Add the months lengths before mh */
    b=(b-flag)/2;
   }
   GJD=GJD+dh-1;

   return GJD;
}
/****************************************************************************/
/* Name:    HMonthLength						    */
/* Type:    Function                                                        */
/* Purpose: Obtains the month length            		     	    */
/* Arguments:                                                               */
/* Input : Hijrah  date: year:yh, month:mh                                  */
/* Output:  Month Length                                                    */
/****************************************************************************/
int HMonthLength(int yh,int mh)
{
  int flag,Dy,m,b;

  if(yh<HStartYear || yh>HEndYear)
  {
   flag=0;
   Dy=0;
  }
 else
  {
   Dy=MonthMap[yh-HStartYear]/4096;  /* Mask 1111000000000000 */
   b=MonthMap[yh-HStartYear];
   b=b-Dy*4096;
    for(m=1;m<=mh;m++)
     {
      flag=b%2;  /* Mask for the current month */
      if(flag) Dy=30; else Dy=29;
      b=(b-flag)/2;
     }
   }
   return Dy;
}

/****************************************************************************/
/* Name:    DayInYear							    */
/* Type:    Function                                                        */
/* Purpose: Obtains the day number in the yea          		     	    */
/* Arguments:                                                               */
/* Input : Hijrah  date: year:yh, month:mh  day:dh                          */
/* Output:  Day number in the Year					    */
/****************************************************************************/
int DayinYear(int yh,int mh,int dh)
{
  int flag,Dy,m,b,DL;

  if(yh<HStartYear || yh>HEndYear)
  {
   flag=0;
   DL=0;
  }
 else
  {
   Dy=MonthMap[yh-HStartYear]/4096;  /* Mask 1111000000000000 */
   b=MonthMap[yh-HStartYear];
   b=b-Dy*4096;
   DL=0;
    for(m=1;m<=mh;m++)
     {
      flag=b%2;  /* Mask for the current month */
      if(flag) Dy=30; else Dy=29;
      b=(b-flag)/2;
      DL=DL+Dy;
     }
   DL=DL+dh;
   }

   return DL;
}

/****************************************************************************/
/* Name:    HYearLength						    	    */
/* Type:    Function                                                        */
/* Purpose: Obtains the year length            		     	    	    */
/* Arguments:                                                               */
/* Input : Hijrah  date: year:yh                                  	    */
/* Output:  Year Length                                                     */
/****************************************************************************/
int HYearLength(int yh)
{
  int flag,Dy,m,b,YL;

  if(yh<HStartYear || yh>HEndYear)
  {
   flag=0;
   YL=0;
  }
 else
  {
   Dy=MonthMap[yh-HStartYear]/4096;  /* Mask 1111000000000000 */
   b=MonthMap[yh-HStartYear];
   b=b-Dy*4096;
   flag=b%2;  /* Mask for the current month */
   if(flag) YL=30; else YL=29;
    for(m=2;m<=12;m++)
     {
      flag=b%2;  /* Mask for the current month */
      if(flag) Dy=30; else Dy=29;
      b=(b-flag)/2;
      YL=YL+Dy;
     }
   }

   return YL;
}

/****************************************************************************/
/* Name:    G2HA                                                            */
/* Type:    Procedure                                                       */
/* Purpose: convert Gdate(year,month,day) to Hdate(year,month,day)          */
/* Arguments:                                                               */
/* Input: Gregorian date: year:yg, month:mg, day:dg                         */
/* Output: Hijrah  date: year:yh, month:mh, day:dh, day of week:dayweek     */
/*       and returns flag found:1 not found:0                               */
/****************************************************************************/
void  G2HA(int yg,int mg, int dg,int *yh,int *mh,int *dh,int *dayweek)
{
   int  yh1,mh1,dh1;
   int  yh2,mh2;
   int  yg1,mg1,dg1;
   int  df,dw2;
  //int flag;
  long J;
  double GJD,HJD;

    GJD=GCalendarToJD(yg,mg,dg+0.5);  /* find JD of Gdate */
    JDToHCalendar(GJD,&yh1,&mh1,&dh1);  /* estimate the Hdate that correspond to the Gdate */
    HJD=HCalendarToJDA(yh1,mh1,dh1);   // get the exact Julian Day
    df=GJD-HJD;
    dh1=dh1+df;
    while(dh1>30)
    {
     dh1=dh1-HMonthLength(yh1,mh1);
     mh1++;
     if(mh1>12) {yh1++;mh1=1;}
    }
   if(dh1==30)
   {
    mh2=mh1+1;
    yh2=yh1;
    if(mh2>12) {mh2=1;yh2++;}
    BH2GA(yh2,mh2,&yg1,&mg1,&dg1,&dw2);
    if(dg==dg1) {yh1=yh2;mh1=mh2;dh1=1;}  /* Make sure that the month is 30days if not make adjustment */
   }
   J=(GCalendarToJD(yg,mg,dg)+2);
   *dayweek=J%7;
   *yh=yh1;
   *mh=mh1;
   *dh=dh1;


  //return flag;



}
/****************************************************************************/
/* Name:    H2GA                                                            */
/* Type:    Procedure                                                       */
/* Purpose: convert Hdate(year,month,day) to Gdate(year,month,day)          */
/* Arguments:                                                               */
/* Input/Ouput: Hijrah  date: year:yh, month:mh, day:dh                     */
/* Output: Gregorian date: year:yg, month:mg, day:dg , day of week:dayweek  */
/*       and returns flag found:1 not found:0                               */
/* Note: The function will correct Hdate if day=30 and the month is 29 only */
/****************************************************************************/
int  H2GA(int *yh,int *mh,int *dh, int *yg,int *mg, int *dg,int *dayweek)
{
    int found,yh1,mh1,yg1,mg1,dg1,dw1;

    /* make sure values are within the allowed values */
    if(*dh>30) {*dh=1;(*mh)++;}
    if(*dh<1)  {*dh=1;(*mh)--;}
    if(*mh>12) {*mh=1;(*yh)++;}
    if(*mh<1)  {*mh=12;(*yh)--;}

	 /*find the date of the begining of the month*/
    found=BH2GA(*yh,*mh,yg,mg,dg,dayweek);
    *dg=*dg+*dh-1;
    GDateAjust(yg,mg,dg);    /* Make sure that dates are within the correct values */
    *dayweek=*dayweek+*dh-1;
    *dayweek=*dayweek%7;

	 /*find the date of the begining of the next month*/
   if(*dh==30)
   {
    mh1=*mh+1;
    yh1=*yh;
    if(mh1>12) {mh1=mh1-12;yh1++;}
    found=BH2GA(yh1,mh1,&yg1,&mg1,&dg1,&dw1);
    if(*dg==dg1) {*yh=yh1;*mh=mh1;*dh=1;}  /* Make sure that the month is 30days if not make adjustment */
   }

   return found;
}
/****************************************************************************/
/* Name:    JDToGCalendar						    */
/* Type:    Procedure                                                       */
/* Purpose: convert Julian Day  to Gdate(year,month,day)                    */
/* Arguments:                                                               */
/* Input:  The Julian Day: JD                                               */
/* Output: Gregorian date: year:yy, month:mm, day:dd                        */
/****************************************************************************/
double JDToGCalendar(double JD, int *yy,int *mm, int *dd)
{
double A, B, F;
int alpha, C, E;
long D, Z;

  Z = (long)floor (JD + 0.5);
  F = (JD + 0.5) - Z;
  alpha = (int)((Z - 1867216.25) / 36524.25);
  A = Z + 1 + alpha - alpha / 4;
  B = A + 1524;
  C = (int) ((B - 122.1) / 365.25);
  D = (long) (365.25 * C);
  E = (int) ((B - D) / 30.6001);
  *dd = B - D - floor (30.6001 * E) + F;
  if (E < 14)
    *mm = E - 1;
  else
    *mm = E - 13;
  if (*mm > 2)
    *yy = C - 4716;
  else
   *yy = C - 4715;

  F=F*24.0;
  return F;
}
/****************************************************************************/
/* Name:    GCalendarToJD						    */
/* Type:    Function                                                        */
/* Purpose: convert Gdate(year,month,day) to Julian Day            	    */
/* Arguments:                                                               */
/* Input : Gregorian date: year:yy, month:mm, day:dd                        */
/* Output:  The Julian Day: JD                                              */
/****************************************************************************/
double GCalendarToJD(int yy,int mm, double dd)
{        /* it does not take care of 1582correction assumes correct calender from the past  */
int A, B, m, y;
double T1,T2,Tr;
  if (mm > 2) {
    y = yy;
    m = mm;
    }
  else {
    y = yy - 1;
    m = mm + 12;
    }
  A = y / 100;
  B = 2 - A + A / 4;
  T1=ip (365.25 * (y + 4716));
  T2=ip (30.6001 * (m + 1));
  Tr=T1+ T2 + dd + B - 1524.5 ;

  return Tr;
}
/****************************************************************************/
/* Name:    GLeapYear						            */
/* Type:    Function                                                        */
/* Purpose: Determines if  Gdate(year) is leap or not            	    */
/* Arguments:                                                               */
/* Input : Gregorian date: year				                    */
/* Output:  0:year not leap   1:year is leap                                */
/****************************************************************************/
int GLeapYear(int year)
{

  int T;

     T=0;
     if(year%4==0) T=1; /* leap_year=1; */
     if(year%100==0)
       {
	 T=0;        /* years=100,200,300,500,... are not leap years */
	 if(year%400==0) T=1;  /*  years=400,800,1200,1600,2000,2400 are leap years */
       }

  return T;

}
/****************************************************************************/
/* Name:    GDateAjust							    */
/* Type:    Procedure                                                       */
/* Purpose: Adjust the G Dates by making sure that the month lengths        */
/*	    are correct if not so take the extra days to next month or year */
/* Arguments:                                                               */
/* Input: Gregorian date: year:yg, month:mg, day:dg                         */
/* Output: corrected Gregorian date: year:yg, month:mg, day:dg              */
/****************************************************************************/
void GDateAjust(int *yg,int *mg,int *dg)
{
   int dys;

   /* Make sure that dates are within the correct values */
	  /*  Underflow  */
	 if(*mg<1)  /* months underflow */
	  {
	   *mg=12+*mg;  /* plus as the underflow months is negative */
	   *yg=*yg-1;
	  }

	 if(*dg<1)  /* days underflow */
	  {
	   *mg= *mg-1;  /* month becomes the previous month */
	   *dg=gmonth[*mg]+*dg; /* number of days of the month less the underflow days (it is plus as the sign of the day is negative) */
	   if(*mg==2) *dg=*dg+GLeapYear(*yg);
	   if(*mg<1)  /* months underflow */
	    {
	     *mg=12+*mg;  /* plus as the underflow months is negative */
	     *yg=*yg-1;
	    }
	  }

	  /* Overflow  */
	 if(*mg>12)  /* months */
	  {
	   *mg=*mg-12;
	   *yg=*yg+1;
	  }

	 if(*mg==2)
	     dys=gmonth[*mg]+GLeapYear(*yg);  /* number of days in the current month */
	   else
	     dys=gmonth[*mg];
	 if(*dg>dys)  /* days overflow */
	  {
	     *dg=*dg-dys;
	     *mg=*mg+1;
	    if(*mg==2)
	     {
	      dys=gmonth[*mg]+GLeapYear(*yg);  /* number of days in the current month */
	      if(*dg>dys)
	       {
		*dg=*dg-dys;
		*mg=*mg+1;
	       }
	     }
	    if(*mg>12)  /* months */
	    {
	     *mg=*mg-12;
	     *yg=*yg+1;
	    }

	  }


}
/*
  The day of the week is obtained as
  Dy=(Julian+1)%7
  Dy=0 Sunday
  Dy=1 Monday
  ...
  Dy=6 Saturday
*/

int DayWeek(long JulianD)
{
  int Dy;
  Dy=(JulianD+1)%7;

  return Dy;
}

/****************************************************************************/
/* Name:    HCalendarToJD						    */
/* Type:    Function                                                        */
/* Purpose: convert Hdate(year,month,day) to estimated Julian Day     	    */
/* Arguments:                                                               */
/* Input : Hijrah  date: year:yh, month:mh, day:dh                          */
/* Output:  The Estimated Julian Day: JD                                    */
/****************************************************************************/
double HCalendarToJD(int yh,int mh,int dh)
{
 /*
   Estimating The JD for hijrah dates
   this is an approximate JD for the given hijrah date
 */
 double md,yd;
 md=(mh-1.0)*29.530589;
 yd=(yh-1.0)*354.367068+md+dh-1.0;
 yd=yd+1948439.0;  /*  add JD for 18/7/622 first Hijrah date */

 return yd;
}
/****************************************************************************/
/* Name:    JDToHCalendar						    */
/* Type:    Procedure                                                       */
/* Purpose: convert Julian Day to estimated Hdate(year,month,day)	    */
/* Arguments:                                                               */
/* Input:  The Julian Day: JD                                               */
/* Output : Hijrah date: year:yh, month:mh, day:dh                          */
/****************************************************************************/
void JDToHCalendar(double JD,int *yh,int *mh,int *dh)
{
 /*
   Estimating the hijrah date from JD
 */
 double md,yd;

 yd=JD-1948439.0;  /*  subtract JD for 18/7/622 first Hijrah date*/
 md=mod(yd,354.367068);
 *dh=mod(md+0.5,29.530589)+1;
 *mh=(md/29.530589)+1;
 yd=yd-md;
 *yh=yd/354.367068+1;
 if(*dh>30) {*dh=*dh-30;(*mh)++;}
 if(*mh>12) {*mh=*mh-12;(*yh)++;}

}
/****************************************************************************/
/* Name:    JDToHACalendar						    */
/* Type:    Procedure                                                       */
/* Purpose: convert Julian Day to  Hdate(year,month,day)	    	     */
/* Arguments:                                                               */
/* Input:  The Julian Day: JD                                               */
/* Output : Hijrah date: year:yh, month:mh, day:dh                          */
/****************************************************************************/
void JDToHACalendar(double JD,int *yh,int *mh,int *dh)
{
   int  yh1,mh1,dh1;

   int  df;

  double HJD;


    JDToHCalendar(JD,&yh1,&mh1,&dh1);  /* estimate the Hdate that correspond to the Gdate */
    HJD=HCalendarToJDA(yh1,mh1,dh1);   // get the exact Julian Day
    df=JD+0.5-HJD;
    dh1=dh1+df;
    while(dh1>30)
    {
     dh1=dh1-HMonthLength(yh1,mh1);
     mh1++;
     if(mh1>12) {yh1++;mh1=1;}
    }
   if(dh1==30 && HMonthLength(yh1,mh1)<30)
   {
    dh1=1;mh1++;
   }
   if(mh1>12)
   {
    mh1=1;yh1++;
   }

//   J=JD+2;  *dayweek=J%7;
   *yh=yh1;
   *mh=mh1;
   *dh=dh1;

}

/**************************************************************************/
double ip(double x)
{ /* Purpose: return the integral part of a double value.     */
double  tmp;

   modf(x, &tmp);
  return tmp;
}
/**************************************************************************/
/*
  Name: mod
  Purpose: The mod operation for doubles  x mod y
*/
int mod(double x, double y)
{
  int r;
  double d;

  d=x/y;
  r=d;
  if(r<0) r--;
  d=x-y*r;
  r=d;
 return r;
}

/**************************************************************************/
int IsValid(int yh, int mh, int dh)
{ /* Purpose: returns 0 for incorrect Hijri date and 1 for correct date      */
  int valid;
  valid=1;
  if(yh<HStartYear ||   yh>HEndYear)     valid=0;
  if(mh<1 || mh>12 || dh<1)
      valid=0;
   else
     if(dh>HMonthLength(yh,mh))   valid=0;

  return valid;
}
/**************************************************************************/




////////////// Alqrah.cpp



/*=====================================================================*/
/*             Computation for the Sun                                 */
/*=====================================================================*/
double atanxy(double x,double y)
{
     double argm;

     if(x==0)  argm=0.5*pi; else argm=atan(y/x);

     if(x>0 && y<0) argm=2.0*pi+argm;
     if(x<0) argm=pi+argm;

     return argm;
}
void EclipToEquator(double lmdr,double betar,double &alph, double &dltr)
{
 /*

   Convert Ecliptic to Equatorial Coordinate
   p.40 No.27, Peter Duffett-Smith book
   input: lmdr,betar  in radians
   output: alph,dltr in radians
 */

 double eps=23.441884;  // (in degrees) this changes with time
 double sdlt,epsr;
 double x,y;
 double rad=0.017453292;  // =pi/180.0

 epsr=eps*rad;  // convert to radians
 sdlt=sin(betar)*cos(epsr)+cos(betar)*sin(epsr)*sin(lmdr);
 dltr=asin(sdlt);
 y=sin(lmdr)*cos(epsr)-tan(betar)*sin(epsr);
 x=cos(lmdr);
 alph=atanxy(x,y);

}

double RoutinR2(double M,double e)
{
   /*
    Routine R2:
    Calculate the value of E
    p.91, Peter Duffett-Smith book
  */
  double dt=1,dE,Ec;
  Ec=M;
  while(fabs(dt)>1e-9)
  {
    dt=Ec-e*sin(Ec)-M;
    dE=dt/(1-e*cos(Ec));
    Ec=Ec-dE;
  }
 return Ec;
}

double SunParamr(int yg,int mg, int dg,double ObsLon,double ObsLat, double TimeZone,
		double *Rise,double *Transit,double *Setting,double *RA,double *Decl,int *RiseSetFlags)
{
  /*
    p.99 of the Peter Duffett-Smith book

  */

  double UT,ET,y,L,e,M;
  double T,JD,Ec;
  double tnv,v,tht;
  double K,angl,T1,T2,H,cH;
  *RiseSetFlags=0;

  JD=GCalendarToJD(yg,mg,dg);
  T=(JD+ TimeZone/24.0 - 2451545.0) / 36525.0;

  L=279.6966778+36000.76892*T+0.0003025*T*T;  // in degrees
  while(L>360) L=L-360;
  while(L<0) L=L+360;
  L=L*pi/180.0;  // radians

  M=358.47583+35999.04975*T-0.00015*T*T-0.0000033*T*T*T;
  while(M>360) M=M-360;
  while(M<0) M=M+360;
  M=M*pi/180.0;

  e=0.01675104-0.0000418*T-0.000000126*T*T;
  Ec=23.452294-0.0130125*T-0.00000164*T*T+0.000000503*T*T*T;
  Ec=Ec*pi/180.0;

  y=tan(0.5*Ec);
  y=y*y;
  ET=y*sin(2*L)-2*e*sin(M)+4*e*y*sin(M)*cos(2*L)-0.5*y*y*sin(4*L)-5*0.25*e*e*sin(2*M);
  UT=ET*180.0/(15.0*pi);   // from radians to hours

  Ec=RoutinR2(M,e);
  tnv=sqrt((1+e)/(1-e))*tan(0.5*Ec);
  v=2.0*atan(tnv);
  tht=L+v-M;
  EclipToEquator(tht,0,*RA,*Decl);

  K=12-UT-TimeZone+ObsLon*12.0/pi;  // (Noon)
  *Transit=K;
      /*  Sunrise and Sunset*/

   angl=(-0.833333)*DToR;  // Meeus p.98
   T1=(sin(angl)-sin(*Decl)*sin(ObsLat));
   T2=(cos(*Decl)*cos(ObsLat));  // p.38  Hour angle for the Sun
   cH=T1/T2;
   if(cH>1)  {*RiseSetFlags=16;cH=1;}  /*At this day and place the sun does not rise or set  */
   H=acos(cH);
   H=H*12.0/pi;
   *Rise=K-H; 	       // Sunrise
   *Setting=K+H; // SunSet

   return JD;
}

/*
  For international prayer times see Islamic Fiqah Council of the Muslim
  World League:  Saturday 12 Rajeb 1406H, concerning prayer times and fasting
  times for countries of high latitudes.
  This program is based on the above.
*/
/*****************************************************************************/
/* Name:    OmAlQrah                                                         */
/* Type:    Procedure                                                        */
/* Purpose: Compute prayer times and sunrise                                 */
/* Arguments:                                                                */
/*   yg,mg,dg : Date in Greg                                                 */
/*   param[0]: Safety time  in hours should be 0.016383h                     */
/*   longtud,latud: param[1],[2] : The place longtude and latitude in radians*/
/*   HeightdifW : param[3]: The place western herizon height difference in meters */
/*   HeightdifE : param[4]: The place eastern herizon height difference in meters */
/*   Zonh :param[5]: The place zone time dif. from GMT  West neg and East pos*/
/*          in decimal hours                                                 */
/*  fjrangl: param[6]: The angle (radian) used to compute                    */
/*            Fajer prayer time (OmAlqrah  -19 deg.)                         */
/*  ashangl: param[7]: The angle (radian) used to compute Isha  prayer time  */
/*          ashangl=0 then use  (OmAlqrah: ash=SunSet+1.5h)                  */
/*  asr  : param[8]: The Henfy (asr=2) Shafi (asr=1, Omalqrah asr=1)         */
/*  param[9]: latude (radian) that should be used for places above -+65.5    */
/*            should be 45deg as suggested by Rabita                         */
/*   param[10]: The Isha fixed time from Sunset                              */
/*  Output:                                                                  */
/*  lst[]: lst[n], 1:Fajer 2:Sunrise 3:Zohar 4:Aser  5:Magreb  6:Ishe        */
/*                 7:Fajer using exact Rabita method for places >48          */
/*                 8:Ash   using exact Rabita method for places >48          */
/*                 9: Eid Prayer Time                                        */
/*          for places above 48 lst[1] and lst[6] use a modified version of  */
/*          Rabita method that tries to eliminate the discontinuity          */
/*         all in 24 decimal hours                                           */
/*         returns flag:0 if there are problems, flag:1 no problems          */
/*****************************************************************************/
int OmAlQrahr(int yg,int mg,int dg, double param[], double lst[])
{
    int flag=1,flagrs,problm=0;
    double RA,Decl;
    double Rise,Transit,Setting;
    double SINd,COSd;
    double act,H,angl,K,cH;
    double X,MaxLat;
    double H0,Night,IshRt,FajrRt;
    double HightCorWest=0,HightCorEast=0;
    double IshFix,FajrFix;
  /*
    Main Local variables:
    RA= Sun's right ascension
    Decl= Sun's declination
    H= Hour Angle for the Sun
    K= Noon time
    angl= The Sun altitude for the required time
    flagrs: sunrise sunset flags
	    0:no problem
	    16: Sun always above horizon (at the ploes for some days in the year)
	    32: Sun always below horizon
  */

       /* Compute the Sun various Parameters */
  SunParamr(yg,mg,dg,-param[1],param[2],-param[5],
		&Rise,&Transit,&Setting,&RA,&Decl,&flagrs);

    /* Compute General Values */
  SINd=sin(Decl)*sin(param[2]);
  COSd=cos(Decl)*cos(param[2]);

   /* Noon */
   K=Transit;

    /* Compute the height correction  */
    HightCorWest=0;HightCorEast=0;
   if(flagrs==0 && fabs(param[2])<0.79 && (param[4]!=0 || param[3]!=0))
   {   /* height correction not used for problematic places above 45deg*/
    H0=H=0;
    angl=-0.83333*DToR;  /* standard value  angl=50min=0.8333deg
				    for sunset and sunrise */
    cH=(sin(angl)-SINd)/(COSd);
    H0=acos(cH);

    X=EarthRadius*1000.0;  /* meters  */
    angl=-0.83333*DToR+(0.5*pi-asin(X/(X+param[3])));  /*  */
    cH=(sin(angl)-SINd)/(COSd);
    HightCorWest=acos(cH);
    HightCorWest=(H0-HightCorWest)*(RToH);

    angl=-0.83333*DToR+(0.5*pi-asin(X/(X+param[4])));
    cH=(sin(angl)-SINd)/(COSd);

    HightCorEast=acos(cH);
    HightCorEast=(H0-HightCorEast)*(RToH);
   }


      /* Modify Sunrise,Sunset and Transit for problematic places*/
  if(!(flagrs==0 && fabs(Setting-Rise)>1 && fabs(Setting-Rise)<23))
   {  /* There are problems in computing sun(rise,set)  */
     /* This is because of places above -+65.5 at some days of the year */
     /* Note param[9] should be  45deg as suggested by Rabita  */
     problm=1;
     if(param[2]<0) MaxLat= -fabs(param[9]); else MaxLat= fabs(param[9]);
      /* Recompute the Sun various Parameters using the reference param[9] */
     SunParamr(yg,mg,dg,-param[1],MaxLat,-param[5],
		&Rise,&Transit,&Setting,&RA,&Decl,&flagrs);
     K=Transit;  /* exact noon time */

      /* ReCompute General Values for the new reference param[9]*/
     SINd=sin(Decl)*sin(MaxLat);
     COSd=cos(Decl)*cos(MaxLat);
   }
   /*-------------------------------------------------------------*/
   if(K<0) K=K+24;

   lst[2]=Rise-HightCorEast;   /* Sunrise - Height correction */
   lst[3]=K+param[0];   /* Zohar time+extra time to make sure that the sun has moved from zaowal */
   lst[5]=Setting+HightCorWest+param[0]; /* Magrib= SunSet + Height correction + Safety Time */


    /*-------------------------------------------------------------*/
      /* Asr time: Henfy param[8]=2, Shafi param[8]=1, OmAlqrah asr=1  */
   if(problm) /* For places above 65deg */
       act=param[8]+tan(fabs(Decl-MaxLat));
     else /* no problem */
       act=param[8]+tan(fabs(Decl-param[2]));  /*In the standard
					    equations abs() is not used,
					    but it is required for -ve latitude  */
   angl=atan(1.0/act);
   cH=(sin(angl)-SINd)/(COSd);
   if(fabs(cH)>1.0)
   {
    H=3.5;
    flag=0; /* problem in compuing Asr */
   }
  else
   {
    H=acos(cH);
    H=H*RToH;
   }
   lst[4]=K+H+param[0];  /*  Asr Time */

    /*-------------------------------------------------------------*/
   /* Fajr Time  */
   angl=-param[6]; /* The value -19deg is used by OmAlqrah for Fajr,
			   but it is not correct,
			   Astronomical twilight and Rabita use -18deg */
  cH=(sin(angl)-SINd)/(COSd);
  if(fabs(param[2])<0.83776)    /*If latitude<48deg   */
  {     /* no problem */
     H=acos(cH);
     H=H*RToH;  /* convert radians to hours  */
     lst[1]=K-(H+HightCorEast)+param[0];    /* Fajr time  */
     lst[7]=lst[1];
  }
 else
  {  /* Get fixed ratio, data depends on latitutde sign*/
      if(param[2]<0)
	    GetRatior(yg,12,21,param,&IshFix,&FajrFix);
	 else
	   GetRatior(yg,6,21,param,&IshFix,&FajrFix);

   if(fabs(cH)>(0.45+1.3369*param[6]))   /* A linear equation I have interoduced  */
   {   /* The problem occurs for places above -+48 in the summer */
     Night=24-(Setting-Rise); /* Night Length  */
     lst[1]=Rise-Night*FajrFix;  /* According to the general ratio rule*/
   }
  else
   {  /* no problem */
     H=acos(cH);
     H=H*RToH;  /* convert radians to hours  */
     lst[1]=K-(H+HightCorEast)+param[0];    /* Fajr time  */
    }
   lst[7]=lst[1];
   if(fabs(cH)>1)
   {   /* The problem occurs for places above -+48 in the summer */
     GetRatior(yg,mg,dg,param,&IshRt,&FajrRt);
     Night=24-(Setting-Rise); /* Night Length  */
     lst[7]=Rise-Night*FajrRt; /*  Accoording to Rabita Method*/
   }
  else
   {  /* no problem */
     H=acos(cH);
     H=H*RToH;  /* convert radians to hours  */
     lst[7]=K-(H+HightCorEast)+param[0];    /* Fajr time  */
   }

  }

   /*-------------------------------------------------------------*/
    /*   Isha prayer time   */
   if(param[7]!=0)  /* if Ish angle  not equal zero*/
    {
       angl=-param[7];
       cH=(sin(angl)-SINd)/(COSd);
      if(fabs(param[2])<0.83776)    /*If latitude<48deg   */
      {     /* no problem */
	H=acos(cH);
	H=H*RToH;  /* convert radians to hours  */
	lst[6]=K+(H+HightCorWest+param[0]);    /* Isha time, instead of  Sunset+1.5h */
	lst[8]=lst[6];
      }
    else
     {
     if(fabs(cH)>(0.45+1.3369*param[6]))   /* A linear equation I have interoduced  */
	{   /* The problem occurs for places above -+48 in the summer */
	  Night=24-(Setting-Rise); /* Night Length  */
	  lst[6]=Setting+Night*IshFix; /*  Accoording to Rabita Method*/
	}
       else
       { /* no problem */
	H=acos(cH);
	H=H*RToH;  /* convert radians to hours  */
	lst[6]=K+(H+HightCorWest+param[0]);    /* Isha time, instead of  Sunset+1.5h */
       }

      if(fabs(cH)>1.0)
	{   /* The problem occurs for places above -+48 in the summer */
	  GetRatior(yg,mg,dg,param,&IshRt,&FajrRt);
	  Night=24-(Setting-Rise); /* Night Length  */
	  lst[8]=Setting+Night*IshRt;  /* According to the general ratio rule*/
	}
       else
       {
	H=acos(cH);
	H=H*RToH;  /* convert radians to hours  */
	lst[8]=K+(H+HightCorWest+param[0]);    /* Isha time, instead of  Sunset+1.5h */
       }

      }
     }
   else
    {
      lst[6]=lst[5]+param[10];  /* Isha time OmAlqrah standard Sunset+fixed time (1.5h or 2h in Romadan) */
      lst[8]=lst[6];
    }
 /*-------------------------------------------------------------*/
    /*   Eid prayer time   */
   angl=param[11]; /*  Eid Prayer time Angle is 4.2  */
  cH=(sin(angl)-SINd)/(COSd);
  if((fabs(param[2])<1.134 || flagrs==0) && fabs(cH)<=1.0)    /*If latitude<65deg   */
  {     /* no problem */
     H=acos(cH);
     H=H*RToH;  /* convert radians to hours  */
     lst[9]=K-(H+HightCorEast)+param[0];    /* Eid time  */
  }
 else
  {
    lst[9]=lst[2]+0.25;  /* If no Sunrise add 15 minutes */
  }
    return flag;

}

/*
  Function to obtain the ratio of the start time of Isha and Fajr at
  a referenced latitude (45deg suggested by Rabita) to the night length
*/
void GetRatior(int yg,int mg,int dg,double param[],double *IshRt,double *FajrRt)
{
    int flagrs;
    double RA,Decl;
    double Rise,Transit,Setting;
    double SINd,COSd;
    double H,angl,cH;
    double MaxLat;
    double FjrRf,IshRf;
    double Night;

     if(param[2]<0) MaxLat= -fabs(param[9]); else MaxLat= fabs(param[9]);
     SunParamr(yg,mg,dg,-param[1],MaxLat,-param[5],
		&Rise,&Transit,&Setting,&RA,&Decl,&flagrs);
     SINd=sin(Decl)*sin(MaxLat);
     COSd=cos(Decl)*cos(MaxLat);
     Night=24-(Setting-Rise);  /* Night Length */
     /* Fajr */
     angl=-param[6];
     cH=(sin(angl)-SINd)/(COSd);
     H=acos(cH);
     H=H*RToH;  /* convert radians to hours  */
     FjrRf=Transit-H-param[0];    /* Fajr time  */
    /* Isha */
   if(param[7]!=0)  /* if Ish angle  not equal zero*/
    {
       angl=-param[7];
       cH=(sin(angl)-SINd)/(COSd);
       H=acos(cH);
       H=H*RToH;  /* convert radians to hours  */
       IshRf=Transit+H+param[0];    /* Isha time, instead of  Sunset+1.5h */
     }
   else
    {
      IshRf=Setting+param[10];  /* Isha time OmAlqrah standard Sunset+1.5h */
    }
   *IshRt=(IshRf-Setting)/Night;  /* Isha time ratio */
   *FajrRt=(Rise-FjrRf)/Night;  /* Fajr time ratio */

   return;
}
