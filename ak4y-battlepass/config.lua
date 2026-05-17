-- ak4y dev.

-- IF YOU HAVE ANY PROBLEM OR DO YOU NEED HELP PLS COME TO MY DISCORD SERVER AND CREATE A TICKET

-- I will share updates and bug fixes about the script on my discord server. You can get it from there 

-- https://discord.gg/kWwM3Bx
-- https://discord.gg/kWwM3Bx



-- YOU HAVE TO RESET YOUR SQL WHEN YOU CHANGE TASK OR REWARD FROM CONFIG
-- YOU HAVE TO RESET YOUR SQL WHEN YOU CHANGE TASK OR REWARD FROM CONFIG
-- YOU HAVE TO RESET YOUR SQL WHEN YOU CHANGE TASK OR REWARD FROM CONFIG
-- YOU HAVE TO RESET YOUR SQL WHEN YOU CHANGE TASK OR REWARD FROM CONFIG


AK4Y = {}

AK4Y.Framework = "newEsx" -- esx or newEsx | "errorEsx" if you have error on console type this.
AK4Y.Mysql = "oxmysql" -- Check fxmanifest.lua when you change it! | ghmattimysql / oxmysql / mysql-async
AK4Y.Discord_Webhook = "https://discordapp.com/api/webhooks/1395422004932247652/G8YpQRnze1_6lX3FTv3BNkMEowZLzBHoQcL8d_x3KuMHMY5zBwQ3kj8d0Qe1fx3vrNs1"
AK4Y.UseTebexForPremiumCodes = false
AK4Y.RequiredXpForNextLevel = 5000 
AK4Y.BPEndDate = {day = 1, month = 9, year = 2025} -- Make sure your server is dated correctly
AK4Y.DailyTasksResetPeriod = 1 -- DAY

AK4Y.Language = {
    ["openSpamProtectNotif"] = "You cannot open the menu right now please wait a bit.",
    ["title1"] = "District 10",
    ["title2"] = "PASS",
    ["collectedText"] = "COLLECTED",
    ["dailyText"] = "DAILY",
    ["remainingText"] = "Remaining",
    ["dayText"] = "Day",
    ["accountTypeText"] = "Account Type :",
    ["premiumBuyButtonText"] = "PREMIUM BUY",
    ["redeemInfoText"] = "You can activate it by entering your premium code at the top.",
    ["premiumCodeTitle1"] = "ENTER YOUR",
    ["premiumCodeTitle2"] = "PREMIUM",
    ["premiumCodeTitle3"] = "CODE:",
    ["acceptButtonText"] = "ACCEPT",
    ["premiumTasksText1"] = "STABLE",
    ["premiumTasksText2"] = "Missions",
    ["upgradeAccountCongratTitle"] = "CONGRATULATIONS!",
    ["upgradeAccountText"] = "Your account has been upgraded to PREMIUM",
    ["piece"] = " pc.",
    ["moneySymbol"] = "$",
}

-- STANDART TASKS
AK4Y.BattlePassTasks = {
    {taskId = 1, requiredcount = 10, rewardXP = 1500, taskTitle = "D10s Freshest Citizen", taskDescription = "Change your outfit 10 times."}, -- Done
    {taskId = 2, requiredcount = 5, rewardXP = 2500, taskTitle = "Metal Detecting Masterclass", taskDescription = "Find 5 items from metal detecting."}, -- Done
    {taskId = 3, requiredcount = 1, rewardXP = 1250, taskTitle = "Don't Drop the Soap", taskDescription = "Complete a workout in prison at the gym."}, --  Done 
    {taskId = 4, requiredcount = 1, rewardXP = 3500, taskTitle = "Worlds Best EMS", taskDescription = "Successfully revive a civilian."}, --  Need Done
    {taskId = 5, requiredcount = 1, rewardXP = 3500, taskTitle = "Worlds Best COP", taskDescription = "Successfully arrest a criminal."}, --  Need Done
    {taskId = 6, requiredcount = 20, rewardXP = 400, taskTitle = "D10s Best Diver", taskDescription = "Collect 20 items"},   -- Done
    {taskId = 7, requiredcount = 15, rewardXP = 150, taskTitle = "D10s World Tour", taskDescription = "Buy 5 meals at each food spot."},  --  Done
    {taskId = 8, requiredcount = 10, rewardXP = 450, taskTitle = "D10s Fitness", taskDescription = "Do 10 workouts at the gym."},  --  Done

    -- {taskId = 13, requiredcount = 1, rewardXP = 50, taskTitle = "Business Supporter", taskDescription = "Purchase any meal/drink from a restaurant."}, -- Done

}

