class Helper
  def self.render_view(filename)
    contents = File.read("views/#{filename}.haml")
    Haml::Engine.new(contents).render
  end

  def self.train_stations
    [
      "Allawah",
      "Arncliffe",
      "Artarmon",
      "Ashfield",
      "Asquith",
      "Auburn",
      "Banksia",
      "Bankstown",
      "Bardwell Park",
      "Beecroft",
      "Belmore",
      "Berala",
      "Berowra",
      "Beverly Hills",
      "Bexley North",
      "Birrong",
      "Blacktown",
      "Bondi Junction",
      "Burwood",
      "Cabramatta",
      "Camellia",
      "Campbelltown",
      "Campsie",
      "Canley Vale",
      "Canterbury",
      "Caringbah",
      "Carlingford",
      "Carlton",
      "Carramar",
      "Casula",
      "Central",
      "Chatswood",
      "Cheltenham",
      "Chester Hill",
      "Circular Quay",
      "Clarendon",
      "Clyde",
      "Como",
      "Concord West",
      "Cronulla",
      "Croydon",
      "Denistone",
      "Domestic",
      "Doonside",
      "Dulwich Hill",
      "Dundas",
      "East Hills",
      "East Richmond",
      "Eastwood",
      "Edgecliff",
      "Edmondson Park",
      "Emu Plains",
      "Engadine",
      "Epping",
      "Erskineville",
      "Fairfield",
      "Flemington",
      "Glenfield",
      "Gordon",
      "Granville",
      "Green Square",
      "Guildford",
      "Gymea",
      "Harris Park",
      "Heathcote",
      "Holsworthy",
      "Homebush",
      "Hornsby",
      "Hurlstone Park",
      "Hurstville",
      "Ingleburn",
      "International",
      "Jannali",
      "Killara",
      "Kings Cross",
      "Kingsgrove",
      "Kingswood",
      "Kirrawee",
      "Kogarah",
      "Lakemba",
      "Leightonfield",
      "Leppington",
      "Leumeah",
      "Lewisham",
      "Lidcombe",
      "Lindfield",
      "Liverpool",
      "Loftus",
      "Macarthur",
      "Macdonaldtown",
      "Macquarie Fields",
      "Macquarie Park",
      "Macquarie University",
      "Marayong",
      "Marrickville",
      "Martin Place",
      "Mascot",
      "Meadowbank",
      "Merrylands",
      "Milsons Point",
      "Minto",
      "Miranda",
      "Mortdale",
      "Mount Colah",
      "Mount Druitt",
      "Mount Kuring-gai",
      "Mulgrave",
      "Museum",
      "Narwee",
      "Newtown",
      "Normanhurst",
      "North Ryde",
      "North Strathfield",
      "North Sydney",
      "Oatley",
      "Olympic Park",
      "Padstow",
      "Panania",
      "Parramatta",
      "Pendle Hill",
      "Pennant Hills",
      "Penrith",
      "Penshurst",
      "Petersham",
      "Punchbowl",
      "Pymble",
      "Quakers Hill",
      "Redfern",
      "Regents Park",
      "Revesby",
      "Rhodes",
      "Richmond",
      "Riverstone",
      "Riverwood",
      "Rockdale",
      "Rooty Hill",
      "Rosehill",
      "Roseville",
      "Rydalmere",
      "Schofields",
      "Sefton",
      "Seven Hills",
      "Stanmore",
      "St James",
      "St Leonards",
      "St Marys",
      "St Peters",
      "Strathfield",
      "Summer Hill",
      "Sutherland",
      "Sydenham",
      "Telopea",
      "Tempe",
      "Thornleigh",
      "Toongabbie",
      "Town Hall",
      "Turramurra",
      "Turrella",
      "Villawood",
      "Vineyard",
      "Wahroonga",
      "Waitara",
      "Warrawee",
      "Warwick Farm",
      "Waterfall",
      "Waverton",
      "Wentworthville",
      "Werrington",
      "Westmead",
      "West Ryde",
      "Wiley Park",
      "Windsor",
      "Wolli Creek",
      "Wollstonecraft",
      "Woolooware",
      "Wynyard",
      "Yagoona",
      "Yennora"
    ]
  end
end
