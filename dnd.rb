#Dungeons and dragons health tracking program
class Entity
	#Initialization
	def initialize(name, hp)
		
		@name=name
		@maxhp=hp
		@currenthp=@maxhp
		@unconscious=false
		@dying=false
		@bloodied=false
		@log=Array.new
		@log.push("Started with #{@currenthp}hp")
	end

	#Functions for retrieving values
	def say_name
		return @name
	end
	def say_hp
		return @currenthp
	end
	def is_bloodied?
		return @bloodied
	end
	def is_unconscious?
		return @unconscious
	end
	def is_dying?
		return @dying
	end	

	#Deals damage to Entity. Source is for log.
	def damage(points, source='unknown')
		#Support for Entity argument		
		if(source.kind_of? Entity)
			source=source.say_name
		end
		#Assign 'unknown' to blank source
		if(source =='') 
			source='unknown' 
		end
		#Deal Damage		
		@currenthp -= points
		#Update Status
		if(not @dying and @currenthp < 0)
			puts "#{@name} is dying."
			@dying=true
			@unconscious=true
			@bloodied=true
		
		elsif(not @unconscious and @currenthp == 0)
			puts "#{@name} is unconscious"
			@unconscious=true
			@bloodied=true
		
		elsif(not @bloodied and @currenthp <= @maxhp*0.20)
			puts "#{@name} is bloodied"
			@bloodied=true
		end
		@log.push("Took #{points} damage from #{source}. hp = #{@currenthp}")
	end

	#Heals Entity. Source is for log.
	def heal(points, source='unknown')
		#Support for Entity as source argument		
		if(source.kind_of? Entity)
			source=source.say_name
		end
		#Assign 'unknown' to blank source
		if(source =='') 
			source='unknown' 
		end
		#Do healing
		@currenthp += points
		#Prevent overhealing
		if(@currenthp > @maxhp)
			@currenthp=@maxhp
		end
		#Update status
		if(@bloodied and @currenthp > @maxhp*0.20)
			puts "#{@name} is no longer bloodied."			
			@bloodied=false
			@unconscious=false
			@dying=false
		
		elsif(@unconscious and @currenthp > 0)
			puts "#{@name} is no longer unconscious"
			@unconscious=false
			@dying=false
		
		elsif(@dying and @currenthp == 0)
			puts "#{@name} is no longer dying"
			@dying=false
		end
		@log.push("Got #{points} points of healing from #{source}. hp = #{@currenthp}")
	end

	#Displays combat log
	def view_log()
		log=""
		log += "-------Combat Log for #{@name}-------\n"
		for entry in @log
			log += entry +"\n"
		end
		log += "-----------End of Log-----------"
		return log
	end
		
end

