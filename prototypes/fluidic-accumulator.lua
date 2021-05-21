function generate_accumulator(entity_name)

    local new_entity_name = "fluidic-"..entity_name
    -- Create the items
    local item = table.deepcopy(data.raw["item"][entity_name])
    override = {
        -- name = "fluidic-accumulator",
        place_result = new_entity_name,
    }
    for k,v in pairs(override) do
        item[k]=v
    end
    data:extend({item})

    -- Recipe
    -- data:extend({util.merge{
    --     data.raw["recipe"]["accumulator"],
    --     {
    --         name = "fluidic-accumulator",
    --         result = "fluidic-accumulator",
    --     }
    -- }})
    -- data.raw["recipe"]["accumulator"].enabled = true

    -- Create the entity
    local circuit_connections = circuit_connector_definitions.create(
        universal_connector_template,
        {
            { variation = 26, main_offset = util.by_pixel(18.5, 19), shadow_offset = util.by_pixel(20.5, 25.5), show_shadow = true },
            { variation = 26, main_offset = util.by_pixel(18.5, 19), shadow_offset = util.by_pixel(20.5, 25.5), show_shadow = true },
            { variation = 26, main_offset = util.by_pixel(18.5, 19), shadow_offset = util.by_pixel(20.5, 25.5), show_shadow = true },
            { variation = 26, main_offset = util.by_pixel(18.5, 19), shadow_offset = util.by_pixel(20.5, 25.5), show_shadow = true },
        }
    )
    local entity = table.deepcopy(data.raw["accumulator"][entity_name])
    local tank = table.deepcopy(data.raw["storage-tank"]["storage-tank"])
    
    local capacity = util.parse_energy(entity.energy_source.buffer_capacity)
    local throughput = math.max(util.parse_energy(entity.energy_source.input_flow_limit),util.parse_energy(entity.energy_source.output_flow_limit))
    throughput = math.max(throughput,1)*200 -- should stop 0 height tank
    local area = capacity/throughput -- 5MJ accumulator / (5kJ/t * 200) = 5 base area 1 height tank
    
    override = {
        name = new_entity_name,
        type = "storage-tank",
        minable = {mining_time = 0.5, result = entity_name},
        next_upgrade = entity.next_upgrade and "fluidic-"..entity.next_upgrade or nil,
        flow_length_in_ticks = 360,
        fluid_box =
        {
            -- Energy Storage = base_area x fluid_unit x 100 = 5000 kJ
            -- So basically it's the contents of 5 poles in a 2x2 area.
            -- Not very efficient, but how vanilla works.
            base_area = area,
            height = throughput/1000000,
            base_level = 1-(throughput/1000000),
            filter = "fluidic-10-kilojoules",      
            pipe_connections =
            {
                {type = "input-output", position = {-1.5, -0.5}, max_underground_distance = 1},
                {type = "input-output", position = {1.5, -0.5}, max_underground_distance = 1},
                {type = "input-output", position = { -0.5, -1.5,}, max_underground_distance = 1},
                {type = "input-output", position = { -0.5, 1.5}, max_underground_distance = 1},
            }
        },
        rotatable = false,
        window_bounding_box = {{-0.2, 0.3}, {-0.4, 0.7}},
        pictures = {
            picture = table.deepcopy(entity.picture),
            fluid_background = table.deepcopy(tank.pictures.fluid_background),
            window_background = table.deepcopy(tank.pictures.window_background),
            flow_sprite = table.deepcopy(tank.pictures.flow_sprite),
            gas_flow = table.deepcopy(tank.pictures.gas_flow),
        },    
        circuit_wire_connection_points = circuit_connections.points,
        circuit_connector_sprites = circuit_connections.sprites,
        circuit_wire_max_distance = default_circuit_wire_max_distance,   
    }
    -- override.pictures.picture.layers[1].filename = "__FluidicPower__/graphics/entities/accumulator/accumulator.png"
    -- override.pictures.picture.layers[1].hr_version.filename = "__FluidicPower__/graphics/entities/accumulator/hr-accumulator.png"
    for k,v in pairs(override) do
        entity[k]=v
    end
    table.insert(entity.flags, "not-rotatable")
    if settings.startup["fluidic-disable-accumulator-alt-info"].value then
        table.insert(entity.flags, "hide-alt-info")
    end
    data:extend({entity})
end

for _,acc in pairs(data.raw.accumulator) do
    generate_accumulator(acc.name)
    acc.next_upgrade = nil
end

-- Fix the satellite recipe to use this mod's accumulator
-- for _, ingredient in pairs(data.raw.recipe["satellite"].ingredients) do
--     if ingredient[1] == "accumulator" then
--         ingredient[1] = "fluidic-accumulator"
--     end
-- end