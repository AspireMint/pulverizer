pulverizer = {
    item = {},
    sfinv_offset = 3.6,
    default_offset = 2,
    enabled = true,
}

pulverizer.after_dig_nodes = {
    ["default:stone"] = "default:cobble",
    ["default:dirt_with_grass"] = "default:dirt",
}

pulverizer.get_addon = function(offset)
    return "image[0.1,"..(offset+0.1)..";0.8,0.8;pulverizer.png]"
        .. "list[detached:survival_pulverizer;main;0,"..offset..";1,1;]"
end

minetest.create_detached_inventory("survival_pulverizer", {
	on_put = function(inv, listname, index, stack, player)
		local size = inv:get_size(listname)
        local list = inv:get_list(listname)
        local itemstack = inv:get_stack(listname, 1)
        pulverizer.item[player:get_player_name()] = itemstack
	end,
    on_take = function(inv, listname, index, stack, player)
        if inv:get_stack(listname, 1):is_empty() then
            pulverizer.item[player:get_player_name()] = nil
        end
    end
}):set_size("main", 1)

if pulverizer.enabled then
    if sfinv.enabled then
        local get_old = sfinv.pages["sfinv:crafting"].get
        sfinv.pages["sfinv:crafting"].get = function(self, player, context)
            return get_old(self, player, context) .. pulverizer.get_addon(pulverizer.sfinv_offset)
        end
    else
        minetest.register_on_joinplayer(function(player)
            local old_formspec = player:get_inventory_formspec()
            player:set_inventory_formspec(old_formspec .. pulverizer.get_addon(pulverizer.default_offset))
        end)
    end
    
    minetest.register_on_dignode(function(pos, oldnode, digger)
        if not digger:is_player() then return end
        
        local unwanted_item = pulverizer.item[digger:get_player_name()]
        if unwanted_item then
            local unwanted_item_name = unwanted_item:get_name()
            if pulverizer.after_dig_nodes[oldnode.name] then
                digger:get_inventory():remove_item("main", {name=pulverizer.after_dig_nodes[oldnode.name], count=1, wear=0, metadata=""})
            elseif unwanted_item_name == oldnode.name then
                digger:get_inventory():remove_item("main", {name=unwanted_item_name, count=1, wear=0, metadata=""})
            end
        end
    end)

    minetest.register_on_leaveplayer(function(player)
        pulverizer.item[player:get_player_name()] = nil
    end)
end
