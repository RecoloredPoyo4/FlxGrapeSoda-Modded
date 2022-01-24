package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxRect;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText;
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
	var editorState:EditorMode = Tilemap;

	var tilemapUI:FlxGroup;
	var entityUI:FlxGroup;
	var menuUI:FlxGroup;

	var uiBorder:FlxSprite;
	var sprLayers:FlxSprite;
	var blackBackground:FlxSprite;

	var levelMap:FlxTypedGroup<FlxTilemap>;
	var highlightBorders:FlxSprite;
	var selectedTile(default, set):Int = 1;
	var selectedLayer(default, set):Int = 2;

	var offsetView(default, set):Int = 0;
	var totalViews:Int = 0;

	var editorText:FlxText;
	var backParallax:BackParallax;
	var entities:FlxGroup;

	var mouseX:Int;
	var mouseY:Int;
	var levelSize:FlxRect;

	// Tilemap
	var highlightBox:FlxSprite;
	var tileSelectedSprite:FlxSprite;
	var textPos:FlxBitmapText;

	// Entities
	var currentEntity:FlxSprite;
	var currentEntityName:FlxText;
	var entityPos:FlxBitmapText;

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

	function set_offsetView(_newOffset)
	{
		if (_newOffset <= totalViews && _newOffset >= 0)
		{
			levelMap.forEach((tilemap) -> tilemap.x = _newOffset * (Game.MAP_WIDTH * Game.TILE_SIZE));
			highlightBorders.x = _newOffset * (Game.MAP_WIDTH * Game.TILE_SIZE);
			return offsetView = _newOffset;
		}
		return offsetView;
	}

	function setLayerTilePreview()
	{
		var path:String = null;

		switch (selectedLayer)
		{
			case 0:
				path = Paths.getImage("tilemaps/backgrass");
				sprLayers.animation.frameIndex = 2;
			case 1:
				path = Paths.getImage("tilemaps/objects");
				sprLayers.animation.frameIndex = 1;
			case 2:
				path = Paths.getImage("tilemaps/grass");
				sprLayers.animation.frameIndex = 0;
		}

		tileSelectedSprite.loadGraphic(path, true, 12, 12);
		tileSelectedSprite.animation.frameIndex = selectedLayer == 2 ? 0 : selectedTile;
	}

	public function createMap()
	{
		var testMap = [for (i in 0...Game.MAP_WIDTH * Game.MAP_HEIGHT) 0];

		if (levelMap != null)
		{
			levelMap.forEach((tilemap) ->
			{
				levelMap.remove(tilemap);
				tilemap.destroy();
			});
			levelMap.clear();
			highlightBorders.makeGraphic(Game.WIDTH, Game.HEIGHT, FlxColor.TRANSPARENT);
			FlxSpriteUtil.drawRect(highlightBorders, 0, 0, Game.WIDTH, Game.HEIGHT, FlxColor.TRANSPARENT, {color: FlxColor.RED});
		}
		else
		{
			levelMap = new FlxTypedGroup<FlxTilemap>();
			add(levelMap);
		}

		var layer2 = new FlxTilemap();
		layer2.loadMapFromArray(testMap, Game.MAP_WIDTH, Game.MAP_HEIGHT, Paths.getImage("tilemaps/backgrass"), Game.TILE_SIZE, Game.TILE_SIZE);
		levelMap.add(layer2);

		var layer1 = new FlxTilemap();
		layer1.loadMapFromArray(testMap, Game.MAP_WIDTH, Game.MAP_HEIGHT, Paths.getImage("tilemaps/objects"), Game.TILE_SIZE, Game.TILE_SIZE);
		levelMap.add(layer1);

		var layer0 = new FlxTilemap();
		layer0.loadMapFromArray(testMap, Game.MAP_WIDTH, Game.MAP_HEIGHT, Paths.getImage("tilemaps/grass"), Game.TILE_SIZE, Game.TILE_SIZE, FULL);
		levelMap.add(layer0);

		offsetView = 0;
	}

	/*
		Tilemap functions
	 */
	function onEditorCreate()
	{
		tileSelectedSprite = new FlxSprite(2, FlxG.height - 14);
		tileSelectedSprite.loadGraphic(Paths.getImage("tilemaps/grass"), true, 12, 12);
		tilemapUI.add(tileSelectedSprite);

		textPos = new FlxBitmapText();
		textPos.setPosition(16, Game.HEIGHT - 14);
		textPos.text = "X: 0\nY: 0";
		tilemapUI.add(textPos);

		// Map stuff
		createMap();

		highlightBox = new FlxSprite(0, 0);
		highlightBox.makeGraphic(Game.TILE_SIZE, Game.TILE_SIZE, 0x99FF0000);
		tilemapUI.add(highlightBox);

		tileSelectedSprite.cameras = [uiCamera];
		textPos.cameras = [uiCamera];

		add(tilemapUI);
	}

	function onEditorUpdate()
	{
		#if desktop
		if (FlxG.mouse.getPosition().inRect(levelSize))
		{
			highlightBox.x = Math.floor(FlxG.mouse.x / Game.TILE_SIZE) * Game.TILE_SIZE;
			highlightBox.y = Math.floor(FlxG.mouse.y / Game.TILE_SIZE) * Game.TILE_SIZE;
			highlightBox.visible = true;
		}
		else
			highlightBox.visible = false;

		if (FlxG.mouse.pressed && highlightBox.visible)
			levelMap.members[selectedLayer].setTile(mouseX, mouseY, selectedTile);
		if (FlxG.mouse.pressedRight && highlightBox.visible)
			levelMap.members[selectedLayer].setTile(mouseX, mouseY, 0);

		if (FlxG.keys.justPressed.NUMPADEIGHT)
			backParallax.y++;

		if (FlxG.keys.justPressed.NUMPADTWO)
			backParallax.y--;

		// Ajustes para el "offset"
		if (FlxG.keys.justPressed.RIGHT)
			offsetView++;

		if (FlxG.keys.justPressed.LEFT)
			offsetView--;

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

		textPos.text = 'X: $mouseX\nY: $mouseY';
		#end
	}

	/*
		Entities functions
	 */
	function onEntityCreate()
	{
		currentEntity = new FlxSprite();
		currentEntity.loadGraphic(Paths.getImage("player/dylan"), true, 13, 20);
		entityUI.add(currentEntity);

		currentEntityName = new FlxText(2, Game.HEIGHT - 18, "PLAYER");
		currentEntityName.setFormat("assets/fonts/Toy.ttf", 16);
		entityUI.add(currentEntityName);

		currentEntityName.cameras = [uiCamera];

		add(entityUI);
	}

	function onEntityUpdate()
	{
		#if desktop
		if (FlxG.mouse.getPosition().inRect(levelSize))
		{
			currentEntity.x = Math.floor(FlxG.mouse.x / Game.TILE_SIZE) * Game.TILE_SIZE;
			currentEntity.y = Math.floor(FlxG.mouse.y / Game.TILE_SIZE) * Game.TILE_SIZE;
		}
		#end
	}

	/*
		FlxState functions
	 */
	override public function create()
	{
		super.create();
		#if desktop
		FlxG.mouse.visible = true;
		#end
		FlxG.sound.music.stop();

		tilemapUI = new FlxGroup();
		entityUI = new FlxGroup();

		backParallax = new BackParallax(Paths.getImage('parallax/mountain'), 65, 0xFF005100, true);
		add(backParallax);

		// UI stuff
		highlightBorders = new FlxSprite(0, 0);
		highlightBorders.makeGraphic(Game.MAP_WIDTH * 12, Game.MAP_HEIGHT * 12, FlxColor.TRANSPARENT);
		add(highlightBorders);
		FlxSpriteUtil.drawRect(highlightBorders, 0, 0, Game.MAP_WIDTH * 12, Game.MAP_HEIGHT * 12, FlxColor.TRANSPARENT, {color: FlxColor.RED});

		uiBorder = new FlxSprite(0, FlxG.height - 16);
		uiBorder.makeGraphic(FlxG.width, 16, 0xFF0163C6);
		add(uiBorder);

		onEditorCreate();
		onEntityCreate();

		sprLayers = new FlxSprite(Game.WIDTH - 40, uiBorder.y - 9);
		sprLayers.loadGraphic(Paths.getImage("layers"), true, 32, 9);
		add(sprLayers);

		editorText = new FlxText(Game.WIDTH - 102, Game.HEIGHT - 18, 100, "LEVEL EDITOR");
		editorText.setFormat("assets/fonts/Toy.ttf", 16, RIGHT);
		add(editorText);

		blackBackground = new FlxSprite();
		blackBackground.makeGraphic(Game.WIDTH, Game.HEIGHT, 0x99000000);
		blackBackground.visible = false;
		add(blackBackground);

		// Configurar cámaras
		uiBorder.cameras = [uiCamera];
		sprLayers.cameras = [uiCamera];
		editorText.cameras = [uiCamera];
		blackBackground.cameras = [uiCamera];

		FlxG.camera.bgColor = FlxColor.BLACK;
		changeState(Tilemap);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		#if desktop
		// Selector y función para colocar y sacar
		mouseX = Std.int(FlxG.mouse.x / Game.TILE_SIZE);
		mouseY = Std.int(FlxG.mouse.y / Game.TILE_SIZE);
		levelSize = new FlxRect(0, 0, (Game.WIDTH * (totalViews + 1)) - 1, Game.HEIGHT - 1);

		switch (editorState)
		{
			case Tilemap:
				onEditorUpdate();
			case Entity:
				onEntityUpdate();
			case Menu:
		}

		if (FlxG.mouse.getPosition().inRect(uiBorder.getHitbox()) || FlxG.mouse.getPosition().inRect(sprLayers.getHitbox()))
		{
			if (uiBorder.alpha > .5)
				uiBorder.alpha = sprLayers.alpha -= .1;
		}
		else
		{
			if (uiBorder.alpha < 1)
				uiBorder.alpha = sprLayers.alpha += .1;
		}

		if (FlxG.keys.justPressed.U)
			uiCamera.visible = !uiCamera.visible;

		if (FlxG.keys.justPressed.E)
			changeState(Entity);

		if (FlxG.keys.justPressed.T)
			changeState(Tilemap);

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.mouse.visible = false;
			FlxG.switchState(new MenuState());
		}
		#end
	}

	function changeState(state:EditorMode)
	{
		switch (state)
		{
			case Tilemap:
				tilemapUI.visible = true;
				entityUI.visible = false;
				setLayerTilePreview();
				editorText.text = "LEVEL EDITOR";
			case Entity:
				tilemapUI.visible = false;
				entityUI.visible = true;
				sprLayers.animation.frameIndex = 3;
				editorText.text = "ENTITY EDITOR";
			case Menu:
		}
		editorState = state;
	}
}
