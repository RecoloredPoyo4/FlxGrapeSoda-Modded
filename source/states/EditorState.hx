package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxRect;
import flixel.text.FlxBitmapText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

enum EditorMode
{
	Tilemap;
	Entity;
	Menu;
}

class EditorState extends BaseState
{
	var tilemapUI:FlxGroup;
	var entityUI:FlxGroup;
	var menuUI:FlxGroup;

	var levelMap:FlxTypedGroup<FlxTilemap>;
	var highlightBox:FlxSprite;
	var highlightBorders:FlxSprite;
	var tileSelectedSprite:FlxSprite;

	var sprLayer2:FlxSprite;
	var sprLayer1:FlxSprite;
	var sprLayer0:FlxSprite;

	var selectedTile(default, set):Int = 1;
	var selectedLayer(default, set):Int = 2;
	var offsetTiles(default, set):Int = 0;
	var offsetTilesY(default, set):Int = 0;
	var textPos:FlxBitmapText;

	var exited:Bool = false;
	var editorState:EditorMode = Tilemap;

	// Map Editor functions!
	function set_selectedTile(_newTile)
	{
		tileSelectedSprite.animation.frameIndex = _newTile;
		return selectedTile = _newTile;
	}

	function set_selectedLayer(_newLayer)
	{
		selectedLayer = _newLayer;
		selectedTile = 1;
		setLayerTilePreview();
		return selectedLayer;
	}

	function set_offsetTiles(_newOffset)
	{
		levelMap.forEach((tilemap) -> tilemap.x = _newOffset * 12);
		highlightBorders.x = _newOffset * 12;
		return offsetTiles = _newOffset;
	}

	function set_offsetTilesY(_newOffset)
	{
		levelMap.forEach((tilemap) -> tilemap.y = _newOffset * 12);
		highlightBorders.y = _newOffset * 12;
		return offsetTilesY = _newOffset;
	}

	function setLayerTilePreview()
	{
		var path:String = null;

		switch (selectedLayer)
		{
			case 0:
				path = Paths.getImage("tilemaps/backgrass");
				sprLayer2.animation.frameIndex = 1;
				sprLayer1.animation.frameIndex = 1;
				sprLayer0.animation.frameIndex = 0;
			case 1:
				path = Paths.getImage("tilemaps/objects");
				sprLayer2.animation.frameIndex = 1;
				sprLayer1.animation.frameIndex = 0;
				sprLayer0.animation.frameIndex = 1;
			case 2:
				path = Paths.getImage("tilemaps/grass");
				sprLayer2.animation.frameIndex = 0;
				sprLayer1.animation.frameIndex = 1;
				sprLayer0.animation.frameIndex = 1;
		}

		tileSelectedSprite.loadGraphic(path, true, 12, 12);
		tileSelectedSprite.animation.frameIndex = selectedLayer == 2 ? 0 : selectedTile;
	}

	public function createMap()
	{
		var testMap = [for (i in 0...Game.MAP_WIDTH * Game.MAP_HEIGHT) 0];

		if (levelMap != null)
		{
			levelMap.forEach((tilemap) -> tilemap.destroy());
			levelMap.clear();
			highlightBorders.makeGraphic(Game.MAP_WIDTH * 12, Game.MAP_HEIGHT * 12, FlxColor.TRANSPARENT);
			FlxSpriteUtil.drawRect(highlightBorders, 0, 0, Game.MAP_WIDTH * 12, Game.MAP_HEIGHT * 12, FlxColor.TRANSPARENT, {color: FlxColor.RED});
		}
		else
		{
			levelMap = new FlxTypedGroup<FlxTilemap>();
			add(levelMap);
		}

		var layer2 = new FlxTilemap();
		layer2.loadMapFromArray(testMap, Game.MAP_WIDTH, Game.MAP_HEIGHT, Paths.getImage("tilemaps/backgrass"), Game.TILE_WIDTH, Game.TILE_HEIGHT);
		levelMap.add(layer2);

		var layer1 = new FlxTilemap();
		layer1.loadMapFromArray(testMap, Game.MAP_WIDTH, Game.MAP_HEIGHT, Paths.getImage("tilemaps/objects"), Game.TILE_WIDTH, Game.TILE_HEIGHT);
		levelMap.add(layer1);

		var layer0 = new FlxTilemap();
		layer0.loadMapFromArray(testMap, Game.MAP_WIDTH, Game.MAP_HEIGHT, Paths.getImage("tilemaps/grass"), Game.TILE_WIDTH, Game.TILE_HEIGHT, FULL);
		levelMap.add(layer0);

		offsetTiles = 0;
		offsetTilesY = 0;
	}

