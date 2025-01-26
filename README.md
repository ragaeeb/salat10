# Background

The code behind the prayer time calculator of Salat10 was based on a port from a prayer time calculator code I wrote in Java. It was the engine that powered Carleton University MSA's [Maxillion Prayers](https://web.archive.org/web/20250126041731/https://groups.google.com/g/carletonmsa/c/33qwEZDyiuU) service which was eventually became a part of my 4th year Engineering Project where end-users could send a SMS to a specific number or email address and get the prayer times back.

Likewise we were able to push prayer times to them using an Email to SMS Gateway.

The app was an opt-in subscription service that Muslims in the university could subscribe to receiving prayer times at the set intervals (once at the beginning of the day, then reminders just before their times, or on demand as a reply to a SMS message). I reached out to the leading “prayer times” web app at the time: IslamicFinder, the developer was Muhammad Riaz who sent it to me in June 2009.

He shared the code snippet which was the engine behind the IslamicFinder website. The code was written by Ahmed Amin El Sheshtawy in 2006. The code was in C++ and was ported into Java and in that process a significant effort was made to comprehend the math, and use the original mathematical calculations to arrive at the values instead of their decimal approximations that were constants. Some work was done to also make the solution more Object-oriented instead of a hacky computer science task. Once completed the site was integrated into the Maxillion Framework for the 4th year engineering project.

Then there was an attempt to bring some of the features of the service to a mobile platform. The most popular prayer time app in BlackBerry App World was `SalatMK`. I reached out to the developer makteri in Jul, 2010 after open sourcing my solution in sourceforge, and hoping he integrated our half-night and last third-night solution into his app along with some other features. However due to the lack of a satisfactory momentum on these features I decided to build out the solution myself.

# Acknowledgements

Once BlackBerry 10 came out I developed Salat10 from scratch with a beautiful design that was designed by my close friend and brother Suhaib, may Allah reward him for all he has done on the app.

We also reached out to an astronomer by the name of Gary Boyle to consult regarding the accuracy of certain prayer times like Fajr based on the nautical twilight to understand the math more.

# Other Links

https://web.archive.org/web/20160531034840/https://code.google.com/archive/p/salat10/
https://www.youtube.com/@IncCanada/videos
