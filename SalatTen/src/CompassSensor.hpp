#ifndef COMPASSSENSOR_HPP
#define COMPASSSENSOR_HPP

#include <QtSensors/QCompassFilter>

namespace canadainc {

QTM_USE_NAMESPACE

class CompassSensor : public QObject, public QCompassFilter
{
    Q_OBJECT

    Q_PROPERTY(qreal azimuth READ azimuth NOTIFY azimuthChanged)
    Q_PROPERTY(qreal calibration READ calibration NOTIFY calibrationChanged)

public:
    CompassSensor(QObject* parent = 0);
    virtual ~CompassSensor();
    qreal azimuth() const;
    qreal calibration() const;
    Q_INVOKABLE bool connected();
    Q_INVOKABLE static qreal calculateAzimuth(qreal latitudeA, qreal longitudeA, qreal elevationA, qreal latitudeB, qreal longitudeB, qreal elevationB);

Q_SIGNALS:
    void azimuthChanged();
    void calibrationChanged();

protected:
    /**
     * This method is reimplemented from the QCompassFilter interface and is
     * called by the QCompass whenever new values are available.
     */
    bool filter(QCompassReading* reading);

private:
    QCompass m_compassSensor;
    qreal m_azimuth;
    qreal m_calibration;
};

} // salat

#endif
