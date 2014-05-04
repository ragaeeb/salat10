import bb.cascades 1.2

TabbedPane
{
    id: root
    activeTab: timingsTab
    
    Menu.definition: CanadaIncMenu {
        id: menuDef
        projectName: "salat10"
        allowDonations: true
        bbWorldID: "21198062"
        showServiceLogging: true
        showSubmitLogs: true
    }
    
    onActiveTabChanged: {
        peekEnabled = activeTab != location;
    }

    Tab
    {
        id: timingsTab
        title: qsTr("Timings") + Retranslate.onLanguageChanged
        description: qsTr("Salah Times") + Retranslate.onLanguageChanged
        imageSource: "images/ic_clock.png"
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivateWhenSelected
        
        delegate: Delegate
        {
            source: "TimingsPane.qml"
            
            function onLocateClicked() {
                location.triggered();
                activeTab = location;
            }
            
            onObjectChanged: {
                if (active) {
                    object.locateClicked.connect(onLocateClicked);
                }
            }
        }
    }

    Tab {
        id: compass
        title: qsTr("Qibla") + Retranslate.onLanguageChanged
        description: qsTr("Compass") + Retranslate.onLanguageChanged
        imageSource: "images/compass/ic_compass.png"
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivatedWhileSelected

        delegate: Delegate {
            source: "CompassPane.qml"
        }
    }
    
    Tab {
        id: articles
        title: qsTr("Articles") + Retranslate.onLanguageChanged
        description: qsTr("Articles") + Retranslate.onLanguageChanged
        imageSource: "images/ic_article.png"
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivatedWhileSelected
        
        delegate: Delegate {
            source: "ArticlesPage.qml"
        }
    }
    
    Tab {
        id: sujud
        title: qsTr("Sujud As-Sahw") + Retranslate.onLanguageChanged
        description: qsTr("Prostration of Forgetfulness") + Retranslate.onLanguageChanged
        imageSource: "images/ic_articles.png"
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivatedWhileSelected
        
        delegate: Delegate {
            source: "SujudAsSahw.qml"
        }
    }
    
    Tab {
        id: location
        title: qsTr("Location") + Retranslate.onLanguageChanged
        imageSource: "images/ic_map.png"
        
        function onSettingChanged(key)
        {
            if (key == "location")
            {
                var location = persist.getValueFor("location");
                description = location ? location : qsTr("Location");
            }
        }
        
        onCreationCompleted: {
            persist.settingChanged.connect(onSettingChanged);
            onSettingChanged("location");
        }
        
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivatedWhileSelected
        
        delegate: Delegate {
            source: "LocationPane.qml"
        }
    }
    
    Tab {
        id: tutorial
        title: qsTr("Tutorial") + Retranslate.onLanguageChanged
        description: qsTr("Step by Step") + Retranslate.onLanguageChanged
        imageSource: "images/ic_tutorial.png"
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivatedWhileSelected
        
        delegate: Delegate {
            source: "Tutorial.qml"
        }
    }

    onCreationCompleted: {
        if ( !persist.contains("angles") ) {
            menuDef.settings.triggered();
        }
    }
}