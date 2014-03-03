#ifndef COORDINATES_H_
#define COORDINATES_H_

#include <QMetaType>
#include <QPointF>
#include <QString>

namespace salat {

struct Coordinates
{
	QString name;
	QPointF position;
	qreal timeZone;
};

} /* namespace salat */

Q_DECLARE_METATYPE(salat::Coordinates)

#endif /* COORDINATES_H_ */
