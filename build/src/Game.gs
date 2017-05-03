/**
 * Game controller 
 */
uses SDL
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
	surface		: unowned Surface
	factory		: Factory
	systems		: Systems
	sprites		: List of Entity* = new List of Entity*

	collision	: Collision
	expire		: Expire
	input		: Input
	physics		: Physics
	remove		: Remove
	spawn		: Spawn

		
	k		   	: int
	t		   	: double
	t1		  	: double = 0.0
	t2		  	: double = 0.0
	t3		  	: double = 0.0

	player : Entity*
	

	construct(width:int, height:int)
		instance = this
		this.width = width
		this.height = height

	def initialize()
		factory = new Factory()
		factory.setEntityRemovedListener(entityRemoved)
		factory.createBackground(0)
		factory.createBackground(1)
		player = factory.createPlayer()
		for var i=1 to 10 do factory.createBullet()
		for var i=1 to 15 do factory.createEnemy1()
		for var i=1 to 10 do factory.createEnemy2()
		for var i=1 to  5 do factory.createEnemy3()
		for var i=1 to 90 do factory.createParticle()
		// systems = new Systems()
		// systems.initialize(this, factory)

		spawn = new Spawn(this, factory)
		input = new Input(this, factory)
		collision = new Collision(this, factory)
		physics = new Physics(this, factory)
		expire = new Expire(this, factory)
		remove = new Remove(this, factory)

		// spawn.initialize()
		// input.initialize() 
		// collision.initialize()
		// physics.initialize()
		// expire.initialize()
		// remove.initialize()

		factory.addSystem(spawn.initialize, spawn.execute)
		factory.addSystem(input.initialize, input.execute)
		factory.addSystem(collision.initialize, collision.execute)
		factory.addSystem(physics.initialize, physics.execute)
		factory.addSystem(expire.initialize, expire.execute)
		factory.addSystem(remove.initialize, remove.execute)
		
		factory.initialize()
			
	def start()
		running = true
		mark1 = emscripten_get_now()/1000

	def processEvents()
		while Event.poll(out evt) != 0

			case evt.type
				when EventType.QUIT
					running = false
				when EventType.KEYDOWN
					keys[evt.key.keysym.sym] = 1
				when EventType.KEYUP
					keys[evt.key.keysym.sym] = 0
				when EventType.MOUSEMOTION
					mouseX = evt.motion.x
					mouseY = evt.motion.y
				when EventType.MOUSEBUTTONDOWN
					mouseDown = true
				when EventType.MOUSEBUTTONUP
					mouseDown = false


	def update()
		mark2 = emscripten_get_now()/1000
		delta = mark2 - mark1
		mark1 = mark2

		processEvents()

		t1 = emscripten_get_now()/1000
		// systems.update(delta)
		factory.execute(delta)
		// spawn.execute(delta)
		// input.execute(delta) 
		// collision.execute(delta)
		// physics.execute(delta)
		// expire.execute(delta)
		// remove.execute(delta)
		t2 = emscripten_get_now()/1000
		t3 = t2 - t1
		t = t + t3
		k += 1
		if k == 1000
			k = 0
			t = t / 1000.0
			print "%f", t
			t = 0


		surface.fill(null, surface.format.map_rgb(255, 0, 0))

		for entity in sprites
			if !entity.isActive() do continue
			if entity.hasIndex()
				var w = (int16)(entity.bounds.w / entity.index.limit)
				var h = (int16)entity.bounds.h
				var x = (int16)0
				var y = (int16)(entity.index.value * w)
				entity.sprite.surface.blit({ x, y, w, h }, surface, 
					{ 	
						(int16)entity.bounds.x, 
						(int16)entity.bounds.y, 
						(int16)w, 
						(int16)h
					})
			else
				entity.sprite.surface.blit(null, surface, 
					{ 	
						(int16)entity.bounds.x, 
						(int16)entity.bounds.y, 
						(int16)entity.bounds.w, 
						(int16)entity.bounds.h
					})


		surface.flip()


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

	