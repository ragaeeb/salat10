import bb.cascades 1.0

StandardListItem
{
    id: sli
    description: ListItemData ? ListItem.view.translation.render(ListItemData.key) : undefined;
    imageSource: ListItemData ? global.renderAthanStatus(ListItemData) : undefined
    status: ListItemData && ListItemData.iqamah ? qsTr("Iqamah: %1").arg( ListItem.view.localization.renderStandardTime(ListItemData.iqamah) ) : undefined
    title: ListItemData ? ListItem.view.localization.renderStandardTime(ListItemData.value) : undefined;
    
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
                enabled: ListItemData.isSalat
                
                onTriggered: {
                    console.log("UserEvent: SetIqamah");
                    sli.ListItem.view.setJamaah(sli.ListItem.indexPath);
                }
            }
            
            DeleteActionItem {
                title: qsTr("Remove Iqamah") + Retranslate.onLanguageChanged
                imageSource: "images/menu/ic_remove_jamaah.png"
                enabled: ListItemData.isSalat && (ListItemData.iqamah != undefined)
                
                onTriggered: {
                    console.log("UserEvent: RemoveIqamah");
                    sli.ListItem.view.removeJamaah(sli.ListItem.indexPath);
                }
            }
        }
    ]
}