package business.trevor.crafttweaks;

import business.trevor.crafttweaks.block.ModBlocks;
import business.trevor.crafttweaks.item.ModItems;

import net.minecraftforge.common.MinecraftForge;
import net.minecraftforge.eventbus.api.IEventBus;
import net.minecraftforge.fml.common.Mod;
import net.minecraftforge.fml.javafmlmod.FMLJavaModLoadingContext;

// The value here should match an entry in the META-INF/mods.toml file
@Mod(CraftTweaks.MOD_ID)
public class CraftTweaks
{
    public static final String MOD_ID = "crafttweaks";

    public CraftTweaks()
    {
        IEventBus modEventBus = FMLJavaModLoadingContext.get().getModEventBus();

        ModBlocks.BLOCKS.register(modEventBus);
        ModItems.ITEMS.register(modEventBus);

        MinecraftForge.EVENT_BUS.register(this);
    }
}
