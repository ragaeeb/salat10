#ifndef CALCULATORTEST_H_
#define CALCULATORTEST_H_

#include "precompiled.h"

#include "Calculator.h"
#include "CompassSensor.hpp"
#include "Coordinates.h"
#include "Logger.h"
#include "SalatParameters.h"

namespace salat {

const qreal EPSILON = 0.01;

using namespace bb::cascades;
using namespace canadainc;

struct CalculatorTest
{
	static void doCompare(qreal expected, qreal actual, QString const& method)
	{
		if ( !( fabs(expected-actual) < EPSILON ) ) {
			LOGGER("ERROR in " << method << "(actual, expected)" << actual << expected << fabs(expected-actual) );
		}
	}

	static void compare(QDateTime const& t, QString const& key, QString const& expectedString, QString const& location)
	{
		int actualHours = t.time().hour();
		int actualMins = t.time().minute();

		QStringList expected = expectedString.split(":");
		int expectedHours = expected[0].toInt();
		int expectedMins = expected[1].toInt();

		if (actualHours > 12) {
			actualHours -= 12;
		}

		QTime actualTime = QTime(actualHours, actualMins);
		QTime expectedTime = QTime(expectedHours, expectedMins);

		if ( abs( actualTime.secsTo(expectedTime) ) > 60*3 ) { // +/- 3 mins difference allowed
			LOGGER("FAIL!" << location << key << t << expectedString);
		}
	}

	static void doTest(QString const& location, qreal timezone, qreal latitude, qreal longitude, QString const& expectedString, QDate const& dateValue, SalatParameters const & sp)
	{
		Calculator c;
		Coordinates coordinates;
		qreal asrRatio = 1;

		coordinates.timeZone = -timezone;
		coordinates.position.setX( SolarCalculator::degreesToRadians(latitude) );
		coordinates.position.setY( SolarCalculator::degreesToRadians(longitude) );
		coordinates.name = location;

		QStringList expected = expectedString.split(" ");
		QList<QDateTime> actual = c.calculate(dateValue, coordinates, sp, asrRatio);

		compare(actual[0], "fajr", expected[0], location);
		compare(actual[1], "sunrise", expected[1], location);
		compare(actual[2], "dhuhr", expected[2], location);
		compare(actual[3], "asr", expected[3], location);
		compare(actual[4], "maghrib", expected[4], location);
		compare(actual[5], "isha", expected[5], location);
	}


	static void testSolarCalculator()
	{
		SolarCalculator sc;
		QDate dateValue = QDate(2009,6,8);

		bool resultBool = sc.performCalculationSolar( dateValue, -4, SolarCalculator::degreesToRadians(-75.65575), SolarCalculator::degreesToRadians(45.373451) );
		Q_ASSERT_X(resultBool, "performCalculationSolar", "performCalculationSolar was not true!");
		doCompare( 0.6477044434183682, sc.getCosDeclination(), "getCosDeclination" );
		doCompare( 0.27552659275411007, sc.getSinDeclination(), "getSinDeclination" );
		doCompare( 0.3975258801541098, sc.getEquatorialCoordinates().x(), "getEquatorialCoordinatesX" );
		doCompare( 1.3189860692379605, sc.getEquatorialCoordinates().y(), "getEquatorialCoordinatesY" );
		doCompare( 0, sc.getMaxLatitude(), "getMaxLatitude" );
	}


	static void testCompass()
	{
		doCompare( 316, CompassSensor::calculateAzimuth(45.3560, -75.7579, 0, 60.7189, -135.0634, 0), "calculateAzimuth_ottawa_whitehorse" );
		doCompare( 26.9, CompassSensor::calculateAzimuth(56.7431, -111.4536, 0, 21.4267, 39.8261, 277), "calculateAzimuth_fortmac_mecca" );
		doCompare( 64.3, CompassSensor::calculateAzimuth(63.7590, -68.5184, 0, 21.4267, 39.8261, 277), "calculateAzimuth_iqaluit_mecca" );
		doCompare( 300.3, CompassSensor::calculateAzimuth(43.7061, -79.5152, 0, 49.3509, -98.1831, 0), "calculateAzimuth_toronto_miami" );
	}