-- STABLE TASKS
AK4Y.DailyPremiumTasks = {

}

AK4Y.PrestigeRewards = {
    [1] = { 
        itemLabel = "Money", itemName = "money", type = "item", count = 50000, unique = true, image = "./images/money.png"
    },
    [2] = { 
        itemLabel = "Money", itemName = "money", type = "item", count = 100000, unique = true, image = "./images/money.png"
    },
    [3] = { 
        itemLabel = "", itemName = "money", type = "item", count = 250000, unique = true, image = "./images/exclusiveitem.png"
    },
    [4] = {
        itemLabel = "", itemName = "exclusiveitem", type = "item", count = 1, unique = true, image = "./images/exclusiveitem.png"
    },
    [5] = { 
        itemLabel = "", itemName = "exclusiveitem", type = "item", count = 1, unique = true, image = "./images/exclusiveitem.png"
    },
    [6] = { 
        itemLabel = "", itemName = "exclusiveitem", type = "item", count = 1, unique = true, image = "./images/exclusiveitem.png"
    }
}

-- BATTLE PASS PRIZES
AK4Y.BattlePassItems = {
    { taskId = 1,  requiredLevel = 1,  rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 500,   image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 1000,  image = "./images/money.png"            } } },
    { taskId = 2,  requiredLevel = 2,  rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 550,   image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 1100,  image = "./images/money.png"            } } },
    { taskId = 3,  requiredLevel = 3,  rewards = { standart = { itemLabel = "Shovel",                  itemName = "md_shovel",        type = "item",  count = 1,     image = "./images/md_shovel.png"        }, premium = { itemLabel = "2x Shovel",                itemName = "md_shovel",        type = "item",  count = 2,     image = "./images/md_shovel.png"        } } },
    { taskId = 4,  requiredLevel = 4,  rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 650,   image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 1300,  image = "./images/money.png"            } } },
    { taskId = 5,  requiredLevel = 5,  rewards = { standart = { itemLabel = "20 Iron",                 itemName = "iron",             type = "item",  count = 20,    image = "./images/iron.png"             }, premium = { itemLabel = "40 Iron",                  itemName = "iron",             type = "item",  count = 40,    image = "./images/iron.png"             } } },
    { taskId = 6,  requiredLevel = 6,  rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 750,   image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 1500,  image = "./images/money.png"            } } },
    { taskId = 7,  requiredLevel = 7,  rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 800,   image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 1600,  image = "./images/money.png"            } } },
    { taskId = 8,  requiredLevel = 8,  rewards = { standart = { itemLabel = "Steel",                   itemName = "steel",            type = "item",  count = 20,    image = "./images/steel.png"            }, premium = { itemLabel = "40 Steel",                 itemName = "steel",            type = "item",  count = 40,    image = "./images/steel.png"            } } },
    { taskId = 9,  requiredLevel = 9,  rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 900,   image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 1800,  image = "./images/money.png"            } } },
    { taskId = 10, requiredLevel = 10, rewards = { standart = { itemLabel = "3 Lockpicks",             itemName = "lockpick",         type = "item",  count = 3,     image = "./images/lockpick.png"         }, premium = { itemLabel = "6 Lockpicks",              itemName = "lockpick",         type = "item",  count = 6,     image = "./images/lockpick.png"         } } },

    { taskId = 11, requiredLevel = 11, rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 1000,  image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 2000,  image = "./images/money.png"            } } },
    { taskId = 12, requiredLevel = 12, rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 1500,  image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 3000,  image = "./images/money.png"            } } },
    { taskId = 13, requiredLevel = 13, rewards = { standart = { itemLabel = "Iron",                    itemName = "iron",             type = "item",  count = 5,     image = "./images/iron.png"             }, premium = { itemLabel = "15 Iron",                  itemName = "iron",             type = "item",  count = 15,    image = "./images/iron.png"             } } },
    { taskId = 14, requiredLevel = 14, rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 2000,  image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 4000,  image = "./images/money.png"            } } },
    { taskId = 15, requiredLevel = 15, rewards = { standart = { itemLabel = "5 Scratch off",           itemName = "scratch_card",     type = "item",  count = 5,     image = "./images/scratch_card.png"     }, premium = { itemLabel = "10 Scratch off",            itemName = "scratch_card",     type = "item",  count = 10,    image = "./images/scratch_card.png"     } } },
    { taskId = 16, requiredLevel = 16, rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 2500,  image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 5000,  image = "./images/money.png"            } } },
    { taskId = 17, requiredLevel = 17, rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 2600,  image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 5200,  image = "./images/money.png"            } } },
    { taskId = 18, requiredLevel = 18, rewards = { standart = { itemLabel = "Radio",                   itemName = "radio",            type = "item",  count = 1,     image = "./images/radio.png"            }, premium = { itemLabel = "2x Radio",                 itemName = "radio",            type = "item",  count = 2,     image = "./images/radio.png"            } } },
    { taskId = 19, requiredLevel = 19, rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 2700,  image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 5400,  image = "./images/money.png"            } } },
    { taskId = 20, requiredLevel = 20, rewards = { standart = { itemLabel = "Backpack",                itemName = "backpack",         type = "item",  count = 1,     image = "./images/backpack.png"         }, premium = { itemLabel = "Backpack + Cash",           itemName = "cash",             type = "money", count = 5000,  image = "./images/money.png"            } } },

    { taskId = 21, requiredLevel = 21, rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 2800,  image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 5600,  image = "./images/money.png"            } } },
    { taskId = 22, requiredLevel = 22, rewards = { standart = { itemLabel = "Racing Tablet",           itemName = "racingtablet",     type = "item",  count = 1,     image = "./images/racingtablet.png"     }, premium = { itemLabel = "2x Racing Tablet",          itemName = "racingtablet",     type = "item",  count = 2,     image = "./images/racingtablet.png"     } } },
    { taskId = 23, requiredLevel = 23, rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 2900,  image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 5800,  image = "./images/money.png"            } } },
    { taskId = 24, requiredLevel = 24, rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 3000,  image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 6000,  image = "./images/money.png"            } } },
    { taskId = 25, requiredLevel = 25, rewards = { standart = { itemLabel = "Lockpick",                itemName = "lockpick",         type = "item",  count = 3,     image = "./images/lockpick.png"         }, premium = { itemLabel = "6 Lockpicks",              itemName = "lockpick",         type = "item",  count = 6,     image = "./images/lockpick.png"         } } },
    { taskId = 26, requiredLevel = 26, rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 3100,  image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 6200,  image = "./images/money.png"            } } },
    { taskId = 27, requiredLevel = 27, rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 3200,  image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 6400,  image = "./images/money.png"            } } },
    { taskId = 28, requiredLevel = 28, rewards = { standart = { itemLabel = "2 Burglary Tool",         itemName = "burglarytools",    type = "item",  count = 2,     image = "./images/burglarytools.png"    }, premium = { itemLabel = "4 Burglary Tools",          itemName = "burglarytools",    type = "item",  count = 4,     image = "./images/burglarytools.png"    } } },
    { taskId = 29, requiredLevel = 29, rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 3300,  image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 6600,  image = "./images/money.png"            } } },
    { taskId = 30, requiredLevel = 30, rewards = { standart = { itemLabel = "Racing Tablet",           itemName = "racingtablet",     type = "item",  count = 1,     image = "./images/racingtablet.png"     }, premium = { itemLabel = "2x Racing Tablet",          itemName = "racingtablet",     type = "item",  count = 2,     image = "./images/racingtablet.png"     } } },

    { taskId = 31, requiredLevel = 31, rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 3400,  image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 6800,  image = "./images/money.png"            } } },
    { taskId = 32, requiredLevel = 32, rewards = { standart = { itemLabel = "10 Steel",                itemName = "steel",            type = "item",  count = 10,    image = "./images/steel.png"            }, premium = { itemLabel = "20 Steel",                 itemName = "steel",            type = "item",  count = 20,    image = "./images/steel.png"            } } },
    { taskId = 33, requiredLevel = 33, rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 3500,  image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 7000,  image = "./images/money.png"            } } },
    { taskId = 34, requiredLevel = 34, rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 3600,  image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 7200,  image = "./images/money.png"            } } },
    { taskId = 35, requiredLevel = 35, rewards = { standart = { itemLabel = "Metal Detecting Beacon",  itemName = "blue_metaldetector", type = "item", count = 1,    image = "./images/blue_metaldetector.png" }, premium = { itemLabel = "2x Metal Detecting Beacon", itemName = "blue_metaldetector", type = "item", count = 2,    image = "./images/blue_metaldetector.png" } } },
    { taskId = 36, requiredLevel = 36, rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 3700,  image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 7400,  image = "./images/money.png"            } } },
    { taskId = 37, requiredLevel = 37, rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 3800,  image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 7600,  image = "./images/money.png"            } } },
    { taskId = 38, requiredLevel = 38, rewards = { standart = { itemLabel = "GPS Hacking Device",      itemName = "gpshackingdevice", type = "item",  count = 1,     image = "./images/gpshackingdevice.png" }, premium = { itemLabel = "2x GPS Hacking Device",    itemName = "gpshackingdevice", type = "item",  count = 2,     image = "./images/gpshackingdevice.png" } } },
    { taskId = 39, requiredLevel = 39, rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 3900,  image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 7800,  image = "./images/money.png"            } } },
    { taskId = 40, requiredLevel = 40, rewards = { standart = { itemLabel = "Glass Cutter",            itemName = "glass_cutter",     type = "item",  count = 1,     image = "./images/glass_cutter.png"     }, premium = { itemLabel = "2x Glass Cutter",           itemName = "glass_cutter",     type = "item",  count = 2,     image = "./images/glass_cutter.png"     } } },
    { taskId = 41, requiredLevel = 41, rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 4000,  image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 8000,  image = "./images/money.png"            } } },
    { taskId = 42, requiredLevel = 42, rewards = { standart = { itemLabel = "30 Rubber",               itemName = "rubber",           type = "item",  count = 30,    image = "./images/rubber.png"           }, premium = { itemLabel = "60 Rubber",                itemName = "rubber",           type = "item",  count = 60,    image = "./images/rubber.png"           } } },
    { taskId = 43, requiredLevel = 43, rewards = { standart = { itemLabel = "Thermite",                itemName = "thermite",         type = "item",  count = 1,     image = "./images/thermite.png"         }, premium = { itemLabel = "2x Thermite",              itemName = "thermite",         type = "item",  count = 2,     image = "./images/thermite.png"         } } },
    { taskId = 44, requiredLevel = 44, rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 4100,  image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 8200,  image = "./images/money.png"            } } },
    { taskId = 45, requiredLevel = 45, rewards = { standart = { itemLabel = "Electronic Kit",          itemName = "electronics",      type = "item",  count = 1,     image = "./images/electronics.png"      }, premium = { itemLabel = "2x Electronic Kit",         itemName = "electronics",      type = "item",  count = 2,     image = "./images/electronics.png"      } } },
    { taskId = 46, requiredLevel = 46, rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 4150,  image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 8300,  image = "./images/money.png"            } } },
    { taskId = 47, requiredLevel = 47, rewards = { standart = { itemLabel = "C4 Bomb",                 itemName = "c4_bomb",          type = "item",  count = 1,     image = "./images/c4_bomb.png"          }, premium = { itemLabel = "2x C4 Bomb",               itemName = "c4_bomb",          type = "item",  count = 2,     image = "./images/c4_bomb.png"          } } },
    { taskId = 48, requiredLevel = 48, rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 4200,  image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 8400,  image = "./images/money.png"            } } },
    { taskId = 49, requiredLevel = 49, rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 4250,  image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 8500,  image = "./images/money.png"            } } },
    { taskId = 50, requiredLevel = 50, rewards = { standart = { itemLabel = "Hacking Laptop",          itemName = "hack_laptop",      type = "item",  count = 1,     image = "./images/hack_laptop.png"      }, premium = { itemLabel = "2x Hacking Laptop",         itemName = "hack_laptop",      type = "item",  count = 2,     image = "./images/hack_laptop.png"      } } },
    { taskId = 51, requiredLevel = 51, rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 4300,  image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 8600,  image = "./images/money.png"            } } },
    { taskId = 52, requiredLevel = 52, rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 4500,  image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 9000,  image = "./images/money.png"            } } },
    { taskId = 53, requiredLevel = 53, rewards = { standart = { itemLabel = "Boosting Tablet",         itemName = "boostingtablet",   type = "item",  count = 1,     image = "./images/boostingtablet.png"   }, premium = { itemLabel = "2x Boosting Tablet",        itemName = "boostingtablet",   type = "item",  count = 2,     image = "./images/boostingtablet.png"   } } },
    { taskId = 54, requiredLevel = 54, rewards = { standart = { itemLabel = "Cash Reward",             itemName = "cash",             type = "money", count = 5000,  image = "./images/money.png"            }, premium = { itemLabel = "Cash Reward",              itemName = "cash",             type = "money", count = 10000, image = "./images/money.png"            } } },
    { taskId = 55, requiredLevel = 55, rewards = { standart = { itemLabel = "4 Days of Speed of Light", itemName = "",               type = "",      count = 1,     image = "./images/speedoflight.png"     }, premium = { itemLabel = "Exclusive Item",            itemName = "exclusiveitem",    type = "item",  count = 1,     image = "./images/exclusiveitem.png"    } } },
}
