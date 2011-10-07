package
{
    import flash.display.Sprite;
    
    public class BasicText extends Sprite
    {
        public function BasicText()
        {
            test2();
        }
        
        public function test2():void
        {
            var htmlNS:Namespace = new Namespace("html", "http://www.w3.org/1999/xhtml");
            var shopNS:Namespace = new Namespace("shop", "http://example.com/furniture");
            
            //			var xml:Namespace = new Namespace("xml", "http://www.w3.org/XML/1998/namespace");
            
            default xml namespace = htmlNS;
            
            var catalog:XML = <html/>;
            
            
            //			catalog.addNamespace(htmlNS);
            catalog.addNamespace(shopNS);
            
            
            catalog.head.title = "Catalog";
            catalog.body.shopNS::table = "";
            catalog.body.shopNS::table.@shopNS::id = "4875";
            catalog.body.shopNS::table.table = "";
            catalog.body.shopNS::table.table.@border = "1";
            
            catalog.body.shopNS::table.table.appendChild(<tr></tr>);
            catalog.body.shopNS::table.table.tr.appendChild(<td></td>);
            catalog.body.shopNS::table.table.tr.td = "Item";
            catalog.body.shopNS::table.table.tr.appendChild(<td></td>);
            catalog.body.shopNS::table.table.tr.td[1] = "Price";
            catalog.body.shopNS::table.table.tr.@align = "center";
            
            catalog.body.shopNS::table.table.appendChild(<tr></tr>);
            catalog.body.shopNS::table.table.tr[1].@align = "left";
            
            catalog.body.shopNS::table.table.tr[1].td.shopNS::desc = "3-legged Coffee Table";
            catalog.body.shopNS::table.table.tr[1].td[1] = "";
            catalog.body.shopNS::table.table.tr[1].td[1].shopNS::price = "79.99";
            
            trace(catalog.toXMLString());
            
        }
        
        
        
        public function test1():void
        {
            var htmlNS:Namespace = new Namespace("html", "http://www.w3.org/1999/xhtml");
            var shopNS:Namespace = new Namespace("shop", "http://example.com/furniture");
            
            //			var xml:Namespace = new Namespace("xml", "http://www.w3.org/XML/1998/namespace");
            
            default xml namespace = htmlNS;
            
            var catalog:XML = <html/>;
            
            
            //			catalog.addNamespace(htmlNS);
            catalog.addNamespace(shopNS);
            
            
            catalog.head.title = "Catalog";
            catalog.body.shopNS::table = "";
            catalog.body.shopNS::table.@shopNS::id = "4875";
            catalog.body.shopNS::table.table = "";
            catalog.body.shopNS::table.table.@border = "1";
            
            catalog.body.shopNS::table.table.tr= "";
            catalog.body.shopNS::table.table.tr.td = "Item";
            catalog.body.shopNS::table.table.tr.td += <td/>;
            catalog.body.shopNS::table.table.tr.td[1] = "Price";
            catalog.body.shopNS::table.table.tr.td[1] += <td/>;
            catalog.body.shopNS::table.table.tr.@align = "center";
            catalog.body.shopNS::table.table.tr += <tr/>;
            
            catalog.body.shopNS::table.table.tr[1] = "";
            catalog.body.shopNS::table.table.tr[1].@align = "left";
            catalog.body.shopNS::table.table.tr[1] += <tr/>;
            
            catalog.body.shopNS::table.table.tr[1].td.shopNS::desc = "3-legged Coffee Table";
            catalog.body.shopNS::table.table.tr[1].td[1] = "";
            catalog.body.shopNS::table.table.tr[1].td[1].shopNS::price = "79.99";
            
            trace(catalog.toXMLString());
            
        }
        
        
    }
}