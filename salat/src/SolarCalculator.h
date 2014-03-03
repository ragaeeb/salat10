#ifndef SOLARCALCULATOR_H_
#define SOLARCALCULATOR_H_

#include <QPointF>

class QDate;

namespace salat {

class SolarCalculator
{
    /** The calculated time of the sun rise. */
    qreal m_sunrise;
    /** The calculated time of the sun set. */
    qreal m_sunset;
    /** The latitude of the region to calculate the solar position data for. */
    qreal m_latitude;
    /** The calculated equatorial coordinates. */
    QPointF m_equatorialCoordinates;
    /** The maximum latitude to use to calculate the solar position data for. */
    qreal m_maxLatitude;
    /** The calculated noon time. */
    qreal m_noonTime;

public:
    bool performCalculationSolar(const QDate& d, qreal timeZone, qreal longitude, qreal latitude);
    /**
	 * Performs the solar calculations for the geographical region specified given the
	 * specified parameters. If recalculation is needed, it is performed.
	 * @param fixedDate The date to perform the solar calculations for.
	 * @param timeZone The daylight savings time adjusted time zone to perform the solar calculations for.
	 * @param longitude The longitude of the region (in radians).
	 * @param latitude The latitude of the region (in radians).
	 * @return true If recalculation was needed due to a problematic calculation done.
	 */
    bool calculateSolar(const QDate& d, qreal timeZone, qreal longitude, qreal latitude);

    /**
     * Converts an angle measured in radians to an approximately equivalent angle measured in degrees. The conversion from radians to
     * degrees is generally inexact; users should not expect cos( toRadians(90.0) ) to exactly equal 0.0.
     * @param angle an angle, in radians.
     * @return The measurement of the angle in degrees.
     */
    static qreal degreesToRadians(qreal angle);

    static qreal radiansToDegrees(qreal angle);

    /**
	 * Calculates the corrected height value given the specified parameters.
	 * @param angle The angle value (in radians).
	 * @return The corrected height value given the angle, the sin and cos values of the
	 * latitudinal angle.
	 */
    qreal calculateCorrectedHeight(qreal angle);
    qreal getSinDeclination() const;
    qreal getCosDeclination() const;
    QPointF getEquatorialCoordinates() const;
    qreal getLatitude() const;
    qreal getMaxLatitude() const;
    qreal getNoonTime() const;
    qreal getSunrise() const;
    qreal getSunset() const;
    qreal getNightLength() const;

    virtual ~SolarCalculator();
};

} /* namespace salat10 */
#endif /* SOLARCALCULATOR_H_ */
