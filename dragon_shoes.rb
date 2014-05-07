#Attempt at making a ruby GUI for RubiesAndDragons
require './dnd.rb'
#=begin
bob=Entity.new('Bob',11)
joe=Entity.new('Joe',12)
steve=Entity.new('Steve',14)
battle1=Encounter.new([bob, joe, steve])
#=end	

Shoes.app do
	def update_entities
		@entity_buttons = Array.new(@encounter.ret_entity_list.size)
		new_entities = stack do
			(0 .. @encounter.ret_entity_list.size-1).each do |i|
				@entity_buttons[i] = button "#{(@encounter.ret_entity_list[i]).say_name}", :width => 1.0 do
					@body.replace "#{(@encounter.ret_entity_list[i]).say_name} was pressed"
					@selected_entity=@encounter.ret_entity_list[i]
					update_stats
				end
			end
		end
		return new_entities
	end

	def update_stats
		@entity_info.replace strong("#{@selected_entity.say_name}\n"), 
		"HP: #{@selected_entity.say_hp}\n",
		"Bloodied: #{@selected_entity.is_bloodied?}\n",
		"Unconscious: #{@selected_entity.is_unconscious?}\n",
		"Dying: #{@selected_entity.is_dying?}" 
	end
	@selected_entity=nil
	@encounter=battle1
	@entity_buttons=nil
	flow :width => 800, :height => 600 do
		stack :width => 0.4, :height => 1.0 do
			@entity_interface = stack :width => 1.0, :height => 0.7 do
				para strong("Create an Encounter name")		
			end
 			stack :width => 1.0, :height => 0.3 do	
				@entity_info = para strong("No entity selected")
				flow :width => 1.0 do
					button "damage"
					button "heal"
					button "remove"
				end
			end
		end

		@interface = flow :width => 0.6, :height => 0.2 do
			para "Enter encounter name"
			@text_entry = edit_line
			@submit = button "Submit" do
				if(@text_entry.text != '')
					@encounter.set_encounter_name(@text_entry.text)
					@entity_interface.clear do
						@encounter_name = para strong("#{@encounter.ret_encounter_name}"), :width => 1.0
						@entities = update_entities
						button "Add New" do 
							@encounter.add_entity(Entity.new("John", 31))	
							@entities.clear do update_entities end	
						end
					end
				end
			end
		end
		stack :height => 0.8 do
			@body = para "Display goes here"
		end

	end
end
