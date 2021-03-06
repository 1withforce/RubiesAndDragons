#Attempt at making a ruby GUI for RubiesAndDragons
require './dnd.rb'

Shoes.app(title: "Dragon Shoes", width: 800, height: 700, resizable: false) do
	#returns a flow with the add entities form. Only provide true if it is the first time being called (or else formatting gets screwed up)	
	def add_entity_form(init=false)
		#Probably a better way to do this, but it works for now
		if(init) 
			newform = flow :width => 0.75, :height=>0.3 do
				para "Entity Name:\t", :width=>0.3 
				@input_entity_name=edit_line :width => 0.7
				para "Hp:\t\t\t", :width => 0.3  
				@input_entity_hp=edit_line :width => 0.7
				button "Submit" do
					if(@input_entity_name.text != '' and Integer(@input_entity_hp.text) )
						@encounter.add_entity(Entity.new(@input_entity_name.text, Integer(@input_entity_hp.text)))
						@entities.clear do update_entities end
					end 
				end
			end
		else
			newform = flow do
				para "Entity Name:\t", :width=>0.3 
				@input_entity_name=edit_line :width => 0.7
				para "Hp:\t\t\t", :width => 0.3  
				@input_entity_hp=edit_line :width => 0.7
				button "Submit" do
					if(@input_entity_name.text != '' and Integer(@input_entity_hp.text) )
						@encounter.add_entity(Entity.new(@input_entity_name.text, Integer(@input_entity_hp.text)))
						@entities.clear do update_entities end
					end 
				end
			end
		end
		return newform
	end

	def update_entities
		@entity_buttons = Array.new(@encounter.ret_entity_list.size)
		new_entities = stack do
			(0 .. @encounter.ret_entity_list.size-1).each do |i|
				@entity_buttons[i] = button "#{(@encounter.ret_entity_list[i]).say_name}", :width => 1.0 do
					@body.replace "#{(@encounter.ret_entity_list[i]).say_name} Selected"
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
	@encounter=Encounter.new
	@entity_buttons=nil
	flow :width => 800, :height => 600 do
		stack :width => 0.3, :height => 1.0 do
			@entity_interface = stack :width => 1.0, :height => 0.7 do
				para strong("Create an Encounter name")		
			end
 			stack :width => 1.0, :height => 0.3 do	
				@entity_info = para strong("No entity selected")
				flow :width => 1.0 do
					button "damage", :width => (1/3.0) do 
						if(@amount.text != '')
							@encounter.damage_entity(@selected_entity.say_name, Integer(@amount.text),@source.text)
							update_stats
						end
					end
					button "heal", :width => (1/3.0) do
						if(@amount.text != '')
							@encounter.heal_entity(@selected_entity.say_name, Integer(@amount.text),@source.text)
							update_stats
						end
					end
					button "remove", :width => (1/3.0) do 
						@encounter.drop(@selected_entity)
						@entities.clear do update_entities end
					end
					para "Points:\t", :width => 0.5
					@amount=edit_line :width => 0.5
					para "Source:\t", :width => 0.5
					@source=edit_line :width=> 0.5
				end
			end
		end
		@interface = flow :height => 1.0, :width=>0.7 do
			para "Enter encounter name"
			@text_entry = edit_line
			@submit = button "Submit" do
				if(@text_entry.text != '')
					@encounter.set_encounter_name(@text_entry.text)
					@entity_interface.clear do
						@encounter_name = para strong("#{@encounter.ret_encounter_name}"), :width => 1.0
						@entities = update_entities
						button "Clear All" do
							for entity in @encounter.ret_entity_list
								puts entity.say_name
								@encounter.drop(entity)
							end 	
							@entities.clear do update_entities end	
						end
					end
					@interface.clear do
						@flexible_input = add_entity_form(true) 
						stack :width=>0.25, :height=>0.3 do
							button "Add Entity", :width => 1.0 do
								@flexible_input.clear do add_entity_form end 
							end
							button "Rename Encounter", :width => 1.0 do
								@flexible_input.clear do
									para "Enter new encounter name: "
									@change_encounter_name_input = edit_line
									button "submit" do
										if(@change_encounter_name_input.text != '')
											@encounter.set_encounter_name(@change_encounter_name_input.text)	
											@encounter_name.replace strong("#{@encounter.ret_encounter_name}")
										end
									end
								end
							end
							button "View Combat Log", :width => 1.0 do
								@body.replace @selected_entity.view_log
							end
							button "Set initiative", :width => 1.0 do
							end
						end
						flow :width=>1.0, :height=>0.7 do
							@body=para "New Body is here"
						end
					end
				end
			end
			@body=para "Body is here", :width => 1.0
		end
	end
end
