import bb.cascades 1.0
import bb.cascades.places 1.0
import bb.platform 1.0
import com.canadainc.data 1.0

Page
{
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    titleBar: TitleBar {
        title: qsTr("Settings") + Retranslate.onLanguageChanged
    }
    
    actions: [
        ActionItem
        {
            id: locationAction
            imageSource: "file:///usr/share/icons/ic_map_all.png"
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            title: qsTr("Choose Location") + Retranslate.onLanguageChanged
            
            attachedObjects: [
                ComponentDefinition {
                    id: pickerDefinition
                    PlacePicker {}
                }
            ]
            
            onTriggered: {
                console.log("UserEvent: LocationPickerTriggered");
                
                var picker = pickerDefinition.createObject();
                var place = picker.show();
                
                if (place && place.latitude && place.longitude)
                {
                    persist.saveValueFor("city", place.city, false);
                    persist.saveValueFor("location", place.name, false);
                    persist.saveValueFor("latitude", place.latitude, true);
                    persist.saveValueFor("longitude", place.longitude, true);
                    persist.saveValueFor("country", place.country, false);
                    locationAction.title = place.name;
                    
                    persist.showToast( qsTr("Location successfully set to %1!").arg(place.name), "", "asset:///images/tabs/ic_map.png" );
                }
                
                picker.destroy();
            }
        }
    ]
    
    ScrollView
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
	    Container
	    {
            Header {
                title: qsTr("General Settings") + Retranslate.onLanguageChanged
            }
            
            Container
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                leftPadding: 10; rightPadding: 10; topPadding: 10; bottomPadding: 10
                
                DropDown
                {
                    id: calcStrategy
                    title: qsTr("Calculation Angles") + Retranslate.onLanguageChanged
                    horizontalAlignment: HorizontalAlignment.Fill
                    
                    attachedObjects: [
                        ComponentDefinition {
                            id: optionDefinition
                            
                            Option {
                                property real fajrTwilight
                                property real ishaTwilight
                                property real dhuhrInterval: 1
                                property real maghribInterval: 1 // The number of minutes to add to the sunset time for the Maghrib prayer time.
                                property real ishaInterval: 0 // The difference of Isha time from Maghrib.
                                imageSource: "images/dropdown/ic_angles.png"
                            }
                        }
                    ]
                    
                    function onDataLoaded(id, data)
                    {
                        if (id == QueryId.GetAllAngles)
                        {
                            var strategy = persist.getValueFor("strategy");
                            var firstTime = !persist.contains("angles");
                            
                            for (var i = 0; i < data.length; i++)
                            {
                                var current = data[i];
                                
                                var def = optionDefinition.createObject();
                                def.text = current.name;
                                def.description = current.description;
                                def.value = current.strategy_key;
                                def.fajrTwilight = current.fajr_twilight;
                                def.ishaTwilight = current.isha_twilight;
                                def.dhuhrInterval = current.dhuhr_interval;
                                def.maghribInterval = current.maghrib_inteval;
                                def.ishaInterval = current.isha_interval;
                                
                                if (def.value == strategy) {
                                    def.selected = true;
                                }
                                
                                calcStrategy.add(def);
                            }
                            
                            if (firstTime) {
                                calcStrategy.expanded = true;
                            }
                        }
                    }
                    
                    onCreationCompleted: {
                        sql.fetchAngles(calcStrategy);
                    }
                    
                    onSelectedOptionChanged:
                    {
                        var parameters = {
                            "fajrTwilightAngle": selectedOption.fajrTwilight,
                            "ishaTwilightAngle": selectedOption.ishaTwilight,
                            "dhuhrInterval": selectedOption.dhuhrInterval,
                            "ishaInterval": selectedOption.ishaInterval,
                            "maghribInterval": selectedOption.maghribInterval
                        };
                        
                        var strategySaved = persist.saveValueFor("strategy", selectedOption.value, false);
                        var anglesSaved = persist.saveValueFor("angles", parameters);
                        
                        if (strategySaved && anglesSaved) {
                            persist.showToast( qsTr("Salat10 will use %1 angles to calculate the prayer times.").arg(selectedOption.text), "", "asset:///images/ic_angles.png" );
                        }
                    }
                }
                
                PersistDropDown
                {
                    id: asrRatio
                    title: qsTr("Asr Ratio") + Retranslate.onLanguageChanged
                    key: "asrRatio"
                    topMargin: 20
                    
                    Option {
                        text: qsTr("Shafii, Maliki, Hanbali") + Retranslate.onLanguageChanged
                        description: qsTr("Asr begins when the height of an object is equal to the height of its shadow.") + Retranslate.onLanguageChanged
                        imageSource: "images/dropdown/ic_asr_shafii.png"
                        value: 1
                    }
                    
                    Option {
                        text: qsTr("Hanafi") + Retranslate.onLanguageChanged
                        description: qsTr("Asr begins when the height of the shadow of an object is twice the height of the object.") + Retranslate.onLanguageChanged
                        imageSource: "images/dropdown/ic_asr_hanafi.png"
                        value: 2
                    }
                }
            }
	        
            Header {
                title: qsTr("Play the athan in the following modes") + Retranslate.onLanguageChanged
            }
            
            Container
            {
                id: profileContainer
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                leftPadding: 10; rightPadding: 10; topPadding: 10; bottomPadding: 10
                
                PersistCheckBox
                {
                    id: skipJumuah
                    key: "skipJumahAthaan"
                    text: qsTr("Skip Athan on Jumuah") + Retranslate.onLanguageChanged
                }
            }
            
            Header {
                id: volumeHeader
                title: qsTr("Athan Volume") + Retranslate.onLanguageChanged
            }
            
            Slider {
                id: volumeSlider
                horizontalAlignment: HorizontalAlignment.Fill
                value: persist.getValueFor("athanVolume")
                fromValue: 0.5
                toValue: 1
                
                onValueChanged: {
                    var changed = persist.saveValueFor("athanVolume", value, false);
                    
                    if (changed) {
                        console.log("UserEvent: AthanVolumeChanged", value);
                    }
                }
                
                onImmediateValueChanged: {
                    volumeHeader.subtitle = Math.floor(immediateValue*100);
                }
            }
            
            onCreationCompleted: {
                var profiles = persist.getValueFor(KEY_PROFILES);
                
                checkBox = checkerDef.createObject();
                profileContainer.insert(1, checkBox);
                checkBox.value = ""+NotificationMode.AlertsOff;
                checkBox.checked = profiles[checkBox.value];
                checkBox.text = qsTr("All Alerts Off");
                
                checkBox = checkerDef.createObject();
                profileContainer.insert(1, checkBox);
                checkBox.value = ""+NotificationMode.PhoneOnly;
                checkBox.checked = profiles[checkBox.value];
                checkBox.text = qsTr("Phone Only");
                
                checkBox = checkerDef.createObject();
                profileContainer.insert(1, checkBox);
                checkBox.value = ""+NotificationMode.Vibrate;
                checkBox.checked = profiles[checkBox.value];
                checkBox.text = qsTr("Vibrate");
                
                var checkBox = checkerDef.createObject();
                profileContainer.insert(1, checkBox);
                checkBox.value = ""+NotificationMode.Silent;
                checkBox.checked = profiles[checkBox.value];
                checkBox.text = qsTr("Silent");
            }
            
            attachedObjects: [
                ComponentDefinition {
                    id: checkerDef
                    
                    CheckBox
                    {
                        property string value
                        
                        onCheckedChanged: {
                            var profiles = persist.getValueFor(KEY_PROFILES);
                            profiles[value] = checked;
                            persist.saveValueFor(KEY_PROFILES, profiles, false);
                        }
                    }
                }
            ]
	    }
    }
}