class Encounter
	def initialize(entity_list=Array.new, turn_order=Array.new)
		@encounter_name="Unnamed Encounter"
		@entity_list=entity_list
		@turn_order=turn_order
	end

	#Functions for accessing/changing class variables
	def ret_entity_list
		return @entity_list	
	end
	
	def ret_encounter_name
		return @encounter_name
	end
	
	def set_encounter_name(name)
		@encounter_name=name
	end

	def input_turn_order()
		#Check to see if a turn order is provided
		if(not @entity_list)
			puts "You must have entities before you can make a turn order!"	
			return
		elsif(not @turn_order)
			initiative_rolls=Hash.new
			for entity in @entity_list
				print "Initiative roll for #{entity.say_name}> "
				initiative_rolls[entity] = gets.chomp.to_f
			end
			@turn_order = initiative_rolls.sort_by {|entity, roll| roll}
			@turn_order.reverse!
			resolve_ties!(@turn_order)
		else
			puts "A turn order us already defined. Run reset_turn_order before continuing."
			return
		end
		view_order()
	end

	#To help fix the shortcomings of the input turn order method
	def tweak_turn_order(name, amount)
		@turn_order.each do |slot|
			if slot[0].say_name == name
				slot[1]+=amount
				@turn_order.sort_by!{|k|k[1]}.reverse!
				return
			end
		end
		puts "Could not find '#{name}'."
	end
	
	#called when two rolls are input the same in turn order
	def resolve_ties!(rolls)
		i = 0 
		modifiers=Array.new(rolls.size,0.0)
		while i < rolls.length-1 do
			if rolls[i][1] == rolls[i+1][1]
				prompt="Two initiative rolls are the same!\nWho goes first? #{rolls[i][0].say_name} or #{rolls[i+1][0].say_name}? > "
				response=input(prompt, [ rolls[i][0].say_name, rolls[i+1][0].say_name ])
				if response == rolls[i][0].say_name
					modifiers[i]+=0.1
				elsif response == rolls[i+1][0].say_name
					modifiers[i+1]+=0.1
				else
					puts "Unknown response!"
					break
				end				
			end
			i+=1
		end
		i=0
		while i < rolls.length-1 do
			rolls[i][1]+=modifiers[i]
			i+=1
		end
		@turn_order=rolls.sort_by{|k|k[1]}.reverse!
		i=0
		#Check to make sure there are no other conflicts.
		#if there are, run the program again
		while i < rolls.length-1 do
			if rolls[i][1] == rolls[i+1][1]
				resolve_ties!(@turn_order)
				break
			end
			i+=1
		end 
	end

	#Calls the Entity.damage function on the named entity in the entity list.
	def damage_entity(name, points, source='Unknown')
		if points < 0
			puts "Can't do negative damage. Use heal_entity instead."
			return
		end
		@entity_list.each do |entity|
			if name==entity.say_name
				entity.damage(points, source)
				return
			end	
		end	
		puts "Did not find entity."
	end
	
	#Calls the Entity.heal function on the named entity in the entity list.
	def heal_entity(name, points, source='Unknown')
		if points < 0 
			puts "Can't do negative healing. Use damage_entity instead."
			return
		end
		@entity_list.each do |entity|
			if name==entity.say_name
				entity.heal(points, source)
				return
			end	
		end	
		puts "Did not find entity."
	end

	#Method for getting and checking user input; might move out of class
	def input(prompt, options)
		print prompt
		valid_input=false
		while not valid_input
			response=gets.chomp
			if options.include? response
				valid_input=true
			else
				puts "Invalid response. Please try again."
				print prompt
			end
		end
		return response
	end
						
	
	#Drops entity from initiative ordering and entity list
	def drop(entity)
=begin
		for entry in @turn_order
			if(entry[0]==entity)
				puts "Dropping #{@turn_order.delete(entry)[0].say_name} from turn order"
				puts "Dropping #{@entity_list.delete(entry[0]).say_name} from entity list"
				view_order
				break
			end
		end  
=end
		@entity_list.delete(entity)		
	end
	
	#Displays all entities in the list with hp and status
	def view_entities()
		puts "-------Entities in Encounter-------"
		puts "|\tName\t|\thp\t|\tBloodied?\t|\tUnconscious?\t|\tDying?\t|"
		100.times do print '_' end
		puts
		@entity_list.each do |entity|
			puts "|\t#{entity.say_name}\t|\t#{entity.say_hp}\t|\t#{entity.is_bloodied?}\t\t|\t#{entity.is_unconscious?}\t\t|\t#{entity.is_dying?}\t|"	
		end
	end
			
	#Display turn order.
	def view_order()
		i=1
		puts "\n-------Initiative order-------"
		for entry in @turn_order
			puts "#{i}. #{entry[0].say_name}. #{entry[1]}"
			i+=1
		end
		puts "--------end of order--------\n"
	end
	

	#Adds an entity to the list of entities.
	def add_entity(entity)
		if(not @entity_list)
			@entity_list=Array(1, entity)
		else
			@entity_list.push(entity)
		end	
	end
	
	def reset_turn_order
		@turn_order=nil
	end 
end

#Test
=begin
bob=Entity.new('Bob', 24)
joe=Entity.new('Joe',20)
steve=Entity.new('Steve', 13)
bill=Entity.new('Bill', 11)
battle1=Encounter.new([bob,joe,steve,bill])
battle1.input_turn_order
battle1.tweak_turn_order('Bob', 5)
battle1.drop(joe)
battle1.view_order
battle1.damage_entity('Joe', 18, 'cats')
battle1.view_entities
=end
