/**
 * Game controller 
 */
// uses SDL
// uses SDL.Video
uses SDLImage
uses Emscripten
uses entitas
uses systems

[Compact, CCode ( /** reference counting */
	ref_function = "game_addRef", 
	unref_function = "game_release"
)]
class Game
	refCount: int = 1
	def addRef() : unowned Game
		GLib.AtomicInt.add (ref refCount, 1)
		return this
	def release() 
		if GLib.AtomicInt.dec_and_test (ref refCount) do this.free ()
	def extern free()
	instance	: static Game
	width		: int
	height		: int
	mark1		: double
	mark2		: double
	delta		: double
	mouseX		: double
	mouseY		: double
	mouseDown	: bool
	running		: bool
	keys		: uint8[256]
	evt			: SDL.Event
	renderer	: unowned SDL.Video.Renderer
	world		: Factory
	sprites		: List of Entity* = new List of Entity*
	font 		: sdx.Font
	fpsSprite	: sdx.Sprite
	fps			: double
	elapsed		: double  = 0
	frames		: int  = 0


	collision	: Collision
	expire		: Expire
	input		: Input
	physics		: Physics
	remove		: Remove
	spawn		: Spawn
	animate		: Animation

	// freq		: double = 1000 //SDL.Timer.get_performance_frequency()
    
	freq		: double = SDL.Timer.get_performance_frequency()

	player : Entity*
	

	construct(width:int, height:int, renderer:SDL.Video.Renderer)//, renderer:SDL.Video.Renderer)
		instance = this
		this.width = width
		this.height = height
		this.renderer = renderer

	def initialize()

		world = new Factory()
		world.setEntityRemovedListener(entityRemoved)
		world.createBackground(this)
		player = world.createPlayer(this)
		for var i=1 to 20 do world.createBullet(this)
		for var i=1 to 15 do world.createEnemy1(this)
		for var i=1 to 10 do world.createEnemy2(this)
		for var i=1 to  5 do world.createEnemy3(this)
		for var i=1 to 10 do world.createExplosion(this)
		for var i=1 to 12 do world.createBang(this)
		for var i=1 to 90 do world.createParticle(this)

		spawn = new Spawn(this, world)
		input = new Input(this, world)
		collision = new Collision(this, world)
		physics = new Physics(this, world)
		expire = new Expire(this, world)
		remove = new Remove(this, world)
		animate = new Animation(this, world)

		world.addSystem(spawn.initialize, spawn.execute)
		world.addSystem(input.initialize, input.execute)
		world.addSystem(collision.initialize, collision.execute)
		world.addSystem(physics.initialize, physics.execute)
		world.addSystem(animate.initialize, animate.execute)
		world.addSystem(expire.initialize, expire.execute)
		world.addSystem(remove.initialize, remove.execute)
		
		world.initialize()
		font = new sdx.Font("assets/fonts/OpenDyslexic-Bold.otf", 24)

			
	def start()
		running = true
		// mark1 = emscripten_get_now()/freq
		mark1 = (double)SDL.Timer.get_performance_counter()/freq

	def processEvents()
		while SDL.Event.poll(out evt) != 0

			case evt.type
				when SDL.EventType.QUIT
					running = false
				when SDL.EventType.KEYDOWN
					keys[evt.key.keysym.sym] = 1
				when SDL.EventType.KEYUP
					keys[evt.key.keysym.sym] = 0
				when SDL.EventType.MOUSEMOTION
					mouseX = evt.motion.x
					mouseY = evt.motion.y
				when SDL.EventType.MOUSEBUTTONDOWN
					mouseDown = true
				when SDL.EventType.MOUSEBUTTONUP
					mouseDown = false


	def update()

		mark2 = (double)SDL.Timer.get_performance_counter()/freq
		// mark2 = emscripten_get_now()/freq
		delta = mark2 - mark1
		mark1 = mark2
		// print "delta %f", delta
		frames++
		elapsed = elapsed + delta
		if elapsed > 1.0
			fps = (int)((double)frames / elapsed)
			elapsed = 0.0
			frames = 0
		
		processEvents()
		world.execute(delta)
		


	def draw()
		renderer.set_draw_color(0, 0, 0xff, 0)
		renderer.clear()
		for sprite in sprites
			if sprite.isActive() do drawEach(sprite)
		drawFps()
		renderer.present()

	def drawFps()
		if fpsSprite != null do fpsSprite = null 
		fpsSprite = new sdx.Sprite(renderer, "%2.2f".printf(fps), font, {0xd7, 0xeb, 0xd7, 0xfa} )
		fpsSprite.centered = false
		fpsSprite.render(renderer, 0, 0)

	def drawEach(e:Entity*):bool
		if e.hasSprite()

			e.bounds.w = (int)((double)e.sprite.width * e.scale.x)
			e.bounds.h = (int)((double)e.sprite.height * e.scale.y)
			if !e.isBackground()
				e.bounds.x = (int)((double)e.position.x - e.bounds.w / 2)
				e.bounds.y = (int)((double)e.position.y - e.bounds.h / 2)
				if e.hasTint()
					e.sprite.sprite.texture.set_color_mod((uint8)e.tint.r, (uint8)e.tint.g, (uint8)e.tint.b)
					e.sprite.sprite.texture.set_alpha_mod((uint8)e.tint.a)
			
			// print "(%d, %d, %d, %d) %s", e.bounds.x, e.bounds.y, e.bounds.w, e.bounds.h, e.name 
			renderer.copy(e.sprite.sprite.texture, null, 
				{ e.bounds.x, e.bounds.y, (uint)e.bounds.w, (uint)e.bounds.h })

		// if e.hasText()
		// 	renderer.copy(e.text.sprite.texture, null, 
		// 		{ (int)e.position.x, (int)e.position.y, e.text.sprite.width, e.text.sprite.height })

		return true

/**
 * add to game.sprites in layer order
 */
def entityAdded(e:Entity*) 
	if !e.hasSprite() do return

	var layer = e.layer.value
	if Game.instance.sprites.length() == 0
		Game.instance.sprites.append(e)

	else
		var i = 0
		for s in Game.instance.sprites
			assert(s != null)
			if layer <= s.layer.value
				Game.instance.sprites.insert(e, i)
				return
			else
				i++
		Game.instance.sprites.append(e)

/**
* remove from game.sprites
*/
def entityRemoved(e:Entity*) 
	Game.instance.sprites.remove(e)

	
