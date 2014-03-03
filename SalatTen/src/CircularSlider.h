#ifndef CIRCULARSLIDER_HPP
#define CIRCULARSLIDER_HPP

#include <bb/cascades/CustomControl>
#include <bb/cascades/Image>
#include <bb/cascades/ImplicitAnimationController>

#include <QPair>
#include <QVector>

namespace bb {
    namespace cascades {
        class Container;
        class ImageView;
        class TouchEvent;
    }
}

namespace canadainc {

class CircularSlider: public bb::cascades::CustomControl
{
    Q_OBJECT

    Q_PROPERTY(float value READ value WRITE setValue NOTIFY valueChanged FINAL)

public:
    CircularSlider(bb::cascades::Container *parent = 0);

    float value() const;
    void setValue(float value);

Q_SIGNALS:
    void valueChanged(float value);

private Q_SLOTS:
    void onSliderHandleTouched(bb::cascades::TouchEvent *touchEvent);
    void onWidthChanged(float width);
    void onHeightChanged(float height);

private:
    void onSizeChanged();
    void processRawCoordinates(float inX, float inY);

    bb::cascades::Container *m_rootContainer;
    bb::cascades::ImageView *m_trackImage;

    float m_width;
    float m_height;
    float m_revAngle;

    float m_centerX;
    float m_centerY;
    float m_radiusCircle;

    bb::cascades::Image m_handleOn;
    bb::cascades::Image m_handleOff;
    bb::cascades::ImageView *m_handle;
    bb::cascades::Container *m_handleContainer;
    bb::cascades::ImplicitAnimationController m_handleImplicitAnimationController;

    QVector<QPair<float, float> > m_pointsOnCircumference;
    float m_angle;
    float m_value;
};

}

#endif
