#include "precompiled.h"

#include "CompassSensor.hpp"
#include "SolarCalculator.h"
#include "Logger.h"

namespace {

using namespace salat;

struct Point {
	QVector3D vector;
	qreal radius;
};

qreal earthRadiusInMeters(qreal latitudeRadians)
{
    qreal a = 6378137.0; // equatorial radius in meters
    qreal b = 6356752.3; // polar radius in meters
    qreal cosValue = cos(latitudeRadians);
    qreal sinValue = sin(latitudeRadians);
    qreal t1 = a * a * cosValue;
    qreal t2 = b * b * sinValue;
    qreal t3 = a * cosValue;
    qreal t4 = b * sinValue;
    return sqrt( (t1*t1 + t2*t2) / (t3*t3 + t4*t4) );
}

Point locationToPoint(QVector3D const& c)
{
    // Convert (lat, lon, elv) to (x, y, z).
    qreal lat = SolarCalculator::degreesToRadians( c.x() );
    qreal lon = SolarCalculator::degreesToRadians( c.y() );
    qreal radius = c.z() + earthRadiusInMeters(lat);
    qreal cosLon = cos(lon);
    qreal sinLon = sin(lon);
    qreal cosLat = cos(lat);
    qreal sinLat = sin(lat);
    qreal x = cosLon * cosLat * radius;
    qreal y = sinLon * cosLat * radius;
    qreal z = sinLat * radius;

    Point result;
    result.vector = QVector3D(x,y,z);
    result.radius = radius;

    return result;
}

QVector3D rotateGlobe(QVector3D const& b, QVector3D const& a, qreal bradius)
{
    // Get modified coordinates of 'b' by rotating the globe so that 'a' is at lat=0, lon=0.
    QVector3D br = QVector3D( b.x(), b.y()-a.y(), b.z() );
    Point brp = locationToPoint(br);

    // scale all the coordinates based on the original, correct geoid radius...
    brp.vector.setX( brp.vector.x() * (bradius / brp.radius) );
    brp.vector.setY( brp.vector.y() * (bradius / brp.radius) );
    brp.radius = bradius; // restore actual geoid-based radius calculation

    // Rotate brp cartesian coordinates around the z-axis by a.lon degrees,
    // then around the y-axis by a.lat degrees.
    // Though we are decreasing by a.lat degrees, as seen above the y-axis,
    // this is a positive (counterclockwise) rotation (if B's longitude is east of A's).
    // However, from this point of view the x-axis is pointing left.
    // So we will look the other way making the x-axis pointing right, the z-axis
    // pointing up, and the rotation treated as negative.
    qreal alat = SolarCalculator::degreesToRadians( -a.x() );
    qreal acos = cos(alat);
    qreal asin = sin(alat);

    qreal bx = (brp.vector.x() * acos) - (brp.vector.z() * asin);
    qreal by = brp.vector.y();
    qreal bz = (brp.vector.x() * asin) + (brp.vector.z() * acos);

    return QVector3D(bx,by,bz);
}

}

namespace canadainc {

using namespace bb::cascades;

CompassSensor::CompassSensor(QObject* parent) : QObject(parent), m_azimuth(0), m_calibration(0)
{
	OrientationSupport::instance()->setSupportedDisplayOrientation(SupportedDisplayOrientation::DisplayPortrait);
    OrientationSupport::instance()->setSupportedDisplayOrientation(SupportedDisplayOrientation::CurrentLocked);

    if ( !m_compassSensor.connectToBackend() ) {
        LOGGER("CannotConnectSensorBackend!");
    }

    m_compassSensor.addFilter(this);
    m_compassSensor.setSkipDuplicates(true);

    m_compassSensor.start();
}

CompassSensor::~CompassSensor() {
	OrientationSupport::instance()->setSupportedDisplayOrientation(SupportedDisplayOrientation::All);
	LOGGER("Destroying");
}


bool CompassSensor::connected() {
	return m_compassSensor.connectToBackend();
}


qreal CompassSensor::azimuth() const {
    return m_azimuth;
}


qreal CompassSensor::calibration() const {
	return m_calibration;
}


qreal CompassSensor::calculateAzimuth(qreal latitudeA, qreal longitudeA, qreal elevationA, qreal latitudeB, qreal longitudeB, qreal elevationB)
{
	QVector3D a = QVector3D(latitudeA, longitudeA, elevationA);
	QVector3D b = QVector3D(latitudeB, longitudeB, elevationB);
	Point bp = locationToPoint(b);

	// Let's use a trick to calculate azimuth:
	// Rotate the globe so that point A looks like latitude 0, longitude 0.
	// We keep the actual radii calculated based on the oblate geoid,
	// but use angles based on subtraction.
	// Point A will be at x=radius, y=0, z=0.
	// Vector difference B-A will have dz = N/S component, dy = E/W component.
	QVector3D br = rotateGlobe(b, a, bp.radius);
	qreal tanValue = atan2( br.z(), br.y() );
	qreal theta = SolarCalculator::radiansToDegrees(tanValue);
	qreal azimuth = 90.0 - theta;

	if (azimuth < 0.0) {
		azimuth += 360.0;
	}

	if (azimuth > 360.0) {
		azimuth -= 360.0;
	}

	return round(azimuth*10)/10;
}


bool CompassSensor::filter(QCompassReading *reading)
{
    const qreal oldAzimuth = m_azimuth;
    const qreal oldCalibration = m_calibration;

    m_azimuth = reading->azimuth();
    m_calibration = reading->calibrationLevel();

    if (oldAzimuth != m_azimuth) {
        emit azimuthChanged();
    }

    if (oldCalibration != m_calibration) {
        emit calibrationChanged();
    }

    return false;
}

} // salat