	function onEditorUpdate()
	{
		// Selector y función para colocar y sacar
		var mouseX = Std.int(FlxG.mouse.x / Game.TILE_WIDTH) - offsetTiles;
		var mouseY = Std.int(FlxG.mouse.y / Game.TILE_HEIGHT) - offsetTilesY;
		var levelSize = new FlxRect(offsetTiles * 12, offsetTilesY * 12, (Game.MAP_WIDTH * 12) - 1, (Game.MAP_HEIGHT * 12) - 1);

		if (FlxG.mouse.getPosition().inRect(levelSize))
		{
			highlightBox.x = Math.floor(FlxG.mouse.x / Game.TILE_WIDTH) * Game.TILE_WIDTH;
			highlightBox.y = Math.floor(FlxG.mouse.y / Game.TILE_HEIGHT) * Game.TILE_HEIGHT;
			highlightBox.visible = true;
		}
		else
			highlightBox.visible = false;

		if (FlxG.mouse.pressed && highlightBox.visible)
			levelMap.members[selectedLayer].setTile(mouseX, mouseY, selectedTile);
		if (FlxG.mouse.pressedRight && highlightBox.visible)
			levelMap.members[selectedLayer].setTile(mouseX, mouseY, 0);

		// Ajustes para el "offset"
		if (FlxG.keys.justPressed.RIGHT)
			offsetTiles += Game.MAP_WIDTH;

		if (FlxG.keys.justPressed.LEFT)
			offsetTiles -= Game.MAP_WIDTH;

		if (FlxG.keys.justPressed.UP)
			offsetTilesY += Game.MAP_HEIGHT;

		if (FlxG.keys.justPressed.DOWN)
			offsetTilesY -= Game.MAP_HEIGHT;

		// Zoom
		if (FlxG.keys.justPressed.PAGEUP)
			FlxG.camera.zoom += .25;

		if (FlxG.keys.justPressed.PAGEDOWN)
			FlxG.camera.zoom -= .25;

		// Cambiar "tile" seleccionado
		if (selectedLayer != 2)
		{
			if (FlxG.mouse.wheel < 0 && selectedTile < tileSelectedSprite.animation.frames - 1)
				selectedTile++;

			if (FlxG.mouse.wheel > 0 && selectedTile > 1)
				selectedTile--;
		}

		// Cambiar capa
		if (FlxG.keys.justPressed.ONE)
			selectedLayer = 2;

		if (FlxG.keys.justPressed.TWO)
			selectedLayer = 1;

		if (FlxG.keys.justPressed.THREE)
			selectedLayer = 0;

		// Salir del editor
		if (FlxG.keys.justPressed.ESCAPE && !exited)
		{
			exited = true;
			FlxG.mouse.visible = false;
			FlxG.switchState(new MenuState());
		}

		// Menu Editor
		/*if (FlxG.keys.justPressed.ENTER)
			{
				var subState = new MapEditorSubState(this);
				openSubState(subState);
		}*/

		textPos.text = 'X: $mouseX\nY: $mouseY';
	}

	// FlxState functions!
	override public function create()
	{
		super.create();
		FlxG.mouse.visible = true;
		FlxG.sound.music.stop();
		// persistentUpdate = true;
		// persistentDraw = true;

		// UI stuff
		highlightBorders = new FlxSprite(0, 0);
		highlightBorders.makeGraphic(Game.MAP_WIDTH * 12, Game.MAP_HEIGHT * 12, FlxColor.TRANSPARENT);
		add(highlightBorders);
		FlxSpriteUtil.drawRect(highlightBorders, 0, 0, Game.MAP_WIDTH * 12, Game.MAP_HEIGHT * 12, FlxColor.TRANSPARENT, {color: FlxColor.RED});

		var backgroundBorder = new FlxSprite(0, FlxG.height - 16);
		backgroundBorder.makeGraphic(FlxG.width, 16, 0xFF0163C6);
		add(backgroundBorder);

		tileSelectedSprite = new FlxSprite(2, FlxG.height - 14);
		tileSelectedSprite.loadGraphic(Paths.getImage("tilemaps/grass"), true, 12, 12);
		add(tileSelectedSprite);

		textPos = new FlxBitmapText();
		textPos.setPosition(16, FlxG.height - 14);
		textPos.text = "X: 0\nY: 0";
		add(textPos);

		sprLayer2 = new FlxSprite(FlxG.width - 24, FlxG.height - 25);
		sprLayer2.loadGraphic(Paths.getImage("layer0"), true, 8, 9);
		add(sprLayer2);

		sprLayer1 = new FlxSprite(FlxG.width - 16, FlxG.height - 25);
		sprLayer1.loadGraphic(Paths.getImage("layer1"), true, 8, 9);
		sprLayer1.animation.frameIndex = 1;
		add(sprLayer1);

		sprLayer0 = new FlxSprite(FlxG.width - 8, FlxG.height - 25);
		sprLayer0.loadGraphic(Paths.getImage("layer2"), true, 8, 9);
		sprLayer0.animation.frameIndex = 1;
		add(sprLayer0);

		var mapEditorText = new FlxBitmapText(Fonts.TOY);
		mapEditorText.text = "MAP EDITOR";
		mapEditorText.x = FlxG.width - mapEditorText.width - 2;
		mapEditorText.y = FlxG.height - mapEditorText.height - 2;
		add(mapEditorText);

		// Map stuff
		createMap();

		highlightBox = new FlxSprite(0, 0);
		highlightBox.makeGraphic(Game.TILE_WIDTH, Game.TILE_HEIGHT, 0x99FF0000);
		add(highlightBox);

		// Configurar cámaras
		backgroundBorder.cameras = [uiCamera];
		tileSelectedSprite.cameras = [uiCamera];
		textPos.cameras = [uiCamera];
		sprLayer2.cameras = [uiCamera];
		sprLayer1.cameras = [uiCamera];
		sprLayer0.cameras = [uiCamera];
		mapEditorText.cameras = [uiCamera];

		FlxG.camera.bgColor = FlxColor.BLACK;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		switch (editorState)
		{
			case Tilemap:
				onEditorUpdate();
			case Entity:
			case Menu:
		}
	}
}
