package
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import scaleform.gfx.Extensions;
	import scaleform.gfx.TextFieldEx;
	import Shared.AS3.BSButtonHintBar;
	import Shared.AS3.BSButtonHintData;
	import Shared.GlobalFunc;
	import Shared.IMenu;
	
	import Library.*;
	
	public class LockpickingMenu extends IMenu
	{
		// \===================/
		// | Public Properties |
		// /===================\
		
		public var ButtonHintBar_mc:BSButtonHintBar;
		
		public var Center_mc:MovieClip;
		public var DebugMenu_mc:MovieClip;
		public var InheritColorsBarMenu_mc:MovieClip;
		public var InheritColorsTicksMenu_mc:MovieClip;
		
		public var LockLevel_tf:TextField;
		public var PickCount_tf:TextField;
		
		// \====================/
		// | Private Properties |
		// /====================\
		
		// Buttons
		private var ToggleActiveButton:BSButtonHintData;
		private var ExitButton:BSButtonHintData;
		
		// Event parameters
		private var fMinPickAngle:Number = 0;
		private var fMaxPickAngle:Number = 0;
		
		private var fSweetSpot:Number;
		private var fSweetSpotWidth:Number;
		private var fPartialPickWidth:Number;
		
		private var sLockLevel:String;
		private var iPickCount:uint;
		
		private var fPickAngle:Number;
		private var fLockAngle:Number = 0;
		private var fPickHealth:Number;
		
		// User settings
		private var Settings:XMLSettings = new XMLSettings("../DeftHands.xml");
		
		private var bCheats:Boolean; // false = Ticks, true = Bar
		private var bHasBeenOpened:Boolean;
		private var bBarMenu:Boolean;
		private var fBarOffset:Number;
		private var fBarIndicatorOffset:Number;
		private var bTicksMenu:Boolean;
		private var fTickIndicatorOffset:Number;
		private var fAngle:Number;
		private var fBuffer:Number;
		private var fRadius:Number;
		private var fLength:Number;
		private var fLockOffsetX:Number;
		private var fLockOffsetY:Number;
		
		private var Ticks:Vector.<Tick>;
		
		
		
		// \=============/
		// | Constructor |
		// /=============\
		
		public function LockpickingMenu()
		{
			super();
			Extensions.enabled = true;
			
			ToggleActiveButton = new BSButtonHintData("$ToggleActive", "E", "PSN_A", "Xenon_A", 1, OnToggleActive);
			ExitButton = new BSButtonHintData("$EXIT", "Esc", "PSN_B", "Xenon_B", 1, OnExitPressed);
			PopulateButtonBar();
			
			TextFieldEx.setTextAutoSize(LockLevel_tf, "shrink");
		}
		
		
		
		// \========/
		// | Events |
		// /========\
		
		// Event sent from the IMenu superclass once SafeX and SafeY have been set
		override protected function onSetSafeRect() : void
		{
			// Position Center_mc
			GlobalFunc.LockToSafeRect(Center_mc, "CC", SafeX, SafeY);
		}
		
		// Event sent when the menu initializes
		public function SetPickMinMax(afMinPickAngle:Number, afMaxPickAngle:Number) : void
		{
			fMinPickAngle = afMinPickAngle + 270; // Convert min and max pick angles to unit circle
			fMaxPickAngle = afMaxPickAngle + 270;
		}
		
		// Event sent when the menu initializes
		public function InitLockpickingMenu() : void
		{
			SetSettings(); // Read settings from XML document
		}
		
		// Event sent when the menu initializes
		public function UpdateSweetSpot(afSweetSpot:Number, afSweetSpotWidth:Number, afPartialPickWidth:Number) : void
		{
			fSweetSpot = -afSweetSpot + 270; // Convert sweet spot to unit circle
			fSweetSpotWidth = afSweetSpotWidth;
			fPartialPickWidth = afPartialPickWidth;
			SetSweetSpotText();
			SetSweetSpotWidthText();
			SetPartialPickWidthText();
			
			TransformBar();
			CreateTicks();
			
			// If the default menu has been opened automatically then open it
			if (bHasBeenOpened)
			{
				OpenMenu();
			}
			
			SetToggleActiveButtonVisible();
			ExitButton.ButtonVisible = true;
		}
		
		// Event sent when the menu initializes or the pick breaks
		public function SetLockInfo(asLockLevel:String, aiPickCount:uint) : void
		{
			// \-----------/
			// | Variables |
			// /-----------\
			
			var tick:Tick;
			
			// \------------/
			// | Operations |
			// /------------\
			
			sLockLevel = asLockLevel;
			iPickCount = aiPickCount;
			SetLockLevelText();
			SetPickCountText();
			
			// If a pick has been broken (fPickAngle should be NaN on initialization)
			if (fPickAngle)
			{
				// Reset the length of each tick
				for each (tick in Ticks)
				{
					tick.scaleY = tick.length;
				}
				
				// If a tick represents the angle at which the pick was broken
				if (fMinPickAngle <= fPickAngle && fPickAngle <= fMaxPickAngle)
				{
					// Double the length of the tick that represents the angle at which the pick was broken
					for each (tick in Ticks)
					{
						// Check whether the pick angle is equal to both the lower and upper bounds to account for both the minimum and maximum pick angles
						// Break the loop to avoid potentially doubling the length of two neighbouring ticks
						if (tick.angleFrom <= fPickAngle && fPickAngle <= tick.angleTo)
						{
							tick.scaleY = 2 * tick.length;
							
							break;
						}
					}
				}
			}
			
			fPickAngle = 270; // Reset pick angle
			fPickHealth = 100; // Reset pick health
			SetPickAngleText();
			SetPickHealthText();
			
			TransformBarIndicator();
			TransformTickIndicator();
		}
		
		// Event sent when the player rotates the pick
		public function UpdatePickAngle(afPickAngle:Number) : void
		{
			fPickAngle = -afPickAngle + 270; // Convert pick angle to unit circle
			SetPickAngleText();
			
			TransformBarIndicator();
			TransformTickIndicator();
		}
		
		// Event sent when the player rotates the lock
		public function UpdateLockAngle(afLockAngle:Number) : void
		{
			// \-----------/
			// | Variables |
			// /-----------\
			
			var tick:Tick;
			
			// \------------/
			// | Operations |
			// /------------\
			
			// If the lock angle is either constant or increasing
			if (fLockAngle <= afLockAngle)
			{
				// If a tick represents the angle at which the pick is rotating the lock
				if (fMinPickAngle <= fPickAngle && fPickAngle <= fMaxPickAngle)
				{
					// Check each tick
					for each (tick in Ticks)
					{
						// If this tick represents the current pick angle then update the lock angle and reveal it
						// Check whether the pick angle is equal to both the lower and upper bounds to account for both the minimum and maximum pick angles
						// Break the loop to avoid potentially updating the lock angle of two neighbouring ticks
						if (tick.angleFrom <= fPickAngle && fPickAngle <= tick.angleTo)
						{
							tick.lockAngle = afLockAngle;
							tick.visible = true;
							
							break;
						}
					}
				}
			}
			
			fLockAngle = afLockAngle;
			SetLockAngleText();
		}
		
		// Event sent when the player forcefully rotates the lock
		public function UpdatePickHealth(afPickHealth:Number) : void
		{
			fPickHealth = afPickHealth;
			SetPickHealthText();
		}
		
		
		
		// Buttons
		public function ProcessUserEvent(asUserEventName:String, abButtonDown:Boolean) : Boolean
		{
			// \-----------/
			// | Variables |
			// /-----------\
			
			var processedUserEvent:Boolean;
			
			// \------------/
			// | Operations |
			// /------------\
			
			processedUserEvent = false;
			
			if (!abButtonDown)
			{
				if (asUserEventName == "Activate")
				{
					OnToggleActive();
					processedUserEvent = true;
				}
			}
			
			return processedUserEvent;
		}
		
		private function OnToggleActive() : void
		{
			// If the other menu is active and a menu has been opened
			// If the other menu is active and the current menu is not
			if ((!bCheats ? bBarMenu : bTicksMenu) && (bHasBeenOpened || !(bCheats ? bBarMenu : bTicksMenu)))
			{
				bCheats = !bCheats;
			}
			
			OpenMenu();
			SetToggleActiveButtonVisible();
		}
		
		private function OnExitPressed() : void
		{
		}
		
		
		
		// \=========/
		// | Methods |
		// /=========\
		
		private function PopulateButtonBar() : void
		{
			// \-----------/
			// | Variables |
			// /-----------\
			
			var buttons:Vector.<BSButtonHintData>;
			
			// \------------/
			// | Operations |
			// /------------\
			
			buttons = new Vector.<BSButtonHintData>();
			buttons.push(ToggleActiveButton);
			buttons.push(ExitButton);
			ButtonHintBar_mc.SetButtonHintData(buttons);
		}
		
		private function SetSettings() : void
		{
			bCheats = Settings.cheats;
			bHasBeenOpened = Settings.hasBeenOpened;
			bBarMenu = Settings.barMenu;
			fBarOffset = Settings.barOffset;
			fBarIndicatorOffset = Settings.barIndicatorOffset;
			bTicksMenu = Settings.ticksMenu;
			fTickIndicatorOffset = Settings.tickIndicatorOffset;
			fAngle = Settings.angle;
			fBuffer = Settings.buffer;
			fRadius = Settings.radius;
			fLength = Settings.length;
			fLockOffsetX = Settings.lockOffsetX;
			fLockOffsetY = Settings.lockOffsetY;
		}
		
		private function TransformBar() : void
		{
			// Position
			SweetSpotWidth_mc.x = PickAngleToX(fSweetSpot - (fSweetSpotWidth / 2), Mask_mc.x, Mask_mc.width);
			LeftPartialPickWidth_mc.x = PickAngleToX(fSweetSpot - (fSweetSpotWidth / 2) - fPartialPickWidth, Mask_mc.x, Mask_mc.width);
			RightPartialPickWidth_mc.x = PickAngleToX(fSweetSpot + (fSweetSpotWidth / 2) + fPartialPickWidth, Mask_mc.x, Mask_mc.width);
			
			BarMenu_mc.y = fBarOffset;
			InheritColorsBarMenu_mc.y = fBarOffset;
			
			// Scale
			SweetSpotWidth_mc.width = PickAngleToX(fSweetSpot + (fSweetSpotWidth / 2), Mask_mc.x, Mask_mc.width) - SweetSpotWidth_mc.x;
			LeftPartialPickWidth_mc.width = PickAngleToX(fSweetSpot - (fSweetSpotWidth / 2), Mask_mc.x, Mask_mc.width) - LeftPartialPickWidth_mc.x;
			RightPartialPickWidth_mc.width = RightPartialPickWidth_mc.x - PickAngleToX(fSweetSpot + (fSweetSpotWidth / 2), Mask_mc.x, Mask_mc.width);
			
			// Mask
			SweetSpot_mc.mask = Mask_mc;
		}
		
		private function PickAngleToX(afPickAngle:Number, afMinX:Number, afRangeX:Number) : Number
		{
			return afMinX + afRangeX * ((afPickAngle - fMinPickAngle) / (fMaxPickAngle - fMinPickAngle));
		}
		
		private function CreateTicks() : void
		{
			// \-----------/
			// | Variables |
			// /-----------\
			
			var angleFrom:Number;
			var angleTo:Number;
			var bufferFrom:Number;
			var bufferTo:Number;
			var tickAngle:Number;
			
			var tick:Tick;
			
			// \------------/
			// | Operations |
			// /------------\
			
			// If the Ticks vector already exists then remove each tick from the TicksMenu_mc container before it is emptied
			if (Ticks)
			{
				for each (tick in Ticks)
				{
					TicksMenu_mc.removeChild(tick);
				}
			}
			
			// Previous elements of the Ticks vector should now be garbage collected
			Ticks = new Vector.<Tick>();
			
			for (tickAngle = fMinPickAngle; tickAngle < fMaxPickAngle; tickAngle += fAngle)
			{
				angleFrom = tickAngle;
				angleTo = Math.min(tickAngle + fAngle, fMaxPickAngle);
				bufferFrom = Math.min(fBuffer / 2, fMaxPickAngle - tickAngle);
				bufferTo = Math.min(fBuffer / 2, Math.max(fMaxPickAngle - (tickAngle + fAngle - (fBuffer / 2)), 0));
				
				Ticks.push(new Tick(lockCenterX, lockCenterY, angleFrom, angleTo, bufferFrom, bufferTo, fRadius, fLength));
			}
			
			// Hide each tick and add it to the TicksMenu_mc container
			for each (tick in Ticks)
			{
				tick.visible = false;
				TicksMenu_mc.addChild(tick);
			}
		}
		
		private function OpenMenu() : void
		{
			bHasBeenOpened = true;
			
			// Bar
			BarMenu_mc.visible = bBarMenu ? bCheats : false; // If the Bar menu is active and cheats are enabled
			InheritColorsBarMenu_mc.visible = bBarMenu ? bCheats : false;
			
			// Ticks
			TicksMenu_mc.visible = bTicksMenu ? !bCheats : false; // If the Ticks menu is active and cheats are disabled
			InheritColorsTicksMenu_mc.visible = bTicksMenu ? !bCheats : false;
		}
		
		public function SetToggleActiveButtonVisible() : void
		{
			// If the current menu is active but has not been opened
			// If the other menu is active
			ToggleActiveButton.ButtonVisible = ((bCheats ? bBarMenu : bTicksMenu) && !bHasBeenOpened) || (!bCheats ? bBarMenu : bTicksMenu);
		}
		
		private function TransformBarIndicator() : void
		{
			// Position
			BarIndicator_mc.x = PickAngleToX(fPickAngle, ShadedBackground_mc.x, ShadedBackground_mc.width);
			BarIndicator_mc.y = -fBarIndicatorOffset;
		}
		
		private function TransformTickIndicator() : void
		{
			// \-----------/
			// | Variables |
			// /-----------\
			
			var thetaPickAngle:Number;
			
			// \------------/
			// | Operations |
			// /------------\
			
			thetaPickAngle = MathEx.DegreesToRadians(fPickAngle);
			
			// Position
			TickIndicator_mc.x = lockCenterX + (fRadius - fTickIndicatorOffset) * Math.cos(thetaPickAngle);
			TickIndicator_mc.y = lockCenterY + (fRadius - fTickIndicatorOffset) * Math.sin(thetaPickAngle);
			
			// Rotate
			TickIndicator_mc.rotation = fPickAngle + 90;
		}
		
		
		
		// Set text
		private function SetSweetSpotText() : void
		{
			GlobalFunc.SetText(DebugMenu_mc.SweetSpot_tf, "SWEET SPOT: " + fSweetSpot.toFixed(1) + "°", false);
		}
		
		private function SetSweetSpotWidthText() : void
		{
			GlobalFunc.SetText(DebugMenu_mc.SweetSpotWidth_tf, "SWEET SPOT WIDTH: " + fSweetSpotWidth.toFixed(1) + "°", false);
		}
		
		private function SetPartialPickWidthText() : void
		{
			GlobalFunc.SetText(DebugMenu_mc.PartialPickWidth_tf, "PARTIAL PICK WIDTH: " + fPartialPickWidth.toFixed(1) + "°", false);
		}
		
		private function SetLockLevelText() : void
		{
			GlobalFunc.SetText(LockLevel_tf, "$Lock", false);
			GlobalFunc.SetText(LockLevel_tf, (sLockLevel + " " + LockLevel_tf.text).toUpperCase(), false);
		}
		
		private function SetPickCountText() : void
		{
			GlobalFunc.SetText(PickCount_tf, "$Lockpicks Left", false);
			
			if (iPickCount < 100)
			{
				GlobalFunc.SetText(PickCount_tf, iPickCount + " " + PickCount_tf.text, false);
			}
			else
			{
				GlobalFunc.SetText(PickCount_tf, "99+ " + PickCount_tf.text, false);
			}
		}
		
		private function SetPickAngleText() : void
		{
			GlobalFunc.SetText(DebugMenu_mc.PickAngle_tf, "PICK ANGLE: " + Math.floor(fPickAngle) + "°", false);
		}
		
		private function SetLockAngleText() : void
		{
			GlobalFunc.SetText(DebugMenu_mc.LockAngle_tf, "LOCK ANGLE: " + Math.floor(fLockAngle) + "°", false);
		}
		
		private function SetPickHealthText() : void
		{
			GlobalFunc.SetText(DebugMenu_mc.PickHealth_tf, "PICK HEALTH: " + Math.floor(fPickHealth) + "%", false);
		}
		
		
		
		// \=========/
		// | Getters |
		// /=========\
		
		// Event parameters
		public function get minPickAngle() : Number
		{
			return fMinPickAngle;
		}
		
		public function get maxPickAngle() : Number
		{
			return fMaxPickAngle;
		}
		
		public function get sweetSpot() : Number
		{
			return fSweetSpot;
		}
		
		public function get sweetSpotWidth() : Number
		{
			return fSweetSpotWidth;
		}
		
		public function get partialPickWidth() : Number
		{
			return fPartialPickWidth;
		}
		
		public function get lockLevel() : String
		{
			return sLockLevel;
		}
		
		public function get pickCount() : uint
		{
			return iPickCount;
		}
		
		public function get pickAngle() : Number
		{
			return fPickAngle;
		}
		
		public function get lockAngle() : Number
		{
			return fLockAngle;
		}
		
		public function get pickHealth() : Number
		{
			return fPickHealth;
		}
		
		
		
		// BarMenu_mc
		public function get BarMenu_mc() : MovieClip
		{
			return (stage.getChildAt(0) as MovieClip).BarMenu_mc;
		}
		
		public function get SweetSpot_mc() : MovieClip
		{
			return BarMenu_mc.SweetSpot_mc;
		}
		
		public function get SweetSpotWidth_mc() : MovieClip
		{
			return SweetSpot_mc.SweetSpotWidth_mc;
		}
		
		public function get LeftPartialPickWidth_mc() : MovieClip
		{
			return SweetSpot_mc.LeftPartialPickWidth_mc;
		}
		
		public function get RightPartialPickWidth_mc() : MovieClip
		{
			return SweetSpot_mc.RightPartialPickWidth_mc;
		}
		
		public function get Mask_mc() : MovieClip
		{
			return SweetSpot_mc.Mask_mc;
		}
		
		// InheritColorsBarMenu_mc
		public function get BarIndicator_mc() : MovieClip
		{
			return InheritColorsBarMenu_mc.PickIndicator_mc;
		}
		
		public function get Brackets_mc() : MovieClip
		{
			return InheritColorsBarMenu_mc.Brackets_mc;
		}
		
		public function get ShadedBackground_mc() : MovieClip
		{
			return Brackets_mc.ShadedBackground_mc;
		}
		
		// TicksMenu_mc
		public function get TicksMenu_mc() : MovieClip
		{
			return (stage.getChildAt(0) as MovieClip).TicksMenu_mc;
		}
		
		// InheritColorsTicksMenu_mc
		public function get TickIndicator_mc() : MovieClip
		{
			return InheritColorsTicksMenu_mc.PickIndicator_mc;
		}
		
		
		
		public function get lockCenterX() : Number
		{
			return Center_mc.x + fLockOffsetX;
		}
		
		public function get lockCenterY() : Number
		{
			return Center_mc.y + fLockOffsetY;
		}
	}
}
