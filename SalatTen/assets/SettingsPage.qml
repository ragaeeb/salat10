import bb.cascades 1.2
import bb.platform 1.0
import com.canadainc.data 1.0

Page
{
    id: settingsPage
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    function onTutorialStarted(key)
    {
        if (key == "athanVolume") {
            scrollView.scrollToPoint(0, 1400);
        }
    }

    onCreationCompleted: {
        tutorial.tutorialStarted.connect(onTutorialStarted);
    }
    
    function cleanUp() {
        tutorial.tutorialStarted.disconnect(onTutorialStarted);
    }
    
    actions: [
        ActionItem
        {
            id: locationAction
            imageSource: "images/tabs/ic_map.png"
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            title: qsTr("Set Location") + Retranslate.onLanguageChanged
            
            onTriggered: {
                console.log("UserEvent: OpenMap");

                definition.source = "LocationPane.qml";
                var x = definition.createObject();
                navigationPane.push(x);
                
                reporter.record("OpenMap");
            }
        }
    ]
    
    titleBar: TitleBar
    {
        kind: TitleBarKind.Segmented
        selectedIndex: boundary.dstAdjustment == 0 ? 1 : boundary.dstAdjustment == 1 ? 2 : 0
        scrollBehavior: TitleBarScrollBehavior.NonSticky
        
        options: [
            Option {
                id: adjustMinusDST
                imageSource: "images/dropdown/dst_minus.png"
                text: qsTr("DST -1") + Retranslate.onLanguageChanged
                value: -1
            },
            
            Option {
                id: autoDST
                imageSource: "images/dropdown/dst_none.png"
                text: qsTr("Auto DST") + Retranslate.onLanguageChanged
                value: 0
            },
            
            Option {
                id: adjustPlusDST
                imageSource: "images/dropdown/dst_add.png"
                text: qsTr("DST +1") + Retranslate.onLanguageChanged
                value: 1
            }
        ]
        
        onSelectedOptionChanged: {
            var changed = persist.saveValueFor("dstAdjust", selectedOption.value);
            
            if (changed) {
                reporter.record("DstAdjust", selectedOption.value);
            }
        }
    }
    
    function showTutorials()
    {
        if (!calcStrategy.expanded)
        {
            tutorial.execBelowTitleBar("asrRatio", qsTr("According to the correct opinion, the time of %1 Aboo Haneefah (رحمه الله) considered the time of 'Asr to begin some time considerably after this point, however, 'He has opposed the narrations and the rest of the scholars, and thus his own students opposed him in this.' as Ibn 'Abdil-Barr said.  Refer to al-Mughnee (2/14). However if you want to use the Hanafi school of thought, use can use the option for the other school of thought.").arg(shafiRatio.description) );
            tutorial.exec("ishaNight", qsTr("The strongest opinion is that the day ends (thus the night begins) at the time of Maghrib. However, some scholars such as Shaykh Muhsin al-Abbad (حفظه الله) holds the opinion that the night begins at the time of Isha. If this is the fiqh opinion you take, enable this option."), HorizontalAlignment.Right, VerticalAlignment.Center, 0, tutorial.du(1), 0, tutorial.du(29), "images/tabs/ic_tutorial.png" );
            tutorial.exec("skipJumuah", qsTr("If you don't want the athan to sound on Fridays at Dhuhr time for Jumuah (to disturb the khateeb), enable this option."), HorizontalAlignment.Right, VerticalAlignment.Center, 0, tutorial.du(1), 0, 0, "images/tabs/ic_tutorial.png" );
            tutorial.exec("skipProfiles", qsTr("Choose the device profiles that you want the athan to sound off in. For example, if you want the athan to sound off even when the device is in 'Silent' mode, make sure you enable the 'Silent' profile checkbox."), HorizontalAlignment.Right, VerticalAlignment.Center );
            tutorial.exec("athanVolume", qsTr("If the athan volume is too loud, use the slider to control its output."), HorizontalAlignment.Center, VerticalAlignment.Bottom, 0, 0, 0, tutorial.du(20), "images/common/ic_next.png", "r" );
        }
    }
    
    ScrollView
    {
        id: scrollView
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

                Container
                {
                    horizontalAlignment: HorizontalAlignment.Fill
                    
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    
                    DropDown
                    {
                        id: calcStrategy
                        property bool isCustom: selectedValue == "custom"
                        title: qsTr("Calculation Angles") + Retranslate.onLanguageChanged
                        horizontalAlignment: HorizontalAlignment.Fill
                        translationY: -100
                        
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1
                        }
                        
                        onExpandedChanged: {
                            showTutorials();
                        }
                        
                        animations: [
                            TranslateTransition
                            {
                                id: anglesAnim
                                fromY: -100
                                toY: 0
                                easingCurve: StockCurve.ElasticOut
                                delay: 150
                                duration: 500
                                
                                onEnded: {
                                    var newInstall = tutorial.execActionBar("map", qsTr("To open the Map page to set your location as well as see where other Salat10 users are, tap on the '%1' action at the bottom.").arg(locationAction.title) );
                                    tutorial.execBelowTitleBar("calcAngles", qsTr("Different regions of the world use different conventions to calculate the prayer timings. Use the '%1' dropdown to set the appropriate one for your region for most accurate results.").arg(calcStrategy.title) );
                                    tutorial.execActionBar("settingsBack", qsTr("To return to the main timings page tap on the Back button here."), "b" );
                                    showTutorials();
                                    
                                    if (!newInstall)
                                    {
                                        tutorial.exec("dstAuto", qsTr("To let the calculations use your device settings for daylight savings rules, choose '%1'.").arg(autoDST.text), HorizontalAlignment.Center, VerticalAlignment.Top, 0, 0, tutorial.du(5));
                                        tutorial.exec("dstMinus", qsTr("If the calculations seem to be 1 hour ahead of the actual time, choose '%1' to manually adjust the time to be an hour backward.").arg(adjustMinusDST.text), HorizontalAlignment.Left, VerticalAlignment.Top, tutorial.du(2), 0, tutorial.du(5) );
                                        tutorial.exec("dstPlus", qsTr("If the calculations seem to be 1 hour before its actual time, choose '%1' to manually adjust the time to be an hour forward.").arg(adjustPlusDST.text), HorizontalAlignment.Right, VerticalAlignment.Top, 0, tutorial.du(2), tutorial.du(5) );
                                    }
                                }
                            }
                        ]
                        
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
                                var angles = persist.getValueFor("angles");
                                
                                data.push({'strategy_key': "custom", 'fajr_twilight': angles ? angles.fajrTwilightAngle : 15, 'isha_twilight': angles ? angles.ishaTwilightAngle : 15, 'dhuhr_interval': 1.0, 'maghrib_interval': 1.0, 'isha_interval': 0});
                                
                                for (var i = 0; i < data.length; i++)
                                {
                                    var current = data[i];
                                    
                                    var def = optionDefinition.createObject();
                                    def.value = current.strategy_key;
                                    def.fajrTwilight = current.fajr_twilight;
                                    def.ishaTwilight = current.isha_twilight;
                                    def.dhuhrInterval = current.dhuhr_interval;
                                    def.maghribInterval = current.maghrib_interval;
                                    def.ishaInterval = current.isha_interval;
                                    
                                    var strategyKey = current.strategy_key;
                                    
                                    if (strategyKey == "egas") {
                                        def.text = qsTr("Egyptian General Authority of Survey");
                                        def.description = qsTr("Africa, Iraq, Lebanon, Syria, Malaysia");
                                    } else if (strategyKey == "isna") {
                                        def.text = qsTr("North American");
                                        def.description = qsTr("Parts of USA, Canada, parts of UK");
                                    } else if (strategyKey == "mwl") {
                                        def.text = qsTr("Muslim World League");
                                        def.description = qsTr("Europe, the far east");
                                    } else if (strategyKey == "uisk") {
                                        def.text = qsTr("University of Islamic Sciences, Karachi");
                                        def.description = qsTr("Afghanistan, Bangladesh, India, Pakistan, Europe");
                                    } else if (strategyKey == "uaq") {
                                        def.text = qsTr("Umm Al-Qura");
                                        def.description = qsTr("The Arabian Peninsula");
                                    } else if (strategyKey == "seca") {
                                        def.text = qsTr("South-East Canada");
                                        def.description = qsTr("South-Eastern Canadian Cities");
                                    } else {
                                        def.text = qsTr("Custom");
                                        def.description = qsTr("Manual calculation angles");
                                    }
                                    
                                    if (i == 0) {
                                        def.imageSource = "images/menu/ic_table.png";
                                    } else if (i == 1) {
                                        def.imageSource = "images/dropdown/ic_sutrah.png";
                                    } else if (i == 2) {
                                        def.imageSource = "images/dropdown/ic_moon.png";
                                    } else if (i == 3) {
                                        def.imageSource = "images/dropdown/ic_gold.png";
                                    } else if (i == 4) {
                                        def.imageSource = "images/dropdown/ic_eid.png";
                                    } else {
                                        def.imageSource = "images/dropdown/ic_angles.png";
                                    }
                                    
                                    if (def.value == strategy) {
                                        def.selected = true;
                                    }
                                    
                                    calcStrategy.add(def);
                                }
                                
                                var profiles = persist.getValueFor("profiles");
                                
                                var checkBox = checkerDef.createObject();
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
                                
                                checkBox = checkerDef.createObject();
                                profileContainer.insert(1, checkBox);
                                checkBox.value = ""+NotificationMode.Silent;
                                checkBox.checked = profiles[checkBox.value];
                                checkBox.text = qsTr("Silent");
                                
                                checkBox = checkerDef.createObject();
                                profileContainer.insert(1, checkBox);
                                checkBox.value = ""+NotificationMode.Unknown;
                                checkBox.checked = profiles[checkBox.value];
                                checkBox.text = qsTr("All Custom Profiles");
                                
                                if (!angles) {
                                    calcStrategy.expanded = true;
                                }
                                
                                anglesAnim.play();
                            }
                        }
                        
                        onCreationCompleted: {
                            sql.fetchAngles(calcStrategy);
                        }
                        
                        function saveAngles()
                        {
                            if (isCustom) {
                                fajrValidator.validate();
                                ishaValidator.validate();
                            }
                            
                            var valid = isCustom && fajrValidator.valid && ishaValidator.valid;
                            
                            var parameters = {
                                "fajrTwilightAngle": valid ? parseFloat( customFajr.text.trim() ) : selectedOption.fajrTwilight,
                                "ishaTwilightAngle": valid ? parseFloat( customIsha.text.trim() ) : selectedOption.ishaTwilight,
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
                        
                        onSelectedOptionChanged: {
                            saveAngles();
                        }
                    }
                    
                    TextField
                    {
                        id: customFajr
                        hintText: qsTr("%1 Twilight Angle").arg( translator.render("fajr") ) + Retranslate.onLanguageChanged
                        text: calcStrategy.selectedOption ? calcStrategy.selectedOption.fajrTwilight.toString() : ""
                        inputMode: TextFieldInputMode.NumbersAndPunctuation
                        clearButtonVisible: false
                        enabled: calcStrategy.isCustom
                        visible: !calcStrategy.expanded
                        
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 0.2
                        }
                        
                        validator: Validator
                        {
                            id: fajrValidator
                            errorMessage: qsTr("Invalid angle") + Retranslate.onLanguageChanged
                            mode: ValidationMode.FocusLost
                            
                            onValidate: {
                                valid = !isNaN( parseFloat( customFajr.text.trim() ) );
                            }
                        }
                        
                        onTextChanged: {
                            console.log("UserEvent: CustomFajrAngle", text.trim() );
                            calcStrategy.saveAngles();
                        }
                    }
                    
                    TextField
                    {
                        id: customIsha
                        hintText: qsTr("%1 Twilight Angle").arg( translator.render("isha") ) + Retranslate.onLanguageChanged
                        text: calcStrategy.selectedOption ? calcStrategy.selectedOption.ishaTwilight.toString() : ""
                        inputMode: customFajr.inputMode
                        enabled: customFajr.enabled
                        clearButtonVisible: customFajr.clearButtonVisible
                        visible: !calcStrategy.expanded
                        
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: customFajr.layoutProperties.spaceQuota
                        }
                        
                        validator: Validator
                        {
                            id: ishaValidator
                            errorMessage: qsTr("Invalid angle") + Retranslate.onLanguageChanged
                            mode: ValidationMode.FocusLost
                            
                            onValidate: {
                                valid = !isNaN( parseFloat( customFajr.text.trim() ) );
                            }
                        }
                        
                        onTextChanged: {
                            console.log("UserEvent: CustomIshaAngle", text.trim() );
                            calcStrategy.saveAngles();
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
                    text: qsTr("Night Starts at %1").arg( translator.render("isha") ) + Retranslate.onLanguageChanged
                    
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
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]
}