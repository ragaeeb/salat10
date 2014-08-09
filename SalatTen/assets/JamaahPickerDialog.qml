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
        boundary.saveIqamah(key, dtp.value);
    }
    
    onOpened: {
        dtp.expanded = true;
        persist.tutorial( "tutorialJamaah", qsTr("Please set the time the congregational prayer for %1 at the masjid/musalla. Then tap anywhere outside the picker to save and dismiss it.").arg( translator.render(key) ), "asset:///images/menu/ic_set_jamaah.png" );
    }
    
    dialogContent: Container
    {
        bottomPadding: 30
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Center
        
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