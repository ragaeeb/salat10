import bb.cascades 1.0

FullScreenDialog
{
    onOpened: {
        tt.play();
        dtp.expanded = true;
    }
    
    dialogContent: Container
    {
        bottomPadding: 30
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Center
        
        Label {
            id: hijriLabel
            horizontalAlignment: HorizontalAlignment.Fill
            textStyle.textAlign: TextAlign.Center
            textStyle.fontSize: FontSize.Large
        }
        
        DateTimePicker
        {
            id: dtp
            mode: DateTimePickerMode.Date
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            title: qsTr("Gregorian Date") + Retranslate.onLanguageChanged
            
            onValueChanged: {
                hijriLabel.text = hijri.writeIslamicDate( persist.getValueFor("hijri"), value );
            }
        }
        
        attachedObjects: [
            HijriCalculator {
                id: hijri
            }
        ]
    }
}