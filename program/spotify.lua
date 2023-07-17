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

    -- Variable de contrôle pour la pause
    local isPaused = false
    -- Variable pour stocker le titre de la musique en cours de lecture
    local currentTitle = ""

    -- Fonction pour lire une musique
    local function playMusic(title, musicURL)
      -- Lecture de la musique en utilisant AUStream
      shell.run(austream, musicURL)
      
      -- Affichage du titre de la musique en cours de lecture
      currentTitle = title
      print("Lecture de la musique : " .. currentTitle)
      
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
      -- Réinitialisation du titre une fois la musique terminée
      currentTitle = ""
    end

    -- Affichage de la liste des musiques sélectionnables
    print("Liste des musiques :")
    for i, title in ipairs(musicList) do
      print(i .. ". " .. title)
    end

    -- Demande à l'utilisateur de sélectionner une musique
    local selectedMusicIndex = tonumber(read())
    if selectedMusicIndex and selectedMusicIndex >= 1 and selectedMusicIndex <= #musicList then
      local selectedMusic = playlist[selectedMusicIndex]
      local selectedTitle = selectedMusic.title
      local selectedURL = selectedMusic.link
      
      -- Lecture de la musique sélectionnée
      local musicThread = parallel.create(function()
        playMusic(selectedTitle, selectedURL)
      end)

      -- Boucle principale pour gérer les commandes utilisateur
      while true do
        local command = read()
        if command == "pause" then
          -- Mettre en pause la musique
          isPaused = true
          print("Musique en pause.")
        elseif command == "resume" then
          -- Reprendre la lecture de la musique
          isPaused = false
          print("Reprise de la musique.")
        elseif command == "stop" then
          -- Interruption de l'utilisateur
          parallel.waitForAny(musicThread, function() end) -- Attendre la fin de la musique
          break
        elseif command == "nowplaying" then
          -- Afficher le titre de la musique en cours de lecture
          print("En train de jouer : " .. currentTitle)
        else
          print("Commande non valide.")
        end
      end
    else
      print("Index de musique invalide.")
    end
  else
    print("Erreur de parsing du fichier de la liste de lecture.")
  end
else
  print("Erreur lors du téléchargement du fichier de la liste de lecture.")
end
