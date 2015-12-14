import bb.cascades 1.2

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
        reporter.record( "SaveIqamah", key+"="+dtp.value.toString() );
        app.saveIqamah(key, dtp.value);
        persist.showToast( qsTr("Iqamah time set to: %1").arg( offloader.renderStandardTime(dtp.value) ), "images/empty/ic_no_coordinates.png" );
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
                    tutorial.execCentered( "jamaah", qsTr("Please set the time the congregational prayer for %1 at the masjid/musalla.").arg( translator.render(key) ) );
                    tutorial.exec("jamaahExit", qsTr("Tap anywhere outside the controls to dismiss this dialog."), HorizontalAlignment.Center, VerticalAlignment.Bottom, 0, 0, 0, tutorial.du(4));
                }
            }
        ]
        
        DateTimePicker
        {
            id: dtp
            mode: DateTimePickerMode.Time
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            title: qsTr("%1 Jamaah Time").arg( translator.render(key) ) + Retranslate.onLanguageChanged
        }
    }
}