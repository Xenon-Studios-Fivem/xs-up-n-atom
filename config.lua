Config = {}

Config.Job = 'upnatom'
Config.Language = 'no'

Config.Blip = {
    coords = vec3(85.31, 288.74, 110.21),
    sprite = 106,
    color = 2,
    scale = 0.7,
    label = "Up-n-Atom"
}

Config.Locations = {
    Burgers = {
        {
            coords = vec3(94.67, 291.49, 110.21),
            radius = 5.0,
            label = "Burger Stasjon"
        }
    },
    Fries = {
        {
            coords = vec3(92.43, 292.43, 110.21),
            radius = 5.0,
            label = "Fries Stasjon"
        }
    },
    Drinks = {
        {
            coords = vec3(92.63, 286.96, 110.21),
            radius = 5.0,
            label = "Drikke Stasjon"
        }
    },
    Handwash = {
        {
            coords = vec3(95.32, 290.99, 110.21),
            radius = 1.0,
            label = "Håndvask Stasjon"
        }
    },
}

Config.Menu = {
    Burgers = {
        {name = 'classic_burger', label = 'Classic Burger'},
        {name = 'cheese_burger', label = 'Cheese Burger'}
    },
    Drinks = {
        {name = 'cola', label = 'Cola'},
        {name = 'milkshake', label = 'Milkshake'}
    },
    Fries = {
        {name = 'small_fries', label = 'Small Fries'},
        {name = 'large_fries', label = 'Large Fries'}
    }
}

Config.CraftEmotes = {
    Burgers = {
        progressText = "Lager burger",
        emote = "handwash",
        animDict = "mp_arresting",
        animName = "a_uncuff"
    },
    Fries = {
        progressText = "Friterer pommes",
        emote = "chefhat",
        animDict = "amb@prop_human_bbq@male@base",
        animName = "base"
    },
    Drinks = {
        progressText = "Lager drikke",
        emote = "handshake",
        animDict = "mp_ped_interaction",
        animName = "handshake_guy_a"
    }
}

Config.CraftTime = 5000 