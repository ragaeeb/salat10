import bb.cascades 1.0

FullScreenDialog
{
    onClosing: {
        var result = Math.floor(slider.value);
        
        persist.saveValueFor( "hijri", result );
        reporter.record( "HijriAdjust", result.toString() );
    }
    
    onOpened: {
        tutorial.execSwipe("hijriEditLeft", qsTr("Drag the slider to the left if the actual date is supposed to be before what it is currently being calculated as."), HorizontalAlignment.Center, VerticalAlignment.Center, "l");
        tutorial.execSwipe("hijriEditRight", qsTr("Drag the slider to the right if the actual date is supposed to after what it is currently being calculated as."), HorizontalAlignment.Center, VerticalAlignment.Center, "r");
        tutorial.exec("hijriExit", qsTr("Tap anywhere outside the controls to dismiss this dialog."), HorizontalAlignment.Center, VerticalAlignment.Bottom, 0, 0, 0, ui.du(4));
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