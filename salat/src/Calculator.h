#ifndef CALCULATOR_H_
#define CALCULATOR_H_

#include "SolarCalculator.h"

#include <QVariantMap>
#include <QDateTime>

namespace salat {

class Coordinates;
class SalatParameters;

class Calculator
{
	SolarCalculator m_solar;

	qreal computeAsr(bool problematic, qreal latitude, qreal asrRatio);
	void calculateFajrIsha(QDate const& fixedDate, Coordinates const& geo, SalatParameters const& angles, QList<QDateTime>& results);
	bool computeFajr(qreal fajrTwilight, qreal latitude, QDate const& fixedDate, QList<QDateTime>& results);
	bool computeIsha(qreal ishaTwilight, qreal ishaInterval, qreal latitude, QDate const& fixedDate, QList<QDateTime>& results);
	void computeFajrIshaInSolstice(Coordinates const& geo, SalatParameters const& angles, QDate const& fixedDate, bool fajrInSolstice, bool ishaInSolstice, QList<QDateTime>& results);

public:
	Calculator();
	QList<QDateTime> calculate(QDate const& fixedDate, Coordinates const& geo, SalatParameters const& angles, qreal asrRatio);
	static Coordinates createCoordinates(QDateTime local, QVariant const& latitude, QVariant const& longitude);
	static SalatParameters createParams(QVariantMap const& angleMap);
	virtual ~Calculator();

	static const int index_fajr;
	static const int index_sunrise;
	static const int index_dhuhr;
	static const int index_asr;
	static const int index_maghrib;
	static const int index_isha;
	static const int index_halfNight;
	static const int index_lastThirdNight;
};

} /* namespace salat */
#endif /* CALCULATOR_H_ */
