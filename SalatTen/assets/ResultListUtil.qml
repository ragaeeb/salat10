import bb.cascades 1.0
import bb.cascades.pickers 1.0
import bb.system 1.2
import com.canadainc.data 1.0

QtObject
{
    property variant picker: FilePicker
    {
        property variant keys
        defaultType: FileType.Music
        
        directories :  {
            return ["/accounts/1000/removable/sdcard/music", "/accounts/1000/shared/music"]
        }
        
        onFileSelected : {
            var uri = selectedFiles[0];
            app.setCustomAthaans(keys, selectedFiles[0]);
            
            persist.showToast( qsTr("Successfully set athans to %1").arg(uri), "", "asset:///images/ic_athaan_custom.png" );
        }
    }
    
    property variant athanDialog: SystemDialog
    {
        title: qsTr("Enable Athan?") + Retranslate.onLanguageChanged
        body: qsTr("Do you want to enable athans to automatically play when it is time for salah?") + Retranslate.onLanguageChanged
        rememberMeText: qsTr("Display notifications in the BlackBerry Hub") + Retranslate.onLanguageChanged
        cancelButton.label: qsTr("No") + Retranslate.onLanguageChanged
        confirmButton.label: qsTr("Yes") + Retranslate.onLanguageChanged
        rememberMeChecked: true
        includeRememberMe: true
        
        onFinished: {
            var enableAthaan = result == SystemUiResult.ConfirmButtonSelection;
            var enableNotifications = rememberMeSelection();
            
            var notifications = persist.getValueFor("notifications");
            var athaans = persist.getValueFor("athaans");
            var keys = translator.eventKeys();
            
            for (var i = keys.length-1; i >= 0; i--)
            {
                notifications[ keys[i] ] = enableNotifications;
                athaans[ keys[i] ] = enableAthaan;
            }
            
            persist.saveValueFor("notifications", notifications);
            persist.saveValueFor("athaans", athaans);
            persist.saveValueFor("athanPrompted", 1, false);
        }
    }
    
    function resetSound(keys)
    {
        app.setCustomAthaans(keys,"");
        persist.showToast( qsTr("Successfully reset athans to default sound"), "", "asset:///images/menu/ic_reset_athaan.png" );
    }
    
    function setCustomAthaans(keys)
    {
        picker.keys = keys;
        picker.title = qsTr("Select Athan");
        picker.open();
    }
    
    function textualize(data)
    {
        var event = translator.render(data.key);
        var dateString = Qt.formatDate(data.dateValue, Qt.SystemLocaleLongDate);
        var timeValue = localizer.renderStandardTime(data.value);
        var result = dateString+"\n"+event+": "+timeValue;
        
        return result;
    }
    
    function copyEvent(data) {
        persist.copyToClipboard( textualize(data) );
    }
    
    function toUtf8(data) {
        return persist.convertToUtf8( textualize(data) );
    }
    
    function toggleAthaans(turnOn)
    {
        var keepNotifications = true;

        if (!turnOn) {
            keepNotifications = persist.showBlockingDialog( qsTr("Mute Athan"), qsTr("Do you want notifications to show up in BlackBerry Hub?"), qsTr("Yes"), qsTr("No") );
        }

        var selected = parent.parent.selectionList();
        var athaans = persist.getValueFor("athaans");
        var notifications = persist.getValueFor("notifications");
        var dm = parent.parent.dataModel;

        for (var i = 0; i < selected.length; i++)
        {
            var indexPath = selected[i];
            var current = dm.data(indexPath);
            var key = current.key;

            current.athaan = turnOn;
            current.notification = keepNotifications;
            athaans[key] = turnOn;
            notifications[key] = keepNotifications;
            dm.updateItem(indexPath, current);
        }
        
        persist.saveValueFor("athaans", athaans);
        persist.saveValueFor("notifications", notifications);
        
        var toastMessage;
        var icon;
        
        if (turnOn) {
            icon = "asset:///images/ic_athaan_enable.png";
            toastMessage = qsTr("Successfully enabled alarms/athans.");
        } else {
            icon = "asset:///images/ic_athaan_mute.png";
            toastMessage = qsTr("Successfully muted alarms/athans.");
        }

        persist.showToast(toastMessage, "", icon);
    }
    
    
    function getSelectedKeys()
    {
        var selected = parent.parent.selectionList();
        var result = [];
        
        for (var i = 0; i < selected.length; i++)
        {
            var current = parent.parent.dataModel.data(selected[i]);
            result.push(current.key);
        }
        
        return result;
    }
    
    
    function textualizeSelected()
    {
        var selected = parent.parent.selectionList();
        var result = "";
        
        if (selected.length > 0)
        {
            var lastDate = parent.parent.dataModel.data(selected[0]).dateValue;
            result += Qt.formatDate(lastDate, Qt.SystemLocaleLongDate) + "\n";
            
            for (var i = 0; i < selected.length; i++)
            {
                var current = parent.parent.dataModel.data(selected[i]);
                var dv = current.dateValue.valueOf();
                
                if ( dv != lastDate.valueOf() ) {
                    lastDate = current.dateValue;
                    result += "\n" + Qt.formatDate(lastDate, Qt.SystemLocaleLongDate) + "\n";
                }
                
                var event = translator.render(current.key);
                var timeValue = localizer.renderStandardTime(current.value);
                result += event+": "+timeValue+"\n";
            }
        }
        
        return result.trim();
    }
}