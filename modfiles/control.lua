small_pole = require("scripts.fluidic-small-pole")
medium_pole_out = require("scripts.fluidic-medium-pole")

function creation_event (event)
    small_pole.on_entity_created(event)
    medium_pole_out.on_entity_created(event)
    medium_pole_in.on_entity_created(event)
end

script.on_event(defines.events.on_built_entity, creation_event)
script.on_event(defines.events.on_robot_built_entity, creation_event)
script.on_event(defines.events.script_raised_built, creation_event)
script.on_event(defines.events.script_raised_revive, creation_event)

function removal_event (event)
    small_pole.on_entity_removed(event)
    medium_pole_out.on_entity_removed(event)
    medium_pole_in.on_entity_removed(event)
end

script.on_event(defines.events.on_player_mined_entity, removal_event)
script.on_event(defines.events.on_robot_mined_entity, removal_event)
script.on_event(defines.events.on_entity_died, removal_event)
script.on_event(defines.events.script_raised_destroy, removal_event)
