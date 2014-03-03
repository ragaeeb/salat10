#include "SolarCalculator.h"

#include <math.h>
#include <QDate>

namespace {

using namespace salat;

const qreal total_hours_in_day = 24;

/** The solar elevation angle. */
const qreal sunrise_arc_angle = SolarCalculator::degreesToRadians(-5.0/6.0);

/** The maximum CH value. */
const qreal max_ch_value = 1;


/**
 * Gets the maximum latitude to use for the specified geographical region.
 * @param g The geographical region to get the maximum latitude value for.
 * @return The maximum latitude to use for the specified geographical region (in radians).
 */
qreal getMaxLatitudeValue(qreal latitude)
{
    qreal rabitaReferenceAngle = SolarCalculator::degreesToRadians(45); // The reference angle as suggested by Rabita.
	qreal maxLatitude = abs(rabitaReferenceAngle); // There are problems in computing sun(rise,set)

	if (latitude < 0) { // This is because of places above -+65.5 at some days of the year
		maxLatitude = -maxLatitude;
	}

	return maxLatitude;
}


/**
 * Calculates the number of centuries since the year 2000. [3]<br><br>
 *
 * [3] Astronomical Applications Department, (2009). Approximate Sidereal Time. [Online].
 * Available: http://aa.usno.navy.mil/faq/docs/GAST.php) [June 21, 2009]<br>
 *
 * @param julianDate The Julian date of the previous midnight (Universal Time) (the value will
 * end in 0.5 exactly).
 * @param timeZone Hours of UT elapsed since the given Julian date.
 * @return The number of centuries that have occurred since the year 2000.
 */
qreal calculateCenturiesSince2000(qreal julianDate, qreal timeZone)
{
	qreal jdTimeOfInterest = julianDate + timeZone/total_hours_in_day;
	return (jdTimeOfInterest - 2451545.0) / 36525.0; // form time in Julian centuries from 1900.0
}


/**
 * Calculates the Julian Epoch value of the specified Gregorian calendar. This does not take
 * care of 1582 correction, assumes that the correct Gregorian calendar from the past is being
 * specified.<br><br>
 *
 * In astronomy, an epoch is a specific moment in time for which celestial coordinates or
 * orbital elements are specified, and from which other orbital parametrics are thereafter
 * calculated in order to predict future position. The applied tools of the mathematics
 * disciplines of Celestial mechanics or its subfield Orbital mechanics (both predict
 * orbital paths and positions) about a center of gravity are used to generate an
 * ephemeris (plural: ephemerides; from the Greek word ephemeros = daily) which is a
 * table of values that gives the positions of astronomical objects in the sky at a given
 * time or times, or a formula to calculate such given the proper time offset from the
 * epoch. Such calculations generally result in an elliptical path on a plane defined by
 * some point on the orbit, and the two focii of the ellipse. Viewing from another
 * orbiting body, following its own trace and orbit, creates shifts in three dimensions
 * in the spherical trigonometry used to calculate relative positions. Over time,
 * inexactitudes and other errors accumulate, creating more and greater errors of
 * prediction, so ephemeris factors need recalculated from time to time, and that
 * requires a new epoch to be defined. Different astronomers or groups of astronomers
 * used to define epochs to suit themselves, but these days of speedy communications, the
 * epochs are generally defined in an international agreement, so astronomers world wide
 * can collaborate more effectively. It was inefficient and error prone to translate data
 * observed by one group so other groups could compare information. An example of how
 * this works: if a star's position is measured by someone today, he/she then obtains the
 * change that occurred in the reference frame position since J2000 and corrects the
 * star's position appropriately, yielding the position of the star relative to the
 * reference frame of J2000. It is this J2000 position which is shared with others.<br><br>
 *
 * Therefore, the current epoch, defined by international agreement, is called J2000.0
 * and is precisely defined to be:<br>
 * 1. The Julian date 2451545.0 TT (Terrestrial Time), or January 1, 2000, noon TT.<br>
 * 2. This is equivalent to January 1, 2000, 11:59:27.816 TAI (International Atomic Time) or<br>
 * 3. January 1, 2000, 11:58:55.816 UTC (Coordinated Universal Time).<br><br>
 *
 * A Julian year, named after Julius Caesar (100 BCE � 44 BCE), is a year of exactly
 * 365.25 days. Julian year 2000 began on 2000 January 1 at exactly 12:00 TT. The
 * beginning of Julian years are indicated with prefix 'J' and suffix '.0', for example
 * 'J2000.0' for the beginning of Julian year 2000. Because Julian years have a fixed
 * length, their beginning is far easier to calculate than that of Besselian years.<br><br>
 *
 * The IAU decided at their General Assembly of 1976 that the new standard equinox of
 * J2000.0 should be used starting in 1984. (Before that, the equinox of B1950.0 seems to
 * have been the standard.) If the past is a good guide, then we may expect to switch to
 * J2050.0 in the mid-2030s. Julian epochs are calculated according to:<br>
 * J = 2000.0 + (Julian date - 2451545.0) / 365.25 [1]<br><br>
 *
 * [1] Wikipedia, (2009). Epoch (astronomy). [Online]. Available:
 * http://en.wikipedia.org/wiki/Epoch_(astronomy) [June 20, 2009]
 *
 * @param fixedDate The date to calculate the Julian epoch value for.
 * @return The Julian Epoch value of the specified Gregorian Calendar.
 * @version 1.00 2009-06-22 Initial submission.
 * @version 1.10 2009-09-15 Methods are no longer static.
 * @version 1.20 2010-04-27 This class now has package visibility and methods are once again static.
 * @version 1.30 2012-11-17 Port to QML.
 */
qreal calculateJulianEpoch(QDate const& fixedDate)
{
	int yy = fixedDate.year();
	int mm = fixedDate.month();
	int dd = fixedDate.day();
	int A, B, m, y;
	qreal T1,T2,Tr;

	if (mm > 2)
	{
		y = yy;
		m = mm;
	} else {
		y = yy-1;
		m = mm+12;
	}

	A = y/100;
	B = 2 - A + A/4;
	T1 = floor( 365.25*(y+4716) );
	T2 = floor( 30.6001*(m+1) );
	Tr = T1+T2+dd+B-1524.5;

	return Tr;
}


/**
 * Converts the specified degrees value to the correct radians. This means that if a value
 * larger than 360 degrees is given, it is scaled until it is less than or equal to 360
 * degrees and then converted to radians.
 * @param L The value in degrees to convert to the correct radians.
 * @return The corrected radians value of the specified degrees.
 */
qreal convertToCorrectRadians(qreal L)
{
	int MAX_DEGREES = 360;

	L -= floor(L/MAX_DEGREES) * MAX_DEGREES;

	if (L < 0)
		L += MAX_DEGREES;

	return SolarCalculator::degreesToRadians(L);
}


/**
 * Calculates the sun mean anomaly given the specified centuries passed. The mean anomaly
 * is the angle between lines drawn from the Sun to the perihelion B and to a point
 * (not shown) moving in the orbit at a uniform rate corresponding to the period of
 * revolution of the planet. [9] The anomaly is the angular difference between a mean
 * circular orbit and the true elliptic orbit. [10]<br><br>
 *
 * [9] Encyclopedia Britannica Inc., (2009). anomaly. [Online]. Available:
 * http://www.britannica.com/EBchecked/topic/26578/anomaly#ref105659 [June 21, 2009]
 * [10] Tomezzoli, Vanni, (2001). How to find the times of sunrise and sunset. [Online]. Available:
 * http://xoomer.virgilio.it/vtomezzo/sunriset/formulas/algorythms.html [June 21, 2009]
 *
 * @param T The number of centuries since January 1, 2000 at 12 UT.
 * @return The sun mean anomaly in radians.
 */
qreal calculateSunMeanAnomaly(qreal T)
{
	qreal M = 358.47583 + 35999.04975*T - 15E-5*( pow(T,2) ) - 33E-7*( pow(T,3) );
	return convertToCorrectRadians(M);
}


/**
 * Calculates the Geometric mean longitude of the sun measured from the vernal equinox.<br><br>
 *
 * The direction to the equinox at a particular epoch, with the effect of nutation
 * subtracted. The mean equinox therefore moves smoothly across the sky due to precession
 * alone, without short-term oscillations due to nutation. [11]<br><br>
 *
 * In astrodynamics or celestial dynamics mean longitude is the longitude at which an
 * orbiting body could be found if its orbit were circular and its inclination were zero.
 * The mean longitude changes at a constant rate over time. The only times when it is
 * equal to the true longitude are at periapsis and apoapsis. [12]<br><br>
 *
 * [11] HighBeam Research, Inc., (2009). mean equinox. [Online]. Available:
 * http://www.encyclopedia.com/doc/1O80-meanequinox.html [June 21, 2009]<br>
 * [12] Wikipedia, (2009). Mean longitude. [Online]. Available:
 * http://en.wikipedia.org/wiki/Mean_longitude [June 21, 2009]
 *
 * @param T The number of centuries since January 1, 2000 at 12 UT.
 * @return The geometric mean longitude of the sun measured from the vernal equinox.
 */
qreal calculateSunMeanLongitude(qreal T)
{
	qreal L = 279.6966778 + (36000.76892*T) + ( 0.0003025*( pow(T,2) ) ); // the periodic oscillation observed in the precession of the earth's axis and the precession of the equinoxes. The following is also used: L0 = 280.46646 + 36000.76983 T + 0.0003032 T2
	return convertToCorrectRadians(L);
}


/**
 * Calculates the Earth eccentricity given the number of centuries since 2000.<br><br>
 *
 * In astrodynamics, under standard assumptions, any orbit must be of conic section shape.
 * The eccentricity of this conic section, the orbit's eccentricity, is an important
 * parameter of the orbit that defines its absolute shape. Eccentricity may be interpreted
 * as a measure of how much this shape deviates from a circle.<br><br>
 *
 * The eccentricity of the Earth's orbit is currently about 0.0167. Over thousands of
 * years, the eccentricity of the Earth's orbit varies from nearly 0.0034 to almost 0.058
 * as a result of gravitational attractions among the planets.<br><br>
 *
 * Orbital mechanics require that the duration of the seasons be proportional to the area
 * of the Earth's orbit swept between the solstices and equinoxes, so when the orbital
 * eccentricity is extreme, the seasons that occur on the far side of the orbit (aphelion)
 * can be substantially longer in duration. Today, northern hemisphere fall and winter
 * occur at closest approach (perihelion), when the earth is moving at its maximum
 * velocity. As a result, in the northern hemisphere, fall and winter are slightly
 * shorter than spring and summer. In 2006, summer was 4.66 days longer than winter and
 * spring is 2.9 days longer than fall. Axial precession slowly changes
 * the place in the Earth's orbit where the solstices and equinoxes occur. Over the next
 * 10,000 years, northern hemisphere winters will become gradually longer and summers will
 * become shorter. Any cooling effect, however, will be counteracted by the fact that the
 * eccentricity of Earth's orbit will be almost halved, reducing the mean orbital radius
 * and raising temperatures in both hemispheres closer to the mid-interglacial peak. [5]<br><br>
 *
 * [5] Wikipedia, (2009). Orbital eccentricity. [Online]. Available:
 * http://en.wikipedia.org/wiki/Orbital_eccentricity [June 21, 2009]
 *
 * @param T The number of centuries since January 1, 2000 at 12 UT.
 * @return The Earth eccentricity.
 */
qreal calculateEarthEccentricity(qreal T) {
	return 0.01675104 - 418E-7*T - 126E-9*( pow(T,2) );
}


/**
 * Calculates the obliquity of the ecliptic with the expression of Newcomb.<br><br>
 *
 * In astronomy, axial tilt is the inclination angle of a planet's rotational axis in
 * relation to its orbital plane. It is also called axial inclination or obliquity. The
 * axial tilt is expressed as the angle made by the planet's axis and a line drawn through
 * the planet's center perpendicular to the orbital plane.
 *
 * The Earth currently has an axial tilt of about 23.37�. The axis remains tilted in the
 * same direction throughout a year; however, as the Earth orbits the Sun, the hemisphere
 * (half part of earth) tilted away from the Sun will gradually become tilted towards the
 * Sun, and vice versa. This effect is the main cause of the seasons (see effect of sun
 * angle on climate). Whichever hemisphere is currently tilted toward the Sun experiences
 * more hours of sunlight each day, and the sunlight at midday also strikes the ground at
 * an angle nearer the vertical and thus delivers more energy per unit surface area. [6]<br>,<br>
 *
 * [6] Wikipedia, (2009). Axial tilt. [Online]. Available:
 * http://en.wikipedia.org/wiki/Obliquity_of_the_ecliptic [June 21, 2009]
 *
 * @param T The number of centuries since January 1, 2000 at 12 UT.
 * @return The ecliptic obliquity value.
 */
qreal calculateEclipticObliquity(qreal T)
{
	qreal ec = 23.452294 - 0.0130125*T - 164E-8*( pow(T,2) ) + 503E-9*( pow(T,3) );
	return SolarCalculator::degreesToRadians(ec);
}


/**
 * Calculates the Y value given the ecliptic obliquity.
 * @param obliq The ecliptic obliquity.
 * @return The Y value associated with the ecliptic obliquity.
 */
qreal calculateY(qreal obliq)
{
	qreal y = tan(obliq*0.5);
	return pow(y, 2);
}


/**
 * Calculates the equation of time given the specified parameters.<br><br>
 *
 * The equation of time is the difference between apparent solar time and mean solar time,
 * both taken at a given place (or at another place with the same geographical longitude)
 * at the same real instant of time.<br><br>
 *
 * Apparent (or true) solar time can be obtained for example by measurement of the current
 * position (hour angle) of the Sun, or indicated (with limited accuracy) by a sundial.
 * Mean solar time, for the same place, would be the time indicated by a steady clock set
 * so that its differences over the year from apparent solar time average to zero (with
 * zero net gain or loss over the year).<br><br>
 *
 * The equation of time varies over the course of a year, in way that is almost exactly
 * reproduced from one year to the next. Apparent time, and the sundial, can be ahead
 * (fast) by as much as 16 min 33 s (around November 3), or behind (slow) by as much as
 * 14 min 6 s (around February 12).<br><br>
 *
 * The equation of time results from two different superposed astronomical causes, each
 * causing a different non-uniformity in the apparent daily motion of the Sun relative to
 * the stars, and contributing a part of the effect:<br>
 * -the obliquity of the ecliptic (the plane of the Earth's annual orbital motion around
 *  the Sun), which is inclined by about 23.44 degrees relative to the plane of the Earth's
 *  equator; and<br>
 * -the eccentricity and elliptical form of the Earth's orbit around the Sun.<br><br>
 *
 * The equation of time is also the east or west component of the analemma, a curve
 * representing the angular offset of the Sun from its mean position on the celestial
 * sphere as viewed from Earth.<br><br>
 *
 * The equation of time was used historically to set clocks. Between the invention of
 * accurate clocks in 1656 and the advent of commercial time distribution services around
 * 1900, one of two common land-based ways to set clocks was by observing the passage of
 * the sun across the local meridian at noon. The moment the sun passed overhead, the
 * clock was set to noon, offset by the number of minutes given by the equation of time
 * for that date. (The second method did not use the equation of time, it used stellar
 * observations to give sidereal time, in combination with the relation between sidereal
 * time and solar time.) The equation of time values for each day of the year,
 * compiled by astronomical observatories, were widely listed in almanacs and ephemerides. [7]<br><br>
 *
 * [7] Wikipedia, (2009). Equation of time. [Online]. Available:
 * http://en.wikipedia.org/wiki/Equation_of_time [June 21, 2009]
 *
 * @param y The Y value.
 * @param L The geometric mean longitude of the sun.
 * @param M The sun mean anomaly.
 * @param earthEccentricity The Earth eccentricity value.
 * @return The equation of time.
 */
qreal calculateEquationOfTime(qreal y, qreal L, qreal M, qreal earthEccentricity)
{
	return y*sin(2*L) - 2*earthEccentricity*sin(M) + 4*earthEccentricity*y*sin(M)*cos(2*L) - 0.5*y*y*sin(4*L) - 5*0.25*earthEccentricity*earthEccentricity*sin(2*M);
}


/**
 * Determines the number of hours that have passed given the specified equation of time.
 * @param eot The equation of time as calculated.
 * @return The sidereal time at Greenwich measured in hours.
 */
qreal calculateHours(qreal eot)
{
	eot /= 15;
	return SolarCalculator::radiansToDegrees(eot);
}


/**
 * Calculates Euler's constant given the specified parameters. The mathematical constant e
 * is the unique real number such that the area above the x-axis and below the curve y=1/x
 * for 1 <= x <= e is exactly 1. It turns out that, consequently, the area for 1 <= x <= et is
 * t. Also, the function ex has the same value as the slope of the tangent line, for all
 * values of x. More generally, the only functions equal to their own derivatives are
 * of the form Cex, where C is a constant. The function ex so defined is called the
 * exponential function, and its inverse is the natural logarithm, or logarithm to base e.
 * The number e is also commonly defined as the base of the natural logarithm (using an
 * integral to define the latter), as the limit of a certain sequence, or as the sum of a
 * certain series (see alternative characterizations below).<br><br>
 *
 * The number e is one of the most important numbers in mathematics, alongside the
 * additive and multiplicative identities 0 and 1, the constant pi, and the imaginary unit
 * i. (All five of these constants together comprise Euler's identity.) The number e is
 * sometimes called Euler's number after the Swiss mathematician Leonhard Euler. The
 * number e is irrational; it is not a ratio of integers (root of a linear polynomial).
 * Furthermore, it is transcendental; it is not a root of any polynomial with integer
 * coefficients. [1]<br><br>
 *
 * The used formula is defined in the "Easy PC Astronomy" book (p.91). [2]<br><br>
 *
 * [1] Wikipedia, (2009). e (mathematical constant). [Online]. Available:
 * http://en.wikipedia.org/wiki/E_(mathematical_constant) [June 21, 2009]<br>
 * [2] Smith, Peter D. (1996). Easy PC Astronomy. Cambridge: Press Syndicate of the
 * University of Cambridge.
 *
 * @param M The sun mean anomaly.
 * @param earthEccentricity The Earth eccentricity.
 * @return The calculated Euler constant given the specified sun mean anomaly and
 * Earth eccentricity.
 */
qreal calculateEuler(double M, double earthEccentricity)
{
	double dt = 1;
	double euler = M;

	while( abs(dt) > 1e-9 )
	{
		dt = euler - earthEccentricity*sin(euler) - M;
		double dE = dt /( 1 - earthEccentricity*cos(euler) );
		euler = euler-dE;
	}

	return euler;
}


/**
 * Calculates the V value given the specified parameters.
 * @param earthEccentricity The Earth eccentricity.
 * @param eclipticObliquity The ecliptic obliquity.
 * @return The V value.
 */
qreal calculateV(qreal earthEccentricity, qreal eclipticObliquity)
{
	qreal x = sqrt( (1+earthEccentricity) / (1-earthEccentricity) );
	qreal tnv = x * tan(0.5*eclipticObliquity);

	return 2*atan(tnv);
}


/**
 * Gets the angle between the two points.
 * @param x The first point.
 * @param y The second point.
 * @return The atanxy angle value between the two points.
 */
qreal atanxy(qreal x, qreal y)
{
	qreal argm;

	if (x == 0) {
	    argm = 0.5*M_PI;
	} else {
		argm = atan(y/x);
    }

	if ( (x > 0) && (y < 0) ) {
		argm = 2.0*M_PI + argm;
    }

	if (x < 0) {
	    argm = M_PI + argm;
	}

	return argm;
}


/**
 * Calculates the equatorial coordinates given the ecliptic coordinates.
 * @param c The ecliptic coordinates in in radians (where the x-coordinate is beta and the y-coordinate is lamda).
 * @return The equatorial coordinates of the given ecliptic coordinates (where the x-coordinate of
 * the result is the declination, and the y-coordinate is the right-ascension).
 */
QPointF getEquatorialCoordinatesValue(QPointF const& c)
{
	qreal epsilonRadians = SolarCalculator::degreesToRadians(23.439281); // is the Earth's axial tilt in radians

	qreal beta = c.x(); // The latitudinal angle is called the ecliptic latitude or celestial latitude (denoted beta) measured positive towards the north.
	qreal lamda = c.y(); // The longitudinal angle is called the ecliptic longitude or celestial longitiude (denoted lamda), measured eastwards from 0� to 360�

	qreal sinDelta = sin(beta)*cos(epsilonRadians) + cos(beta)*sin(epsilonRadians)*sin(lamda);
	qreal deltaR = asin(sinDelta);

	qreal y = sin(lamda)*cos(epsilonRadians) - tan(beta)*sin(epsilonRadians);
	qreal x = cos(lamda);
	qreal alpha = atanxy(x,y);

	return QPointF(deltaR, alpha);
}


/**
 * Calculates the noon time (which is when the sun reaches its highest point: the zenith).
 * This is the point in the sun's path at which it is on the local meridian. [8]
 *
 * [8] Farlex Inc., (2009). noon. [Online]. Available:
 * http://www.thefreedictionary.com/noon [June 21, 2009]
 *
 * @param obsLongitude The observer's longitude value (in radians).
 * @param UT The universal time (in hours).
 * @param tz The timezone of the region.
 * @return The noon-time for the region given the specified parameters.
 */
qreal calculateNoonTime(qreal obsLongitude, qreal UT, qreal tz) {
	return 12 - UT - tz + obsLongitude*(12.0/M_PI);
}


/**
 * Calculates the ratio used to calculate the height above sea level. The used formula is
 * defined in the "Easy PC Astronomy" book (p.38). [2][12]
 * @param latitude The latitude of the region (in radians).
 * @param decl The declination value of the equatorial coordinates.
 * @return The ratio given the specified latitude and declination value.
 */
qreal calculateCH(qreal latitude, qreal decl)
{
	qreal T1 = ( sin(sunrise_arc_angle) - sin(decl)*sin(latitude) ); // divisor
	qreal T2 = ( cos(decl)*cos(latitude) ); // divisor: Hour angle for the Sun

	return T1/T2;
}


}

