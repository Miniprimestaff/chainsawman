local aukit = require("aukit")
local austream = shell.resolveProgram("austream")
local buttonApi = require("button")

-- Téléchargement du fichier de la liste de lecture
local playlistURL = "https://raw.githubusercontent.com/Miniprimestaff/music-cc/main/program/playlist.json"
local response = http.get(playlistURL)
if response then
  local playlistData = response.readAll()
  response.close()

  -- Parsing du fichier JSON de la liste de lecture
  local success, playlist = pcall(textutils.unserializeJSON, playlistData)
  if success and type(playlist) == "table" then
    -- Création de la liste sélectionnable des musiques
    local musicList = {}
    for _, entry in ipairs(playlist) do
      table.insert(musicList, entry)
    end

    -- Création des boutons pour chaque musique
    local buttons = {}
    for i, music in ipairs(musicList) do
      local btn = buttonApi.create(music.title)
      btn:setPos(1, i)
      btn:setSize(10, 1)
      btn:setColor(colors.red)

      -- Callback lorsque le bouton est cliqué
      btn:onClick(function()
        playMusic(music.title, music.link)
      end)

      table.insert(buttons, btn)
    end

    -- Fonction pour lire une musique
    local function playMusic(title, musicURL)
      -- Lecture de la musique en utilisant AUStream
      shell.run(austream, musicURL)
      
      -- Affichage du titre de la musique en cours de lecture
      print("Lecture de la musique : " .. title)
      
      -- Attente jusqu'à la fin de la musique
      while true do
        local status, result = pcall(aukit.isPlaying)
        if not status or not result then
          break
        end
        sleep(1)
      end
    end

    -- Attente de l'événement de clic sur les boutons
    while true do
      local clickedButton = buttonApi.await(buttons)
      
      if clickedButton then
        -- Récupération de la musique associée au bouton cliqué
        local music = musicList[clickedButton:getPos().y]
        playMusic(music.title, music.link)
      end
    end

  else
    print("Erreur de parsing du fichier de la liste de lecture.")
  end
else
  print("Erreur lors du téléchargement du fichier de la liste de lecture.")
end
