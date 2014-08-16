import bb.cascades 1.0
import com.canadainc.data 1.0

StandardListItem
{
    id: sli
    property variant data: ListItem.data
    property bool peek: sli.ListItem.view.secretPeek
    title: ListItemData ? ListItem.view.localization.renderStandardTime(ListItemData.value) : undefined;
    description: ListItemData ? ListItem.view.translation.render(ListItemData.key) : undefined;
    imageSource: {
        if (ListItemData) {
            if (ListItemData.athaan == true && ListItemData.isSalat) {
                return "images/ic_athaan_enable.png";
            } else if (ListItemData.notification == true) {
                return "images/ic_notification_enable.png";
            } else {
                return "images/ic_athaan_mute.png";
            }
        } else {
            return undefined;
        }
    }
    
    onPeekChanged: {
        if (peek) {
            showAnim.play();
        }
    }
    
    onDataChanged: {
        if (!ListItemData) {
            return;
        }
        
        var now = new Date();
        
        if ( ListItemData.value > now || ListItemData.iqamah > now ) {
            status = undefined;
            statusTimer.timeout.connect(statusTimer.updateStatus);
            statusTimer.start(1000);   
        } else {
            statusTimer.cancel();
        }
    }
    
    opacity: 0
    animations: [
        FadeTransition
        {
            id: showAnim
            fromOpacity: 0
            toOpacity: 1
            duration: sli.ListItem.indexInSection*300
        }
    ]
    
    ListItem.onInitializedChanged: {
        if (initialized) {
            showAnim.play();
        }
    }
    
    contextActions: [
        ActionSet
        {
            title: sli.title
            subtitle: sli.description
            
            ActionItem
            {
                title: qsTr("Edit") + Retranslate.onLanguageChanged
                imageSource: "images/menu/ic_edit.png"
                
                onTriggered: {
                    console.log("UserEvent: EditTime");
                    sli.ListItem.view.edit(sli.ListItem.indexPath);
                }
            }
            
            ActionItem {
                title: qsTr("Set Iqamah") + Retranslate.onLanguageChanged
                imageSource: "images/menu/ic_set_jamaah.png"
                enabled: sli.data.isSalat
                
                onTriggered: {
                    console.log("UserEvent: SetIqamah");
                    sli.ListItem.view.setJamaah(sli.ListItem.indexPath);
                }
            }
            
            DeleteActionItem {
                title: qsTr("Remove Iqamah") + Retranslate.onLanguageChanged
                imageSource: "images/menu/ic_remove_jamaah.png"
                enabled: sli.data.isSalat && (sli.data.iqamah != undefined)
                
                onTriggered: {
                    console.log("UserEvent: RemoveIqamah");
                    sli.ListItem.view.removeJamaah(sli.ListItem.indexPath);
                }
            }
        }
    ]
    
    attachedObjects: [
        QTimer {
            id: statusTimer
            singleShot: false
            
            function cancel()
            {
                stop();
                timeout.disconnect(updateStatus);
                sli.status = undefined;
            }
            
            function renderIqamah(now)
            {
                var diff = sli.data.iqamah - now;
                var diffDays = Math.ceil( diff/(1000*3600*24) );

                if (diff > 0 && diffDays < 2)
                {
                    var minutes = Math.floor( diff / (1000 * 60) );
                    var difference = diff - minutes * (1000 * 60);
                    var seconds = Math.floor(difference / 1000);

                    if (minutes > 30) {
                        sli.status = qsTr("Iqamah: %1").arg( sli.ListItem.view.localization.renderStandardTime( new Date(ListItemData.iqamah) ) );
                        start(diff-60000*30);
                    } else if (minutes <= 30 && minutes > 5) {
                        interval = 60000;
                        sli.status = qsTr("Iqamah: %1 minutes").arg(minutes);
                    } else if (minutes >= 1) {
                        interval = 1000;
                        sli.status = qsTr("Iqamah: %1 minutes %2 seconds").arg(minutes).arg(seconds);
                    } else if (seconds > 0) {
                        interval = 1000;
                        sli.status = qsTr("Iqamah: %1 seconds").arg(seconds);
                    }
                } else {
                    cancel();
                }
            }
            
            function updateStatus()
            {
                var now = new Date();
                var diff = sli.data.value - now;
                
                if (diff > 0)
                {
                    var minutes = Math.floor( diff / (1000 * 60) );
                    var difference = diff - minutes * (1000 * 60);
                    var seconds = Math.floor(difference / 1000);
                    
                    if (minutes > 30)
                    {
                        start(diff-60000*30);

                        if (sli.data.iqamah) {
                            renderIqamah(now);
                        }
                    } else if (minutes <= 30 && minutes > 5) {
                        interval = 60000;
                        sli.status = qsTr("%1 minutes").arg(minutes);
                    } else if (minutes >= 1) {
                        interval = 1000;
                        sli.status = qsTr("%1 minutes %2 seconds").arg(minutes).arg(seconds);
                    } else if (seconds > 0) {
                        interval = 1000;
                        sli.status = qsTr("%1 seconds").arg(seconds);
                    }
                } else if (sli.data.iqamah) {
                    renderIqamah(now);
                } else {
                    cancel();
                }
            }
        }
    ]
}