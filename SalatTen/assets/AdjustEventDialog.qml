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