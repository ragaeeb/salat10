import bb.cascades 1.0

FullScreenDialog
{
    property variant base
    property string key
    
    onBaseChanged: {
        dtp.minimum = base;
        
        var max = base;
        max.setMinutes( base.getMinutes()+15 );
        dtp.value = max;
        
        max.setHours( max.getHours()+2 );
        dtp.maximum = max;
    }
    
    onClosing: {
        app.saveIqamah(key, dtp.value);
        persist.showToast( qsTr("Iqamah time set to: %1").arg( offloader.renderStandardTime(dtp.value) ), "", "asset:///images/menu/ic_set_jamaah.png" );
    }
    
    onOpened: {
        tt.play();
    }
    
    dialogContent: Container
    {
        bottomPadding: 30
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Center
        
        animations: [
            TranslateTransition
            {
                id: tt
                fromY: -720
                toY: 0
                easingCurve: StockCurve.ExponentialOut
                duration: 1000
                
                onEnded: {
                    dtp.expanded = true;
                    persist.tutorial( "tutorialJamaah", qsTr("Please set the time the congregational prayer for %1 at the masjid/musalla. Then tap anywhere outside the picker to save and dismiss it.").arg( translator.render(key) ), "asset:///images/menu/ic_set_jamaah.png" );
                }
            }
        ]
        
        DateTimePicker
        {
            id: dtp
            mode: DateTimePickerMode.Time
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            title: qsTr("Jamaah Time") + Retranslate.onLanguageChanged
        }
    }
}