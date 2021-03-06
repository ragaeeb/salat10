import bb.cascades 1.0

FullScreenDialog
{
    property string key
    
    onKeyChanged: {
        var adjustments = persist.getValueFor("adjustments");
        var value = adjustments[key];
        
        if (slider.value == value) {
            slider.valueChanged(slider.value);
        } else {
            slider.value = value;
        }
    }
    
    onOpened: {
        tutorial.execSwipe("eventEditLeft", qsTr("Drag the slider to the left if the actual time is supposed to be before what it is currently being calculated as."), HorizontalAlignment.Center, VerticalAlignment.Center, "l");
        tutorial.execSwipe("eventEditRight", qsTr("Drag the slider to the right if the actual time is supposed to after what it is currently being calculated as."), HorizontalAlignment.Center, VerticalAlignment.Center, "r");
        tutorial.exec("eventExit", qsTr("Tap anywhere outside the controls to dismiss this dialog."), HorizontalAlignment.Center, VerticalAlignment.Bottom, 0, 0, 0, tutorial.du(4));
    }
    
    onClosing: {
        var adjustments = persist.getValueFor("adjustments");
        adjustments[key] = Math.floor(slider.value);
        persist.saveValueFor("adjustments", adjustments);
        
        reporter.record( "SaveAdjustment", key+"="+slider.value.toString() );
    }
    
    dialogContent: Container
    {
        bottomPadding: 30
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Center
        
        Slider {
            id: slider
            fromValue: -10
            toValue: 10
            value: 0
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Center
            
            onValueChanged: {
                var actualValue = Math.floor(value);
                
                var label = translator.render(key);
                var message;
                
                if (actualValue < 0) {
                    message = qsTr("%1 will be adjusted %2 minutes before its calculated time.").arg(label).arg( Math.abs(actualValue) ) + Retranslate.onLanguageChanged
                } else if (actualValue == 0) {
                    message = qsTr("%1 will be shown exactly as calculated.").arg(label) + Retranslate.onLanguageChanged
                } else {
                    message = qsTr("%1 will be adjusted %2 minutes after its calculated time.").arg(label).arg(actualValue) + Retranslate.onLanguageChanged
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