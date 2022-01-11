package external;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;

/**
 * ...
 * @author Ohmnivore
 */
class ArtifactFix
{
	public static var SPACING_X:Int = 2;
	public static var SPACING_Y:Int = 2;
	public static var START_X:Int = Std.int(SPACING_X / 2);
	public static var START_Y:Int = Std.int(SPACING_Y / 2);
	public static var COLUMN_SIZE_X:Int = START_X;
	public static var COLUMN_SIZE_Y:Int = START_Y;

	static public function artifactFix(Graphic:Dynamic, FrameWidth:Int, FrameHeight:Int):FlxTileFrames
	{
		var cached:FlxGraphic = FlxG.bitmap.add(Graphic, false);

		var cont:BitmapData = ArtifactFix.returnContainer(cached.bitmap.width, cached.bitmap.height, FrameWidth, FrameHeight);
		ArtifactFix.placeTiles(cached.bitmap, cont, FrameWidth, FrameHeight);
		ArtifactFix.placeSafePixelColumn(cached.bitmap, cont, FrameWidth, FrameHeight);

		var newcached:FlxGraphic = FlxG.bitmap.add(cont, true);

		// tile size
		var tileSize:FlxPoint = new FlxPoint(FrameWidth, FrameHeight);
		// tile spacing
		var tileSpacing:FlxPoint = new FlxPoint(SPACING_X, SPACING_Y);
		// region of image to use for tiles (optional)
		var region:FlxRect = new FlxRect(START_X, START_Y, cont.width - START_X, cont.height - START_Y);

		return FlxTileFrames.fromRectangle(newcached, tileSize, region, tileSpacing);
	}

	static public function placeSafePixelColumn(Source:BitmapData, Dest:BitmapData, TileWidth:Int, TileHeight:Int):Void
	{
		var x_tot:Int = Std.int(Source.width / TileWidth);
		var y_tot:Int = Std.int(Source.height / TileHeight);
		var x_count:Int = 0;
		var y_count:Int = 0;

		while (x_count < x_tot)
		{
			while (y_count < y_tot)
			{
				// To the left
				var rect1:Rectangle = new Rectangle(x_count * TileWidth, y_count * TileHeight, COLUMN_SIZE_X, TileHeight);
				var point1:Point = new Point(START_X + x_count * (TileWidth + SPACING_X) - COLUMN_SIZE_X, START_Y + y_count * (TileHeight + SPACING_Y));
				Dest.copyPixels(Source, rect1, point1, true);

				// To the right
				var rect2:Rectangle = new Rectangle((x_count + 1) * TileWidth - COLUMN_SIZE_X, y_count * TileHeight, COLUMN_SIZE_X, TileHeight);
				var point2:Point = new Point(START_X + (x_count + 1) * (TileWidth + SPACING_X) - SPACING_X, START_Y + y_count * (TileHeight + SPACING_Y));
				Dest.copyPixels(Source, rect2, point2, true);

				// To the top
				var rect3:Rectangle = new Rectangle(x_count * TileWidth, y_count * TileHeight, TileWidth, COLUMN_SIZE_Y);
				var point3:Point = new Point(START_X + x_count * (TileWidth + SPACING_X), START_Y + y_count * (TileHeight + SPACING_Y) - COLUMN_SIZE_Y);
				Dest.copyPixels(Source, rect3, point3, true);

				// To the bottom
				var rect4:Rectangle = new Rectangle(x_count * TileWidth, (y_count + 1) * TileWidth - COLUMN_SIZE_Y, TileWidth, COLUMN_SIZE_Y);
				var point4:Point = new Point(START_X + x_count * (TileWidth + SPACING_X), START_Y + (y_count + 1) * (TileHeight + SPACING_Y) - SPACING_Y);
				Dest.copyPixels(Source, rect4, point4, true);

				y_count++;
			}

			y_count = 0;
			x_count++;
		}
	}

	static public function placeTiles(Source:BitmapData, Dest:BitmapData, TileWidth:Int, TileHeight:Int):Void
	{
		var x_tot:Int = Std.int(Source.width / TileWidth);
		var y_tot:Int = Std.int(Source.height / TileHeight);
		var x_count:Int = 0;
		var y_count:Int = 0;

		while (x_count < x_tot)
		{
			while (y_count < y_tot)
			{
				var rect:Rectangle = new Rectangle(x_count * TileWidth, y_count * TileHeight, TileWidth, TileHeight);
				var point:Point = new Point(START_X + x_count * TileWidth + x_count * SPACING_X, START_Y + y_count * TileHeight + y_count * SPACING_Y);
				Dest.copyPixels(Source, rect, point, true);

				y_count++;
			}

			y_count = 0;
			x_count++;
		}
	}

	static public function returnContainer(Width:Int, Height:Int, TileWidth:Int, TileHeight:Int):BitmapData
	{
		var width:Int = Width + (Std.int(Width / TileWidth) - 1) * SPACING_X + START_X * 2;
		var height:Int = Height + (Std.int(Height / TileHeight) - 1) * SPACING_Y + START_Y * 2;

		return new BitmapData(width, height, true, 0x00ffffff);
	}
}