namespace salat {


qreal SolarCalculator::calculateCorrectedHeight(qreal angle) {
	return (sin(angle) - getSinDeclination()) / getCosDeclination();
}

/**
 * Gets the sin value of the equatorial declination value performed on the previously
 * calculated latitude.
 * @return The sin value of the equatorial declination value performed on the previously
 * calculated latitude.
 */
qreal SolarCalculator::getSinDeclination() const {
	return sin( m_equatorialCoordinates.x() ) * sin(m_latitude);
}

QPointF SolarCalculator::getEquatorialCoordinates() const {
	return m_equatorialCoordinates;
}

qreal SolarCalculator::getLatitude() const {
	return m_latitude;
}

qreal SolarCalculator::getMaxLatitude() const {
	return m_maxLatitude;
}

qreal SolarCalculator::getNoonTime() const {
	return m_noonTime;
}

qreal SolarCalculator::getSunrise() const {
	return m_sunrise;
}

qreal SolarCalculator::getSunset() const {
	return m_sunset;
}

qreal SolarCalculator::getNightLength() const {
	return total_hours_in_day - (m_sunset-m_sunrise); // 24 hours in a day
}


/**
 * Gets the cos value of the equatorial declination value performed on the previously
 * calculated latitude.
 * @return The cos value of the equatorial declination value performed on the previously
 * calculated latitude.
 */
qreal SolarCalculator::getCosDeclination() const {
	return cos( m_equatorialCoordinates.x() ) * cos(m_latitude);
}

/**
 * Performs the solar calculations for the geographical region specified given the
 * specified parameters.
 * @param fixedDate The date to perform the solar calculations for.
 * @param tz The daylight savings time adjusted time zone to perform the solar calculations for.
 * @param longitude The longitude of the region (in radians).
 * @param latitude The latitude of the region (in radians).
 * @return true If recalculation will be needed due to a problematic region.
 */
bool SolarCalculator::performCalculationSolar(const QDate& fixedDate, qreal tz, qreal longitude, qreal latitude)
{
	m_latitude = latitude;
	qreal julianDate = calculateJulianEpoch(fixedDate);
	qreal T = calculateCenturiesSince2000(julianDate, tz);
	qreal L = calculateSunMeanLongitude(T);
	qreal M = calculateSunMeanAnomaly(T);
	qreal earthEccentricity = calculateEarthEccentricity(T);
	qreal obliq = calculateEclipticObliquity(T);
	qreal Y = calculateY(obliq);
	qreal eot = calculateEquationOfTime(Y, L, M, earthEccentricity);
	qreal hours = calculateHours(eot);
	qreal eValue = calculateEuler(M, earthEccentricity);
	qreal v = calculateV(earthEccentricity, eValue);
	qreal tht = L + v - M; // theta value
	m_equatorialCoordinates = getEquatorialCoordinatesValue( QPointF(0, tht) ); // where DECL = delta = x: 0.183, alpha = RA = y: 0.441
	m_noonTime = calculateNoonTime(-longitude, hours, tz);
	qreal cH = calculateCH( latitude, m_equatorialCoordinates.x() );
	bool successFlag = cH <= max_ch_value;
	if (!successFlag) {
		cH = max_ch_value; // At this day and place the sun does not rise or set
	}
	/* The sunrise occurs when the upper limb of the Sun disc is visible at the horizon,
	 * towards east, at a location whose elevation is reduced to the sea level - while
	 * the sunset occurs in the same circumstances, but in the opposite direction,
	 * towards the western horizon.
	 *
	 * [2] Tomezzoli, Vanni, (2001). How to find the times of sunrise and sunset. [Online]. Available:
	 * http://xoomer.virgilio.it/vtomezzo/sunriset/formulas/algorythms.html [June 21, 2009]
	 */
	qreal H = acos(cH) * (12/M_PI); // The height above sea level in meters.
	m_sunrise = m_noonTime - H;
	m_sunset = m_noonTime + H;
	return successFlag;
}


bool SolarCalculator::calculateSolar(QDate const& fixedDate, qreal timeZone, qreal longitude, qreal latitude) {
	bool success = performCalculationSolar(fixedDate, timeZone, longitude, latitude);
	qreal solarDifference = abs(m_sunset - m_sunrise);
	bool recalculationNeeded = !success || (solarDifference <= 1) || (solarDifference >= 23);
	if (recalculationNeeded) {
		m_maxLatitude = getMaxLatitudeValue(latitude);
		performCalculationSolar(fixedDate, timeZone, longitude, m_maxLatitude);
	}
	if (m_noonTime < 0) {
		m_noonTime += total_hours_in_day; // total hours in a day
	}
	return recalculationNeeded;
}

qreal SolarCalculator::radiansToDegrees(qreal angle) {
	return (angle * 180 / M_PI);
}

qreal SolarCalculator::degreesToRadians(qreal angle) {
    return (angle * M_PI / 180);
}


SolarCalculator::~SolarCalculator()
{
}


} /* namespace salat10 */
