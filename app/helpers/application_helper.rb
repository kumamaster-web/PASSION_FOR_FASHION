module ApplicationHelper
  COLOR_MAP = {
    # Reds / Pinks
    "red" => "#DC2626", "crimson" => "#DC143C", "scarlet" => "#FF2400",
    "burgundy" => "#800020", "deep burgundy" => "#800020", "wine" => "#722F37",
    "maroon" => "#800000", "rose" => "#FF007F", "dusty rose" => "#DCAE96",
    "blush" => "#DE5D83", "coral" => "#FF7F50", "salmon" => "#FA8072",
    "pink" => "#FFC0CB", "hot pink" => "#FF69B4", "magenta" => "#FF00FF",
    "fuchsia" => "#FF00FF", "raspberry" => "#E30B5C", "ruby" => "#E0115F",
    "cherry" => "#DE3163",

    # Oranges
    "orange" => "#F97316", "burnt orange" => "#CC5500", "tangerine" => "#FF9966",
    "peach" => "#FFCBA4", "apricot" => "#FBCEB1", "amber" => "#FFBF00",
    "rust" => "#B7410E", "terracotta" => "#E2725B", "copper" => "#B87333",

    # Yellows / Golds
    "yellow" => "#FACC15", "mustard" => "#FFDB58", "mustard yellow" => "#FFDB58",
    "gold" => "#FFD700", "golden" => "#FFD700", "champagne" => "#F7E7CE",
    "lemon" => "#FFF44F", "saffron" => "#F4C430", "honey" => "#EB9605",

    # Greens
    "green" => "#22C55E", "olive" => "#808000", "olive green" => "#808000",
    "sage" => "#B2AC88", "sage green" => "#B2AC88", "forest green" => "#228B22",
    "emerald" => "#50C878", "emerald green" => "#50C878", "mint" => "#98FB98",
    "mint green" => "#98FB98", "lime" => "#32CD32", "teal" => "#008080",
    "seafoam" => "#93E9BE", "hunter green" => "#355E3B", "jade" => "#00A86B",
    "moss" => "#8A9A5B", "moss green" => "#8A9A5B", "khaki" => "#C3B091",
    "army green" => "#4B5320", "pine" => "#01796F", "pistachio" => "#93C572",

    # Blues
    "blue" => "#3B82F6", "navy" => "#000080", "navy blue" => "#000080",
    "royal blue" => "#4169E1", "electric blue" => "#7DF9FF", "sky blue" => "#87CEEB",
    "baby blue" => "#89CFF0", "powder blue" => "#B0E0E6", "cobalt" => "#0047AB",
    "cobalt blue" => "#0047AB", "indigo" => "#4B0082", "slate" => "#708090",
    "slate blue" => "#6A5ACD", "steel blue" => "#4682B4", "denim" => "#1560BD",
    "turquoise" => "#40E0D0", "aqua" => "#00FFFF", "cyan" => "#00FFFF",
    "cerulean" => "#007BA7", "sapphire" => "#0F52BA", "periwinkle" => "#CCCCFF",
    "midnight blue" => "#191970",

    # Purples
    "purple" => "#A855F7", "lavender" => "#E6E6FA", "violet" => "#8B00FF",
    "plum" => "#8E4585", "mauve" => "#E0B0FF", "lilac" => "#C8A2C8",
    "eggplant" => "#614051", "amethyst" => "#9966CC", "orchid" => "#DA70D6",
    "deep purple" => "#673AB7", "grape" => "#6F2DA8",

    # Browns / Earthy
    "brown" => "#92400E", "chocolate" => "#7B3F00", "tan" => "#D2B48C",
    "camel" => "#C19A6B", "beige" => "#F5F5DC", "sand" => "#C2B280",
    "taupe" => "#483C32", "sienna" => "#A0522D", "umber" => "#635147",
    "coffee" => "#6F4E37", "espresso" => "#3C1414", "cocoa" => "#D2691E",
    "cinnamon" => "#D2691E", "mahogany" => "#C04000", "chestnut" => "#954535",

    # Neutrals / Greys
    "white" => "#FFFFFF", "off-white" => "#FAF9F6", "cream" => "#FFFDD0",
    "ivory" => "#FFFFF0", "black" => "#000000", "charcoal" => "#36454F",
    "charcoal grey" => "#36454F", "charcoal gray" => "#36454F",
    "grey" => "#9CA3AF", "gray" => "#9CA3AF", "silver" => "#C0C0C0",
    "light grey" => "#D3D3D3", "light gray" => "#D3D3D3",
    "dark grey" => "#505050", "dark gray" => "#505050",
    "stone" => "#928E85", "ash" => "#B2BEB5",
  }.freeze

  def color_name_to_hex(name)
    normalized = name.strip.downcase
    # Exact match first
    return COLOR_MAP[normalized] if COLOR_MAP[normalized]

    # Try partial match (e.g. "deep burgundy" matches "burgundy")
    COLOR_MAP.each do |key, hex|
      return hex if normalized.include?(key) || key.include?(normalized)
    end

    nil # Unknown color - won't render a sphere
  end
end
