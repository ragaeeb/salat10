import bb.cascades 1.0

StandardListItem
{
    id: sli
    property variant data: ListItem.data
    title: ListItemData ? ListItem.view.localization.renderStandardTime(ListItemData.value) : undefined;
    description: ListItemData ? ListItem.view.translation.render(ListItemData.key) : undefined;
    status: ListItemData && ListItemData.iqamah ? qsTr("Iqamah: %1").arg( ListItem.view.localization.renderStandardTime(ListItemData.iqamah) ) : undefined
    
    imageSource: {
        if (ListItemData) {
            vdd.show();
            return global.renderAthanStatus(ListItemData);
        } else {
            return undefined;
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
}