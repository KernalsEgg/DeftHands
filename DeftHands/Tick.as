package
{
	import flash.display.MovieClip;
	
	import Library.*;
	
	public class Tick extends MovieClip
	{
		// \====================/
		// | Private Properties |
		// /====================\
		
		// User settings
		private var fCenterX:Number;
		private var fCenterY:Number;
		private var fAngleFrom:Number;
		private var fAngleTo:Number;
		private var fBufferFrom:Number;
		private var fBufferTo:Number;
		private var fRadius:Number;
		private var fLength:Number;
		
		// Greatest lock angle
		private var fLockAngle:Number = 0;
		
		
		
		// \=============/
		// | Constructor |
		// /=============\
		
		public function Tick(afCenterX:Number, afCenterY:Number, afAngleFrom:Number, afAngleTo:Number, afBufferFrom:Number, afBufferTo:Number, afRadius:Number, afLength:Number)
		{
			stop(); // Stop shape tween
			
			fCenterX = afCenterX;
			fCenterY = afCenterY;
			fAngleFrom = afAngleFrom;
			fAngleTo = afAngleTo;
			fBufferFrom = afBufferFrom;
			fBufferTo = afBufferTo;
			fRadius = afRadius;
			fLength = afLength;
			
			TransformTick();
		}
		
		
		
		// \=========/
		// | Methods |
		// /=========\
		
		private function TransformTick() : void
		{
			// \-----------/
			// | Variables |
			// /-----------\
			
			var thetaAngleFrom:Number;
			var thetaAngleTo:Number;
			var thetaBufferFrom:Number;
			var thetaBufferTo:Number;
			
			// \------------/
			// | Operations |
			// /------------\
			
			thetaAngleFrom = MathEx.DegreesToRadians(fAngleFrom);
			thetaAngleTo = MathEx.DegreesToRadians(fAngleTo);
			thetaBufferFrom = MathEx.DegreesToRadians(fBufferFrom);
			thetaBufferTo = MathEx.DegreesToRadians(fBufferTo);
			
			// Position
			x = fCenterX + fRadius * Math.cos(thetaAngleFrom + thetaBufferFrom); // Math.cos returns the x position in a unit circle for a given angle
			y = fCenterY + fRadius * Math.sin(thetaAngleFrom + thetaBufferFrom); // Math.sin returns the y position in a unit circle for a given angle
			
			// Rotate
			rotation = MathEx.RadiansToDegrees(Math.atan2(fRadius * (Math.sin(thetaAngleTo - thetaBufferTo) - Math.sin(thetaAngleFrom + thetaBufferFrom)), fRadius * (Math.cos(thetaAngleTo - thetaBufferTo) - Math.cos(thetaAngleFrom + thetaBufferFrom)))); // Math.atan2 returns the angle between (0, 0) and (y, x)
			
			// Scale
			scaleX = Math.sqrt(Math.pow(fRadius * (Math.cos(thetaAngleTo - thetaBufferTo) - Math.cos(thetaAngleFrom + thetaBufferFrom)), 2) + Math.pow(fRadius * (Math.sin(thetaAngleTo - thetaBufferTo) - Math.sin(thetaAngleFrom + thetaBufferFrom)), 2)); // The distance between (x1, y1) and (x2, y2)
			scaleY = fLength;
		}
		
		
		
		// \=========/
		// | Getters |
		// /=========\
		
		// User settings
		public function get centerX() : Number
		{
			return fCenterX;
		}
		
		public function get centerY() : Number
		{
			return fCenterY;
		}
		
		public function get angleFrom() : Number
		{
			return fAngleFrom;
		}
		
		public function get angleTo() : Number
		{
			return fAngleTo;
		}
		
		public function get bufferFrom() : Number
		{
			return fBufferFrom;
		}
		
		public function get bufferTo() : Number
		{
			return fBufferTo;
		}
		
		public function get radius() : Number
		{
			return fRadius;
		}
		
		public function get length() : Number
		{
			return fLength;
		}
		
		
		
		public function get lockAngle() : Number
		{
			return fLockAngle;
		}
		
		
		
		// \=========/
		// | Setters |
		// /=========\
		
		public function set lockAngle(afLockAngle:Number) : void
		{
			if (fLockAngle < afLockAngle)
			{
				gotoAndStop(Math.ceil(afLockAngle) + 1); // Lock angle range: 0 - 90, Frame range: 1 - 91
				fLockAngle = afLockAngle;
			}
		}
	}
}
