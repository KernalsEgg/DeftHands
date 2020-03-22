package Library
{
	import System.XML.*;
	
	public class XMLSettings
	{
		// \====================/
		// | Private Properties |
		// /====================\
		
		// \-----------/
		// | Constants |
		// /-----------\
		
		private const CHEATS:Vector.<XMLElement> = new <XMLElement>[new XMLElement("Menu", new <XMLAttribute>[new XMLAttribute("Name", "Default")])];
		private const HAS_BEEN_OPENED:Vector.<XMLElement> = new <XMLElement>[new XMLElement("Open")];
		
		private const BAR_MENU_PARENT:XMLElement = new XMLElement("Menu", new <XMLAttribute>[new XMLAttribute("Name", "Bar")]);
		private const BAR_MENU:Vector.<XMLElement> = new <XMLElement>[BAR_MENU_PARENT, new XMLElement("Active")];
		private const BAR_OFFSET:Vector.<XMLElement> = new <XMLElement>[BAR_MENU_PARENT, new XMLElement("BarOffset")];
		private const BAR_INDICATOR_OFFSET:Vector.<XMLElement> = new <XMLElement>[BAR_MENU_PARENT, new XMLElement("IndicatorOffset")];
		
		private const TICKS_MENU_PARENT:XMLElement = new XMLElement("Menu", new <XMLAttribute>[new XMLAttribute("Name", "Ticks")]);
		private const TICKS_MENU:Vector.<XMLElement> = new <XMLElement>[TICKS_MENU_PARENT, new XMLElement("Active")];
		private const TICK_INDICATOR_OFFSET:Vector.<XMLElement> = new <XMLElement>[TICKS_MENU_PARENT, new XMLElement("IndicatorOffset")];
		private const ANGLE:Vector.<XMLElement> = new <XMLElement>[TICKS_MENU_PARENT, new XMLElement("Angle")];
		private const BUFFER:Vector.<XMLElement> = new <XMLElement>[TICKS_MENU_PARENT, new XMLElement("Buffer")];
		private const RADIUS:Vector.<XMLElement> = new <XMLElement>[TICKS_MENU_PARENT, new XMLElement("Radius")];
		private const LENGTH:Vector.<XMLElement> = new <XMLElement>[TICKS_MENU_PARENT, new XMLElement("Length")];
		private const LOCK_OFFSET_X:Vector.<XMLElement> = new <XMLElement>[TICKS_MENU_PARENT, new XMLElement("LockOffsetX")];
		private const LOCK_OFFSET_Y:Vector.<XMLElement> = new <XMLElement>[TICKS_MENU_PARENT, new XMLElement("LockOffsetY")];
		
		// \-----------/
		// | Variables |
		// /-----------\
		
		private var Settings:XMLDocument;
		
		private var fMinAngle:Number = 0.5;
		private var fMaxAngle:Number = 90.0;
		
		
		
		// \=============/
		// | Constructor |
		// /=============\
		
		public function XMLSettings(asXMLPath:String)
		{
			Settings = new XMLDocument(asXMLPath);
		}
		
		
		
		// \=========/
		// | Getters |
		// /=========\
		
		public function get cheats() : Boolean
		{
			return Boolean(uint(Settings.GetValue(CHEATS)));
		}
		
		public function get hasBeenOpened() : Boolean
		{
			return Boolean(uint(Settings.GetValue(HAS_BEEN_OPENED)));
		}
		
		public function get barMenu() : Boolean
		{
			return Boolean(uint(Settings.GetValue(BAR_MENU)));
		}
		
		public function get barOffset() : Number
		{
			return Number(Settings.GetValue(BAR_OFFSET));
		}
		
		public function get barIndicatorOffset() : Number
		{
			return Number(Settings.GetValue(BAR_INDICATOR_OFFSET));
		}
		
		public function get ticksMenu() : Boolean
		{
			return Boolean(uint(Settings.GetValue(TICKS_MENU)));
		}
		
		public function get tickIndicatorOffset() : Number
		{
			return Number(Settings.GetValue(TICK_INDICATOR_OFFSET));
		}
		
		public function get angle() : Number
		{
			return Math.min(Math.max(Number(Settings.GetValue(ANGLE)), fMinAngle), fMaxAngle);
		}
		
		public function get buffer() : Number
		{
			return Math.min(Math.max(Number(Settings.GetValue(BUFFER)), 0), angle - fMinAngle);
		}
		
		public function get radius() : Number
		{
			return Math.max(Number(Settings.GetValue(RADIUS)), 0);
		}
		
		public function get length() : Number
		{
			return Math.max(Number(Settings.GetValue(LENGTH)), 0);
		}
		
		public function get lockOffsetX() : Number
		{
			return Number(Settings.GetValue(LOCK_OFFSET_X));
		}
		
		public function get lockOffsetY() : Number
		{
			return -Number(Settings.GetValue(LOCK_OFFSET_Y)); // Invert y-axis
		}
	}
}
