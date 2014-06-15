A Dungeons and Dragons (or any RP game) tool written in ruby
Still very new. There are a lot of additions and modifications to be made.

Planned features:
-initiative/turn order tracker
-modifier stat sheet
-standalone GUI, ie doesn't have to be run with shoes.

VERSION: 0.2

To run the GUI with shoes:
-Get ruby shoes (google it)
-cd into directory containing dnd.rb and dragon_shoes.rb
- ~$ shoes dragon_shoes.rb
-profit

I suggest you run the shoes GUI but it's possible to use dnd.rb from irb.

For Linux:
cd  into the directory with dnd.rb and run ~$  irb -I ./ -r 'dnd.rb'

Then create an encounter and use the class functions accordingly. An example is provided at the end of dnd.rb

For Windows:
Coming eventually

For Apple:
Probably not coming

dragon_shoes.rb:
This is a rudimentary dnd.rb GUI using ruby shoes. As it stands right now, the interface allows you to add entities to the encounter, keeps track of hp and bloodied/unconscious/dying for each entity, and allows entities to be damaged, healed, or removed from the encounter. Also able to generate a combat log to show history of damage and healing.
 
This is my first attempt at making a ruby GUI so beware of messy code.
