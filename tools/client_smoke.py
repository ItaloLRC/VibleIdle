"""Bundle real client modules with a small event adapter; not a Roblox engine test."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def bundle(shared_modules):
    chunks = ["local shared = {}\n"]
    for name, relative in shared_modules.items():
        chunks.append(f"shared.{name} = (function()\n{(ROOT / relative).read_text(encoding='utf-8')}\nend)()\n")
    chunks.append("local factories = {}\n")
    parameters = "game, script, require, Enum, UDim2, UDim, Vector2, Color3, Font, Instance, ColorSequence, ColorSequenceKeypoint, os, task, Random, warn"
    for name, relative in {
        "StoreIconCatalog": "src/client/StoreIconCatalog.luau",
        "FeatureIconCatalog": "src/client/FeatureIconCatalog.luau",
        "StoreIcon": "src/client/StoreIcon.luau",
        "DeskTheme": "src/client/DeskTheme.luau",
        "AgentMascot": "src/client/AgentMascot.luau",
        "AgentLab": "src/client/AgentLab.luau",
        "RobuxShop": "src/client/RobuxShop.luau",
        "Onboarding": "src/client/Onboarding.luau",
        "UiMotion": "src/client/UiMotion.luau",
        "CommerceService": "src/server/CommerceService.luau",
        "CollectionStyle": "src/client/CollectionStyle.luau",
        "PrestigePage": "src/client/PrestigePage.luau",
        "PrestigeTransition": "src/client/PrestigeTransition.luau",
        "CardsPage": "src/client/CardsPage.luau",
        "StreakAvatar": "src/client/StreakAvatar.luau",
        "MascotCatalog": "src/client/MascotCatalog.luau",
        "TerminalController": "src/client/TerminalController.luau",
        "TerminalDesk": "src/client/TerminalDesk.luau",
        "PixelWallpaper": "src/client/PixelWallpaper.luau",
        "FloatingWords": "src/client/FloatingWords.luau",
        "SkillFlame": "src/client/SkillFlame.luau",
        "SkillFireCatalog": "src/client/SkillFireCatalog.luau",
        "PixelSkillDial": "src/client/PixelSkillDial.luau",
        "SkillCheckController": "src/client/SkillCheckController.luau",
        "BackdropDancers": "src/client/BackdropDancers.luau",
        "AudioController": "src/client/AudioController.luau",
        "Bootstrap": "src/client/Bootstrap.client.luau",
        "GameService": "src/server/GameService.luau",
        "ServerBootstrap": "src/server/Bootstrap.server.luau",
        "ServerConfig": "src/server/ServerConfig.luau",
        "Telemetry": "src/server/Telemetry.luau",
    }.items():
        chunks.append(f"factories.{name} = function({parameters})\n{(ROOT / relative).read_text(encoding='utf-8')}\nend\n")
    chunks.append("local smoke = (function()\n" + (ROOT / "tests/ClientSmoke.luau").read_text(encoding="utf-8") + "\nend)()\n")
    chunks.append("assert(smoke(factories, shared) >= 107)\n")
    return "".join(chunks)