	static void testCalculate()
	{
		testCompass();
		testSolarCalculator();

		SalatParameters sp;
		sp.dhuhrInterval = 1;
		sp.ishaInterval = 0;
		sp.maghribInterval = 1;
		sp.ishaTwilightAngle = SolarCalculator::degreesToRadians(15);
		sp.fajrTwilightAngle = SolarCalculator::degreesToRadians(15);
		QDate dateValue = QDate(2013,1,1);

		doTest("Ottawa, ON", -5, 45.3560, -75.7579, "6:14 7:42 12:07 2:14 4:32 6:01", dateValue, sp);
		doTest("Whitehorse, YT", -8, 60.7189, -135.0634, "7:46 10:09 1:05 1:56 4:00 6:23", dateValue, sp);
		doTest("Fort McMurray, AB", -7, 56.7431, -111.4536, "7:00 9:01 12:30 1:46 3:58 6:00", dateValue, sp);
		doTest("Iqaluit, NU", -5, 63.7590, -68.5184, "6:30 9:19 11:38 12:07 1:57 4:47", dateValue, sp);
		doTest("Halifax, NS", -4, 44.6633, -63.6096, "6:24 7:51 12:19 2:28 4:46 6:14", dateValue, sp);
		doTest("Charlottetown, PE", -4, 46.2379, -63.1282, "6:25 7:55 12:17 2:20 4:38 6:09", dateValue, sp);
		doTest("Toronto, ON", -5, 43.7061, -79.5152, "6:26 7:51 12:22 2:35 4:53 6:19", dateValue, sp);
		doTest("St. John's, NL", -3.5, 47.5731, -52.7210, "6:16 7:49 12:05 2:03 4:21 5:55", dateValue, sp);
		doTest("Miami, MB", -6, 49.3509, -98.1831, "6:51 8:28 12:37 2:28 4:45 6:23", dateValue, sp);
		doTest("Baie-Comeau, QC", -5, 49.1916, -68.2745, "5:51 7:28 11:37 1:29 3:46 5:24", dateValue, sp);
		doTest("Saskatoon, SK", -6, 52.1013, -106.5428, "7:30 9:14 1:10 2:50 5:06 6:51", dateValue, sp);
		doTest("Winnipeg, MB", -6, 49.9006, -97.7613, "6:50 8:29 12:35 2:24 4:41 6:20", dateValue, sp);
		doTest("Los Angeles, CA", -8, 33.9733, -118.2487, "5:45 6:58 11:57 2:38 4:56 6:10", dateValue, sp);
		doTest("Houston, TX", -6, 29.7634, -95.3634, "6:07 7:16 12:26 3:15 5:34 6:45", dateValue, sp);
		doTest("Chicago, IL", -6, 41.8858, -87.6229, "5:55 7:18 11:55 2:13 4:31 5:54", dateValue, sp);
		doTest("Phoenix, AZ", -7, 33.4486, -112.0733, "6:19 7:32 12:33 3:14 5:32 6:46", dateValue, sp);
		doTest("Oakland, CA", -8, 37.7776, -122.2181, "6:07 7:24 12:13 2:44 5:02 6:20", dateValue, sp);
		doTest("Atlanta, GA", -5, 33.7486, -84.3884, "6:29 7:42 12:42 3:23 5:41 6:55", dateValue, sp);
		doTest("Kansas, AL", -6, 33.9019, -87.5517, "5:42 6:55 11:55 2:35 4:53 6:07", dateValue, sp);
		doTest("Las Vegas, NV", -8, 36.1730, -115.1233, "5:36 6:51 11:45 2:20 4:38 5:54", dateValue, sp);
		doTest("Portland, OR", -8, 45.4978, -122.6937, "6:22 7:50 12:15 2:21 4:39 6:09", dateValue, sp);
		doTest("Seattle, WA", -8, 47.6115, -122.3343, "6:24 7:57 12:14 2:12 4:29 6:03", dateValue, sp);
		doTest("Washington, DC", -5, 38.9102, -77.0179, "6:08 7:26 12:12 2:40 4:58 6:17", dateValue, sp);
		doTest("Memphis, TN", -6, 35.1496, -90.0487, "5:54 7:08 12:04 2:42 5:00 6:15", dateValue, sp);
		doTest("Istanbul, Turkey", 2, 41.0186, 28.9647, "6:07 7:29 12:08 2:29 4:47 6:09", dateValue, sp);
		doTest("Jeddah, Makkah, Saudi Arabia", 3, 21.5169, 39.2192, "5:56 7:01 12:27 3:32 5:53 6:58", dateValue, sp);
		doTest("Tehran, Iran", 3.5, 35, 52, "5:55 7:10 12:06 2:44 5:02 6:17", dateValue, sp);
		doTest("Baghdad, Iraq", 3, 33.3386, 44.3939, "5:53 7:06 12:07 2:48 5:06 6:20", dateValue, sp);
		doTest("Damascus, Dimashq, Syria", 2, 33.5, 36.3, "5:26 6:39 11:39 2:20 4:38 5:52", dateValue, sp);
		doTest("Amman, Jordan", 3, 31.95, 35.9333, "6:25 7:36 12:40 3:25 5:44 6:56", dateValue, sp);
		doTest("Beirut, Beyrouth, Lebanon", 2, 33.8719, 35.5097, "5:30 6:43 11:42 2:22 4:41 5:55", dateValue, sp);
		doTest("Aden, Yemen", 3, 12.7667, 45.0167, "5:20 6:21 12:04 3:20 5:46 6:48", dateValue, sp);
		doTest("Gaza, Palestine", 2, 31.5, 34.4667, "5:30 6:41 11:46 2:32 4:51 6:02", dateValue, sp);
		doTest("Dhaka, Bangladesh", 6, 23.7231, 90.4086, "5:35 6:40 12:02 3:03 5:24 6:30", dateValue, sp);
		doTest("Shanghai, China", 8, 31.2222, 121.4581, "5:42 6:52 11:58 2:45 5:03 6:15", dateValue, sp);
		doTest("Karachi, Pakistan", 5, 24.8667, 67.05, "6:10 7:16 12:36 3:35 5:55 7:02", dateValue, sp);
		doTest("Kuala Lumpur, Wilayah Persekutuan, Malaysia", 8, 3.1667, 101.7000, "6:17 7:18 1:17 4:41 7:16 8:17", dateValue, sp);
		doTest("Buenos Aires, Argentina", -3, -34.5875, -58.6725, "4:22 5:45 12:59 4:45 8:12 9:36", dateValue, sp);

		// the following two fail because the DST times are different
		doTest("Brasilia, Brazil", -2, -15.7833, -47.9167, "5:39 6:43 1:16 4:40 7:47 8:53", dateValue, sp);
		doTest("Sydney, Australia", 11, -33.8833, 151.2167, "4:25 5:47 12:59 4:44 8:10 9:33", dateValue, sp);

		dateValue = QDate(2013,6,3); // fort mcmurry is supposed to show 12am for isha & fajr...

		dateValue = QDate(2013,6,6); // solstice for Edmonton/Fort Mac area, they are also in DST
		doTest("Fort McMurray, AB", -6, 56.7431, -111.4536, "3:07 4:37 1:25 5:57 10:13 11:42", dateValue, sp);


		sp.dhuhrInterval = 1;
		sp.ishaInterval = 0;
		sp.maghribInterval = 1;
		sp.ishaTwilightAngle = SolarCalculator::degreesToRadians(17);
		sp.fajrTwilightAngle = SolarCalculator::degreesToRadians(18);
		dateValue = QDate(2013,1,15);

		doTest("Kuala Lumpur, Wilayah Persekutuan, Malaysia", 8, 3.1667, 101.7000, "6:11 7:23 1:23 4:47 7:22 8:31", dateValue, sp);
		doTest("Shanghai, China", 8, 31.2222, 121.4581, "5:29 6:53 12:04 2:55 5:14 6:35", dateValue, sp);
		doTest("Dhaka, Bangladesh", 6, 23.7231, 90.4086, "5:24 6:42 12:08 3:13 5:33 6:47", dateValue, sp);
		doTest("Baghdad, Iraq", 3, 33.3386, 44.3939, "5:39 7:06 12:12 2:59 5:18 6:41", dateValue, sp);

		sp.dhuhrInterval = 1;
		sp.ishaInterval = 1.5;
		sp.maghribInterval = 1;
		sp.ishaTwilightAngle = SolarCalculator::degreesToRadians(0);
		sp.fajrTwilightAngle = SolarCalculator::degreesToRadians(19);
		dateValue = QDate(2013,1,15);
		doTest("Jeddah, Makkah, Saudi Arabia", 3, 21.5169, 39.2192, "5:44 7:03 12:33 3:41 6:02 7:32", dateValue, sp);
	}
};

} /* namespace salat */
#endif /* CALCULATORTEST_H_ */
