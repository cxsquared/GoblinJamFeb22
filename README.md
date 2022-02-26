# Cxsquared's Heaps ECS Starter Kit

A simple [ECS](https://www.wikiwand.com/en/Entity_component_system) and Event system built on top of [Heaps](https://heaps.io/). Mostly built for Game Jams so your millage may vary.

## Entity

Just an Id that has 0 or more components connect to it.

## Components

Data objects that control the state of the game.

## System

An update function that either takes in entities based on a requested set of Components. The components a system looks for are set in the `forComponents` variable.
There are 2 types of Systems: `IPerEntitySystem` which has an update function that takes in 1 entity at a time and `IAllEntitySystem` which has an update function that takes in all entities in the world that have the given components.
It's important to note that an entity must have AllComponents listed in the `forComponents` array to be passed into the system.

## World

The core controller of this ECS system. You'll create all Entities and register all systems with the World object.
You must remember to tick the `world.update(dt:Float)`.

## Events

### IEvent

A blank interface to denote that the given class will be used with the EventBus.

### Event Bus

Controls the distribution of events through the use of it's `subscribe<T:IEvent>(event:Class<T>, callback:(T) -> Void)` and `publish<T:IEvent>(event:T)` functions.

## GameScene

A Heaps object that will act as your levels/screen inside your game. Scenes are controlled inside the Game.hx. You can change a scene by publishing a new `ChangeSceneEvent` on the Global Event Bus.
