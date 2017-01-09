import bb.cascades 1.0
import com.canadainc.data 1.0

Container
{
    id: quoteRoot
    horizontalAlignment: HorizontalAlignment.Center
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.GetRandomBenefit && data.length > 0)
        {
            var quote = data[0];
            
            if (quoteLabel.text.length == 0) {
                ft.play();
            }
            
            var partQuote = "<i>“%1”</i>".arg( app.escapeHtml(quote.body) );
            var partAuthor = "<b>%1%2</b>".arg( app.escapeHtml(quote.author) ).arg( global.getSuffix(quote.birth, quote.death, quote.is_companion == 1, quote.female == 1) );
            var partSource = "[%1]".arg( app.escapeHtml(quote.reference) );
            var parts = "%1\n\n- %2\n\n%3".arg(partQuote).arg(partAuthor).arg(partSource);
            
            if (quote.translator) {
                parts += "\n\nTranslated by <i>%1%2</i>".arg( app.escapeHtml(quote.translator) ).arg( global.getSuffix(quote.translator_birth, quote.translator_death, quote.translator_companion == 1, quote.translator_female == 1) );
            }
            
            quoteLabel.text = "<html>"+parts+"</html>";
            divider.visible = true;
        }
    }
    
    TextArea
    {
        id: quoteLabel
        backgroundVisible: false
        editable: false
        textStyle.fontSize: FontSize.XXSmall
        textStyle.textAlign: TextAlign.Center
        horizontalAlignment: HorizontalAlignment.Center
        topMargin: 0; bottomMargin: 0
        
        animations: [
            FadeTransition {
                id: ft
                fromOpacity: 0
                toOpacity: 1
                easingCurve: StockCurve.CubicOut
                duration: 2000
                
                onEnded: {
                    permissions.process();
                }
            }
        ]
    }
    
    ImageView
    {
        id: divider
        imageSource: "images/dividers/divider_quote.png"
        horizontalAlignment: HorizontalAlignment.Center
        topMargin: 0; bottomMargin: 0
        visible: false
    }
}