package business.trevor.crafttweaks.item;

import business.trevor.crafttweaks.CraftTweaks;
import net.minecraft.world.item.CreativeModeTab;
import net.minecraft.world.item.Item;
import net.minecraftforge.registries.DeferredRegister;
import net.minecraftforge.registries.ForgeRegistries;
import net.minecraftforge.registries.RegistryObject;

public class ModItems {
	public static final DeferredRegister<Item> ITEMS = DeferredRegister.create(ForgeRegistries.ITEMS, CraftTweaks.MOD_ID);

	public static final RegistryObject<Item> NETHERSTEEL_PROJECTILE = ITEMS.register("nethersteel_projectile",
			()->new Item(new Item.Properties().tab(CreativeModeTab.TAB_COMBAT))
	);
}
