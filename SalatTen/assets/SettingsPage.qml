import bb.cascades 1.0
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
	        id: contentContainer
	    	topPadding: 20; leftPadding: 20; rightPadding: 20; bottomPadding: 20

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
		            
		            var strategySaved = persist.saveValueFor("strategy", selectedOption.value);
		            var anglesSaved = persist.saveValueFor("angles", parameters);
		            
		            if (strategySaved && anglesSaved) {
                        persist.showToast( qsTr("Salat10 will use %1 angles to calculate the prayer times.").arg(selectedOption.text), "", "asset:///images/ic_angles.png" );
                        infoText.text = qsTr("%1 calculation angles set.").arg(selectedOption.text);
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
            
            PersistDropDown
            {
                id: profile
                title: qsTr("Respect Profile") + Retranslate.onLanguageChanged
                key: "respectProfile"
                topMargin: 20
                
                Option {
                    text: qsTr("Ignore Profile") + Retranslate.onLanguageChanged
                    description: qsTr("Athan will always play regardless of the device profile.") + Retranslate.onLanguageChanged
                    imageSource: "images/dropdown/ic_ignore_profile.png"
                    value: 0
                }
                
                Option {
                    text: qsTr("Respect Vibrate/Silent") + Retranslate.onLanguageChanged
                    description: qsTr("Athan will play if the device is not in vibrate/silent profile.") + Retranslate.onLanguageChanged
                    imageSource: "images/dropdown/ic_vibrate.png"
                    value: 1
                }
                
                Option {
                    text: qsTr("Respect Silence") + Retranslate.onLanguageChanged
                    description: qsTr("Athan will play if the device is not in silent profile.") + Retranslate.onLanguageChanged
                    imageSource: "images/dropdown/ic_silent.png"
                    value: 2
                }
            }

            CheckBox {
		        topMargin: 20
		        text: qsTr("Dhuhr Athan on Friday") + Retranslate.onLanguageChanged
                checked: persist.getValueFor("skipJumahAthaan") != 1;
                
                onCheckedChanged: {
                    persist.saveValueFor("skipJumahAthaan", checked ? 0 : 1);
                    
                    if (checked) {
                        infoText.text = qsTr("Athan during Ju'muah will be played.").arg(text);
                    } else {
                        infoText.text = qsTr("Athan during Ju'muah will be muted.").arg(text);
                    }
                }
          	}
		    
		    Label {
		        id: infoText
		        multiline: true
		        topMargin: 50
		        textStyle.fontSize: FontSize.XXSmall
		        textStyle.textAlign: TextAlign.Center
		        verticalAlignment: VerticalAlignment.Bottom
		        horizontalAlignment: HorizontalAlignment.Center
		    }
	    }
    }
}