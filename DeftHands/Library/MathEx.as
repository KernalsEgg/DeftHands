package Library
{
	public class MathEx
	{
		public static function DegreesToRadians(afDegrees:Number) : Number
		{
			return (afDegrees / 180) * Math.PI;
		}
		
		public static function RadiansToDegrees(afRadians:Number) : Number
		{
			return 180 * (afRadians / Math.PI);
		}
	}
}
