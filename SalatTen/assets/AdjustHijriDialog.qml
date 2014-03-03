import bb.cascades 1.0

FullScreenDialog
{
    onClosing: {
        persist.saveValueFor( "hijri", Math.floor(slider.value) );
    }
    
    dialogContent: Container
    {
        bottomPadding: 30
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Center
        
        Slider {
            id: slider
            fromValue: -5
            toValue: 5
            value: persist.getValueFor("hijri")
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Center
            
            onValueChanged: {
                var actualValue = Math.floor(value);
                
                var message;
                
                if (actualValue < 0) {
                    message = qsTr("The Hijri date will be adjusted %1 days before its calculated time.").arg( Math.abs(actualValue) );
                } else if (actualValue == 0) {
                    message = qsTr("The Hijri date will be shown exactly as calculated.");
                } else {
                    message = qsTr("The Hijri date will be adjusted %1 days after its calculated time.").arg(actualValue);
                }
                
                sliderLabel.text = message;
            }
        }
        
        Label {
            id: sliderLabel
            multiline: true
            horizontalAlignment: HorizontalAlignment.Fill
            textStyle.textAlign: TextAlign.Center
        }
    }
}