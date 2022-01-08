package util;

import flixel.util.FlxTimer;

class Timer
{
	static var TOTAL_TIME:Int = 0;
	static var LEVEL_TIME:Int = 0;
	static var FTIMER:FlxTimer;
	static var COUNTDOWN:Bool = false;

	static function counter(_hud:HUD)
	{
		TOTAL_TIME++;
		LEVEL_TIME = COUNTDOWN ? LEVEL_TIME - 1 : LEVEL_TIME + 1;

		if (_hud != null)
			_hud.updateTimer(minutes, seconds);
	}

	static public var minutes(get, null):Int;

	static function get_minutes()
	{
		return Math.floor(LEVEL_TIME / 60);
	}

	static public var seconds(get, null):Int;

	static function get_seconds()
	{
		return LEVEL_TIME - (minutes * 60);
	}

	static public function start(_hud:HUD = null, _time:Int = 0)
	{
		if (FTIMER == null || FTIMER.manager != null)
		{
			if (_time > 0)
			{
				COUNTDOWN = true;
				LEVEL_TIME = _time;
			}
			else
			{
				COUNTDOWN = false;
				LEVEL_TIME = 0;
			}

			FTIMER = new FlxTimer().start(1, (tmr) -> counter(_hud), 0);

			if (_hud != null)
				_hud.updateTimer(minutes, seconds);
		}
		else
			FTIMER.active = true;
	}

	static public var isCountdown(get, null):Bool;

	static function get_isCountdown()
	{
		return COUNTDOWN;
	}

	static public function stop()
	{
		FTIMER.active = false;
	}

	static public function restart()
	{
		TOTAL_TIME = 0;
	}
}
