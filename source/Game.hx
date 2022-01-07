import flixel.FlxG;

class Game
{
	public static inline var PIXEL_PERFECT:Bool = false;
	public static inline var REAL_WIDTH:Int = 256;
	public static inline var REAL_HEIGHT:Int = 144;

	public static function initialize()
	{
		Fonts.loadBitmapFonts();

		#if !mobile
		FlxG.mouse.visible = false;
		#end

		#if desktop
		FlxG.save.bind("settings");

		if (FlxG.save.data.fullScreen == null)
			FlxG.save.data.fullScreen = false;
		else
			FlxG.fullscreen = FlxG.save.data.fullScreen;

		if (FlxG.save.data.soundsEnabled == null)
			FlxG.save.data.soundsEnabled = true;
		else
			FlxG.sound.muted = FlxG.save.data.soundsEnabled;

		if (FlxG.save.data.detectGamepad == null)
			FlxG.save.data.detectGamepad = true;
		else
			Input.detectGamepad = FlxG.save.data.detectGamepad;
		#end
	}
}
