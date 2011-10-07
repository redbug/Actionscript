package
{
	import flash.display.Sprite;
	
	public class Main extends Sprite
	{
		public function Main()
		{
			example5();
		}
		
		private function example5():void
		{
			var htmlNS:Namespace = new Namespace("html", "http://www.w3.org/1999/xhtml");
			var shopNS:Namespace = new Namespace("shop", "http://example.com/furniture");
			
			default xml namespace = htmlNS;
			
			var catalog:XML = <html/>;
			
			catalog.addNamespace(shopNS);
			
			
			catalog.head.title = "Catalog";
			catalog.body.shopNS::table = "";
			catalog.body.shopNS::table.@shopNS::id = "4875";
			catalog.body.shopNS::table.table = "";
			catalog.body.shopNS::table.table.@border = "1";
			catalog.body.shopNS::table.table.tr.td = "Item";
			catalog.body.shopNS::table.table.tr.td[1] = "Price";
			trace(catalog.toXMLString());

		}
		
		
		private function example4():void
		{
			var staff:XML = 
					<STAFF>
						<EMPLOYEE ID="501" HIRED="1090728000000">
							<NAME>Marco Crawley</NAME>
							<MANAGER>James Porter</MANAGER>
							<SALARY>25000</SALARY>
							<POSITION>Designer</POSITION>
						</EMPLOYEE>
						<EMPLOYEE ID="500" HIRED="1078462800000">
							<NAME>Graham Barton</NAME>
							<MANAGER>James Porter</MANAGER>
							<SALARY>35000</SALARY>
							<POSITION>Designer</POSITION>
						</EMPLOYEE>
						<EMPLOYEE ID="238" HIRED="1014699600000">
							<NAME>James Porter</NAME>
							<MANAGER>Dorian Schapiro</MANAGER>
							<SALARY>55000</SALARY>
							<POSITION>Manager</POSITION>
						</EMPLOYEE>
					</STAFF>		

//			staff.EMPLOYEE[0] = <BOSS> <A> KKK </A> </BOSS>;
			staff.replace("EMPLOYEE[1]", <BOSS> <A> KKK </A> </BOSS>);
			staff.prependChild(<GG> kkkk </GG>);
			staff.insertChildBefore(staff.*[0], <AA>gg</AA>);			
			staff.*[0] = <CC>cc</CC> + staff.*[0];
			trace(staff);
				
		}
		
		private function example3():void
		{
			var books:XML = 
				<BOOKS>
					<BOOK ISBN="1234567"/>
					<BOOK ISBN="2222222"/>
					<BOOK ISBN="3333333"/>
					<BOOK/>
				</BOOKS>
				
			var order:XML = <ORDER ITEMS=""/>;
			order.@ITEMS = books.*.@ISBN;
			trace(order.toXMLString());
			trace(order.@ITEMS);
		}
		
		/****************************************
		 * test XML filter
		 ****************************************/
		private function example2():void
		{
			var staff:XML = <STAFF>
								<EMPLOYEE ID="501" HIRED="1090728000000">
									<NAME>Marco Crawley</NAME>
									<MANAGER>James Porter</MANAGER>
									<SALARY>25000</SALARY>
									<POSITION>Designer</POSITION>
								</EMPLOYEE>
								<EMPLOYEE ID="500" HIRED="1078462800000">
									<NAME>Graham Barton</NAME>
									<MANAGER>James Porter</MANAGER>
									<SALARY>35000</SALARY>
									<POSITION>Designer</POSITION>
								</EMPLOYEE>
								<EMPLOYEE ID="238" HIRED="1014699600000">
									<NAME>James Porter</NAME>
									<MANAGER>Dorian Schapiro</MANAGER>
									<SALARY>55000</SALARY>
									<POSITION>Manager</POSITION>
								</EMPLOYEE>
							</STAFF>
			
				
				
			var allEmployees:XMLList = staff.*;
			var employeesUnderJames:XMLList = allEmployees.(MANAGER == "James Porter");
//			trace(employeesUnderJames);
//			trace(staff.*.(@ID == "238"));
//			trace(new Date(Number(staff.*.(NAME == "Graham Barton").@HIRED)));
//			trace(staff.*.(NAME == "Graham Barton").*[2]);
			
		}
		
		private function example1():void
		{
			var rootName			:String = "BOOK";
			var rootAttributeName	:String = "ISBN";
			var ISBN				:String = "123456789";
			var titleName			:String = "Actionscript Cookbook";	

			
			XML.ignoreComments = false;
			XML.ignoreProcessingInstructions = false;
			
			var novel:XML = 
				<{rootName} {rootAttributeName}={ISBN} INSTOCK="false">
					<!-- This is comment -->
					<?app1 someData?>
					<TITLE>	{titleName} </TITLE>
					<AUTHOR> Bill Gaze </AUTHOR>
					<?app2 someData?>
					<AUTHOR size="A"> Redbug </AUTHOR>
					<PUBLISHER> Prinston </PUBLISHER>
					<!-- Goodbye -->
				</{rootName}>;
			
			trace(novel..*);
			
			
			novel.AUTHOR[0].setName("WRITER");
			novel.TITLE.setName("TOPIC");
			
			trace(novel.comments()[1]);
			trace(novel.processingInstructions()[1]);

			if(novel.@INSTOCK.toLowerCase() == "false"){
				trace("unavailible");
			}else{
				trace("availible");
			}

//			trace(novel.AUTHOR.@*);
//			var author:XML = novel.TOPIC[0];			
//			
//			trace("previous Sibling:" + previousSibling(author));
//			trace("previous Sibling:" + nextSibling(author));


//			trace(novel.*.text());
//			trace(novel.TOPIC.*[0].nodeKind());
//			trace(novel.AUTHOR.*[0].nodeKind());
//			trace(novel.AUTHOR.*[0].toString());
//			trace(novel.AUTHOR.*[0].parent());
//			trace(novel.AUTHOR.*[0].parent().parent());

//			trace(novel.child("AUTHOR")[0].children()[0].nodeKind());
//			trace(novel.child("AUTHOR")[0].parent());
//			trace(novel.child("AUTHOR")[0].toString());


//			trace(novel.child("AUTHOR")[1]);
//			trace(novel.child("AUTHOR"));
//			trace(novel.children()[0]);
//			trace(novel.*[1]);
//			trace(novel.children());
//			trace(novel.*);			
//			trace(novel.toString());
//			trace(novel.toXMLString());		
		}
		
		private function getRoot(childNode:XML):XML
		{
			var parentNode:XML = childNode.parent();
	
			if(parentNode != null){
				return getRoot(parentNode);
			}else{
				return childNode;
			}
		}
		
		private function previousSibling(theNode:XML):XML
		{
			if(theNode.parent() != null && theNode.childIndex() > 0){
				return theNode.parent().*[theNode.childIndex()-1];
			}
			else{
				return null;
			}
		}

		private function nextSibling(theNode:XML):XML
		{
			if(theNode.parent() != null && theNode.childIndex() != theNode.parent().*.length() - 1 ){
				return theNode.parent().*[theNode.childIndex() + 1];
			}
			else{
				return null;
			}
		}
		
	}
}