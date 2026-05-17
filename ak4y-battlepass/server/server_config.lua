-- ak4y dev.
-- Server-side configuration

AK4Y.Server = {}

-- Discord webhook logging toggles (uses AK4Y.Discord_Webhook from config.lua)
AK4Y.Server.LogRewardClaims = true   -- log when a player claims a level reward
AK4Y.Server.LogPrestige     = true   -- log when a player prestiges
AK4Y.Server.LogPremiumRedeem = true  -- log when a player redeems a premium code

-- Database table names
AK4Y.Server.TableName      = "ak4y_battlepass"
AK4Y.Server.CodesTableName = "ak4y_battlepass_codes"
