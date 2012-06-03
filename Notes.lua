-- High level notes on the code

-- =============== Class Hierarchy =================
-- The first class to know about is Screen. It represents an ipad screen on which we
-- can draw stuff. It's main bit of functionality is that it knows how to handle meshes
-- and z-order of objects within these meshes. The current implementation just keeps a
-- different mesh for each texture in each z-order but obviously could be optimized to
-- for example uses an atlas

-- The various games screens are subclasses of Screen: Level, PackSelect, LevelSelect, 
-- StartScreen, WinScreen. currentScreen is a global variable that corresponds to 
-- the screen that is currently showing

-- Screen subclasses Panel. Panels are simple container objects that hold a bunch of
-- elems and recursively pass on methods to their elements. For example, put a bunch of
-- objects in a panel and by translating the panel you will translate all the elements 
-- as well

-- Panels can also contain other other panels of course. So while screens are panels, many
-- of the objects on a screen are panels themselves. Also note that objects can
-- be added to the screen with add(), which is a panel method, but that doesn't mean that 
-- they will be drawn (say an invisible button). 
-- You could also have objects that are drawn but not added to the screen, for example, a
-- drawing that doesn't respond to any type of event ever doesn't necessarily have to be
-- add()'ed to the screen (but I guess no harm if it was added)

-- The leaves of the panel hierarchy are SpriteObjs. SpriteObjs are first created which
-- just their coordinates but as soon as they are added to a screen with doDraw, they become
-- part of that screen and will contain references to the meshes of that screen. From then on
-- we can set properties of SpriteObjs like position, tint, size and this will automatically
-- get reflected on the screen meshes. Functionality for moving a spriteObj from one screen
-- to another doesn't exist at the moment.

-- Two important subclasses of SpriteObj: Button and ShadowObj
-- Button is a SpriteObj that knows how to handle touches. Touches on a screen (or panels more
-- generally) are passed on to its elems, which can implement the touched method themselves.
-- Buttons do that - its touched metho checks if
-- the touch happened within the boundaries of the button, and forwards the touch to one of
-- its virtual methods: onBegan, onMoving, onEnded.

-- ShadowObj are SpriteObjs which have an internal SpriteObj to represent shadows. It then
-- overwrites all the SpriteObj methods to also apply them to the shadow.
-- The shadowOffset method determines the offset of the shadow relative to the object, given
-- its position. This method can be overwritten if we want to give the impression that the
-- shadow is elsewhere, for example the stage shadow works differently than the startScreen
-- shadow

-- ============= Level configuations ==============
-- The global variables packs and levels specify the parms for each level/pack

-- ============= Stage ==============
-- stages are defined in BaseStage/Stage/Goal and contain things like Piles,Claws,Crate
-- Different types of stage are drawn with different dimensions and sprites, and
-- so we define a config table which contains all the information needed to draw that stage

-- ============= Events ==============
-- Events are bound and triggered using the Events class, which is a static class
-- Note the interaction between the Panel class and Events. When a Panel is bound
-- it calls bindEvents on each of its elems so for each class you have to write 
-- all binding of events into a bindEvents method. This also makes sure that the events
-- are easy to find and are not mixed with the rest of the code
