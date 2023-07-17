local aukit = require("aukit")
local austream = shell.resolveProgram("austream")

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
      table.insert(musicList, entry.title)
    end

    -- Variables de contrôle
    local selectedIndex = 1

    -- Fonction pour afficher la liste des musiques
    local function printMusicList()
      term.clear()
      print("Liste des musiques :")
      for i, title in ipairs(musicList) do
        if i == selectedIndex then
          print("> " .. i .. ". " .. title)
        else
          print("  " .. i .. ". " .. title)
        end
      end
    end

    -- Affichage initial de la liste des musiques
    printMusicList()

    -- Boucle principale pour gérer les commandes utilisateur
    while true do
      local _, keyCode = os.pullEvent("key")

      if keyCode == keys.up and selectedIndex > 1 then
        -- Défilement vers le haut
        selectedIndex = selectedIndex - 1
      elseif keyCode == keys.down and selectedIndex < #musicList then
        -- Défilement vers le bas
        selectedIndex = selectedIndex + 1
      elseif keyCode == keys.enter then
        -- Lecture de la musique sélectionnée
        local selectedMusic = playlist[selectedIndex]
        local selectedTitle = selectedMusic.title
        local selectedURL = selectedMusic.link

        -- Affichage du titre de la musique en cours de lecture
        term.clear()
        print("Lecture de la musique : " .. selectedTitle)

        -- Lecture de la musique en utilisant AUStream
        shell.run(austream, selectedURL)

        -- Attente jusqu'à la fin de la musique
        while true do
          local status, result = pcall(aukit.isPlaying)
          if not status or not result then
            break
          end
          sleep(1)
        end

        -- Affichage de la liste des musiques après la fin de la lecture
        printMusicList()
      elseif keyCode == keys.q then
        -- Interruption de l'utilisateur
        break
      end

      -- Affichage mis à jour de la liste des musiques
      printMusicList()
    end
  else
    print("Erreur de parsing du fichier de la liste de lecture.")
  end
else
  print("Erreur lors du téléchargement du fichier de la liste de lecture.")
end
