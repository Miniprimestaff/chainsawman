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
    local isPaused = false
    local currentMusicTitle = ""

    -- Variables pour le défilement de la liste
    local maxLines = 10 -- Nombre maximal de lignes à afficher
    local startIndex = 1 -- Indice de départ pour afficher les musiques
    local endIndex = math.min(#musicList, startIndex + maxLines - 1) -- Indice de fin pour afficher les musiques

    -- Fonction pour afficher la liste des musiques
    local function printMusicList()
      term.clear()
      print("Liste des musiques :")
      for i = startIndex, endIndex do
        print(i .. ". " .. musicList[i])
      end
    end

    -- Affichage initial de la liste des musiques
    printMusicList()

    -- Boucle pour gérer le défilement de la liste
    while true do
      local command = read()

      if command == "up" then
        -- Défilement vers le haut
        if startIndex > 1 then
          startIndex = startIndex - 1
          endIndex = endIndex - 1
        end
      elseif command == "down" then
        -- Défilement vers le bas
        if endIndex < #musicList then
          startIndex = startIndex + 1
          endIndex = endIndex + 1
        end
      elseif tonumber(command) then
        -- Sélection d'une musique à jouer
        local selectedIndex = tonumber(command)
        if selectedIndex >= startIndex and selectedIndex <= endIndex then
          local selectedMusic = playlist[selectedIndex]
          local selectedTitle = selectedMusic.title
          local selectedURL = selectedMusic.link

          -- Mise à jour du titre de la musique en cours
          currentMusicTitle = selectedTitle
          print("Lecture de la musique : " .. currentMusicTitle)

          -- Lecture de la musique sélectionnée
          shell.run(austream, selectedURL)

          -- Attente jusqu'à la fin de la musique ou interruption de l'utilisateur
          while true do
            if not isPaused then
              local status, result = pcall(aukit.isPlaying)
              if not status or not result then
                break
              end
            end
            sleep(1)
          end
        else
          print("Index de musique invalide.")
        end
      elseif command == "pause" then
        -- Mettre en pause la musique en cours
        isPaused = true
        print("Musique en pause : " .. currentMusicTitle)
      elseif command == "resume" then
        -- Reprendre la lecture de la musique en cours
        isPaused = false
        print("Reprise de la musique : " .. currentMusicTitle)
      elseif command == "stop" then
        -- Interruption de l'utilisateur
        break
      else
        print("Commande non valide.")
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
