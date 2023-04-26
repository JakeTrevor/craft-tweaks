package business.trevor.crafttweaks.block;

import business.trevor.crafttweaks.CraftTweaks;
import business.trevor.crafttweaks.item.ModItems;
import net.minecraft.world.item.BlockItem;
import net.minecraft.world.item.CreativeModeTab;
import net.minecraft.world.item.Item;
import net.minecraft.world.level.block.Block;
import net.minecraftforge.registries.DeferredRegister;
import net.minecraftforge.registries.ForgeRegistries;
import net.minecraftforge.registries.RegistryObject;

import java.util.function.Supplier;

public class ModBlocks {
	public static final DeferredRegister<Block> BLOCKS = DeferredRegister.create(ForgeRegistries.BLOCKS, CraftTweaks.MOD_ID);

	/** utility function to automatically register a block and associated item */
	private static <T extends Block> RegistryObject<T> registerBlock(String name, Supplier<Block> block, CreativeModeTab tab) {
		RegistryObject<T> result = (RegistryObject<T>) BLOCKS.register(name, block);
		ModItems.ITEMS.register(name, () -> new BlockItem(result.get(), new Item.Properties().tab(tab)));
		return result;
	}
}
