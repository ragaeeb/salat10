import bb.cascades 1.0
import com.canadainc.data 1.0

ListView
{
    id: listView
    
    dataModel: ArrayDataModel {
        id: adm
    }
    
    listItemComponents:
    [
        ListItemComponent {
            StandardListItem
            {
                title: ListItemData.author
                description: ListItemData.title
            }
        }
    ]
    
    onCreationCompleted: {
        sql.dataLoaded.connect( function(id, data)
        {
                if (id == QueryId.GetArticles)
                {
                    adm.clear();
                    adm.append(data);
                }
        });
    
    sql.query = "SELECT suite_pages.id AS id,COALESCE(i.displayName, i.name) AS author,COALESCE(heading,title) AS title FROM suites LEFT JOIN individuals i ON i.id=suites.author INNER JOIN suite_pages ON suite_pages.suite_id=suites.id";
    sql.load(QueryId.GetArticles);
    }
}