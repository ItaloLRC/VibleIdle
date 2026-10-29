--!nonstrict
return {
    -- MEMORY by default: safe to open and test without a cloud API or credentials.
    -- Published games save automatically; local/Studio tests stay isolated.
    STORAGE_MODE = "MEMORY", -- "MEMORY" | "DATASTORE"
    DATASTORE_NAME = "VibeIdle_Profiles_v1_TEST",
    PUBLISHED_STORAGE_MODE = "DATASTORE",
    LIVE_DATASTORE_NAME = "VibeIdle_Profiles_v1",
    LIVE_COMMERCE_RECEIPTS_NAME = "VibeIdle_ReceiptArchive_v1",
    SAVE_INTERVAL = 60,
    LEASE_SECONDS = 180,
    SEND_ANALYTICS = true, -- Native Roblox events, published servers only.
    ANALYTICS_LOGS = true, -- Structured server summaries; no external collector.
    EXPERIMENT_ID = "vibeidle-mvp",
    -- Create products/pass in this published experience; see docs/ROBux_SETUP.md.
    COMMERCE_ENABLED = false,
    COMMERCE_RECEIPTS_NAME = "VibeIdle_ReceiptArchive_v1_TEST",
    COMMERCE_IDS = {money_hour=0,chips_hour=0,agent=0,forever=0},
}
