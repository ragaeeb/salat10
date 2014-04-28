import bb.cascades 1.0
import bb.platform 1.0
import bb.system 1.0
import com.canadainc.data 1.0

Page
{
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
                title: qsTr("Play the athan in the following modes") + Retranslate.onLanguageChanged
            }
            
            Container
            {
                id: profileContainer
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                leftPadding: 10; rightPadding: 10; topPadding: 10; bottomPadding: 10
            }
	    	
	    	Header {
	    	    title: qsTr("General Settings") + Retranslate.onLanguageChanged
          	}
	    	
	    	Container
	    	{
	    	    horizontalAlignment: HorizontalAlignment.Fill
	    	    verticalAlignment: VerticalAlignment.Fill
                leftPadding: 10; rightPadding: 10; topPadding: 10; bottomPadding: 10
	    	    
                PersistCheckBox
                {
                    topMargin: 20
                    key: "skipJumahAthaan"
                    text: qsTr("Dhuhr Athan on Friday") + Retranslate.onLanguageChanged
                }
                
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
                    
                    onCreationCompleted: {
                        sql.dataLoaded.connect( function(id, data)
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
                                        def.maghribInterval = current.maghrib_interval;
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
                        });
                    
                    sql.query = "SELECT * FROM angles ORDER BY name";
                    sql.load(QueryId.GetAllAngles);
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
                            persist.saveValueFor("profiles", profiles, false);
                        }
                    }
                }
            ]
	    }
    }
}