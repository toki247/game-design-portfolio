// Copyright Epic Games, Inc. All Rights Reserved.

using UnrealBuildTool;

public class BossCombatDemo : ModuleRules
{
	public BossCombatDemo(ReadOnlyTargetRules Target) : base(Target)
	{
		PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;

		PublicDependencyModuleNames.AddRange(new string[] {
			"Core",
			"CoreUObject",
			"Engine",
			"InputCore",
			"EnhancedInput",
			"AIModule",
			"StateTreeModule",
			"GameplayStateTreeModule",
			"UMG",
			"Slate"
		});

		PrivateDependencyModuleNames.AddRange(new string[] { });

		PublicIncludePaths.AddRange(new string[] {
			"BossCombatDemo",
			"BossCombatDemo/Variant_Platforming",
			"BossCombatDemo/Variant_Platforming/Animation",
			"BossCombatDemo/Variant_Combat",
			"BossCombatDemo/Variant_Combat/AI",
			"BossCombatDemo/Variant_Combat/Animation",
			"BossCombatDemo/Variant_Combat/Gameplay",
			"BossCombatDemo/Variant_Combat/Interfaces",
			"BossCombatDemo/Variant_Combat/UI",
			"BossCombatDemo/Variant_SideScrolling",
			"BossCombatDemo/Variant_SideScrolling/AI",
			"BossCombatDemo/Variant_SideScrolling/Gameplay",
			"BossCombatDemo/Variant_SideScrolling/Interfaces",
			"BossCombatDemo/Variant_SideScrolling/UI"
		});

		// Uncomment if you are using Slate UI
		// PrivateDependencyModuleNames.AddRange(new string[] { "Slate", "SlateCore" });

		// Uncomment if you are using online features
		// PrivateDependencyModuleNames.Add("OnlineSubsystem");

		// To include OnlineSubsystemSteam, add it to the plugins section in your uproject file with the Enabled attribute set to true
	}
}
