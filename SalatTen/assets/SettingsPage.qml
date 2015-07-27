import bb.cascades 1.3
import bb.platform 1.0
import com.canadainc.data 1.0

Page
{
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll

    actions: [
        ActionItem
        {
            id: locationAction
            imageSource: "images/tabs/ic_map.png"
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            title: qsTr("Map") + Retranslate.onLanguageChanged
            
            onTriggered: {
                console.log("UserEvent: OpenMap");

                var x = definition.init("LocationPane.qml");
                navigationPane.push(x);
                
                reporter.record("OpenMap");
            }
        }
    ]
    
    titleBar: TitleBar {
        title: qsTr("Settings") + Retranslate.onLanguageChanged
    }
    
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

                    onExpandedChanged: {
                        if (!expanded) {
                            tutorial.execActionBar("map", qsTr("To open the Map page to set your location as well as see where other Salat10 users are, tap on the '%1' action at the bottom.").arg(locationAction.title) );
                            tutorial.execBelowTitleBar("calcAngles", qsTr("Different regions of the world use different conventions to calculate the prayer timings. Use the '%1' dropdown to set the appropriate one for your region for most accurate results.") );
                            tutorial.execBelowTitleBar("asrRatio", qsTr("According to the strongest opinion, the time of '%1' However if you want to use Imam Abu Hanifa's (rahimahullah), use can use the option for the other school of thought.").arg(shafiRatio.description) );
                            tutorial.exec("ishaNight", qsTr("The strongest opinion is that the day ends (thus the night begins) at the time of Maghrib. However, some scholars such as Shaykh Muhsin al-Abbad holds the opinion that the night begins at the time of Isha. If this is the fiqh opinion you take, enable this option."), HorizontalAlignment.Right, VerticalAlignment.Center, 0, ui.du(1), 0, ui.du(29) );
                            tutorial.exec("skipJumuah", qsTr("If you don't want the athan to sound on Fridays at Dhuhr time for Jumuah (to disturb the khateeb), enable this option."), HorizontalAlignment.Right, VerticalAlignment.Center, 0, ui.du(1) );
                            tutorial.exec("skipProfiles", qsTr("Choose the device profiles that you want the athan to sound off in. For example, if you want the athan to sound off even when the device is in 'Silent' mode, make sure you enable the 'Silent' profile checkbox."), HorizontalAlignment.Right, VerticalAlignment.Center );
                            tutorial.exec("athanVolume", qsTr("If the athan volume is too loud, use the slider to control its output."), HorizontalAlignment.Center, VerticalAlignment.Bottom, 0, 0, 0, ui.du(20), undefined, "r" );
                        }
                    }

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
                            reporter.record("NewAngles", selectedOption.value);
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
                        id: shafiRatio
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
                    
                    onValueChanged: {
                        reporter.record( "AsrRatioChanged", asrRatio.selectedValue.toString() );
                    }
                }
                
                PersistCheckBox
                {
                    id: nightStartsIsha
                    key: "nightStartsIsha"
                    text: qsTr("Night Starts at Isha") + Retranslate.onLanguageChanged
                    
                    onValueChanged: {
                        reporter.record( "NightStartsAtIshaChanged", checked.toString() );
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
                    
                    onValueChanged: {
                        reporter.record( "SkipJumuahChanged", checked.toString() );
                    }
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
                        reporter.record( "AthanVolumeChanged", value.toString() );
                    }
                }
                
                onImmediateValueChanged: {
                    volumeHeader.subtitle = Math.floor(immediateValue*100);
                }
            }
            
            onCreationCompleted: {
                var profiles = persist.getValueFor("profiles");
                
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
                            var profiles = persist.getValueFor("profiles");
                            profiles[value] = checked;
                            var changed = persist.saveValueFor("profiles", profiles, false);
                            
                            if (changed) {
                                reporter.record( "ProfileChanged_%1".arg(value), checked.toString() );
                            }
                        }
                    }
                }
            ]
	    }
    }
}