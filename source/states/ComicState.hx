package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;

class ComicState extends BaseState
{
	public static var COMIC_INDEX:Int = 0;

	var comicNames:Array<String> = ["SodaCutscene"];
	var actualComic:String;

	var imgLeft:FlxSprite;
	var imgCenter:FlxSprite;
	var imgRight:FlxSprite;
	var imgFull:FlxSprite;

	var comicState:Int = 0;

	override function create()
	{
		super.create();
		actualComic = comicNames[COMIC_INDEX];

		imgLeft = new FlxSprite(12, 12);
		imgCenter = new FlxSprite();
		imgRight = new FlxSprite();
		imgFull = new FlxSprite();

		imgLeft.visible = false;
		imgRight.visible = false;
		imgCenter.visible = false;
		imgFull.visible = false;

		add(imgLeft);
		add(imgCenter);
		add(imgRight);
		add(imgFull);

		// Comic inicial
		if (actualComic == comicNames[0])
			new FlxTimer().start(2, firstComic, 0);
	}

	function firstComic(tmr:FlxTimer)
	{
		switch (comicState)
		{
			case 0:
				imgLeft.loadGraphic(Paths.getImage("cutscenes/SodaCutscene0"));
				imgLeft.visible = true;
			case 1:
				imgCenter.loadGraphic(Paths.getImage("cutscenes/SodaCutscene1"), true, 60, 120);
				imgCenter.setPosition(imgLeft.x + imgLeft.width + 12, 12);
				imgCenter.animation.add("default", [0, 1], 2);
				imgCenter.animation.play("default");
				imgCenter.visible = true;
				imgLeft.alpha = .5;
			case 2:
				imgRight.loadGraphic(Paths.getImage("cutscenes/SodaCutscene2"), true, 60, 120);
				imgRight.setPosition(imgCenter.x + imgCenter.width + 12, 12);
				imgRight.animation.add("default", [0, 1], 2);
				imgRight.animation.play("default");
				imgRight.visible = true;
				imgCenter.alpha = .5;
				imgCenter.animation.stop();
			case 3:
				imgFull.loadGraphic(Paths.getImage("cutscenes/SodaCutscene3"));
				imgFull.visible = true;
				imgRight.alpha = .5;
				imgRight.animation.stop();
			case 4:
				imgLeft.visible = false;
				imgCenter.visible = false;
				imgRight.visible = false;
				imgFull.visible = false;

				imgLeft.alpha = 1;
				imgCenter.alpha = 1;
				imgRight.alpha = 1;
			case 5:
				imgLeft.loadGraphic(Paths.getImage("cutscenes/SodaCutscene4"), true, 60, 120);
				imgLeft.animation.add("default", [0, 1], 2);
				imgLeft.animation.play("default");
				imgLeft.visible = true;
			case 6:
				imgCenter.loadGraphic(Paths.getImage("cutscenes/SodaCutscene5"), true, 84, 120);
				imgCenter.setPosition(imgLeft.x + imgLeft.width + 12, 12);
				imgCenter.animation.add("default", [0, 1, 2], 2, false);
				imgCenter.animation.play("default");
				imgCenter.visible = true;
				imgLeft.alpha = .5;
				imgLeft.animation.stop();
				tmr.time = 3;
			case 7:
				imgRight.loadGraphic(Paths.getImage("cutscenes/SodaCutscene6"), true, 60, 120);
				imgRight.setPosition(imgCenter.x + imgCenter.width + 12, 12);
				imgRight.animation.add("default", [0, 1, 2], 2);
				imgRight.animation.play("default");
				imgRight.visible = true;
				imgCenter.alpha = .5;
				tmr.time = 4;
			case 8:
				FlxG.camera.fade(2, () -> FlxG.switchState(new MenuState()));
				tmr.cancel();
		}
		comicState++;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
