local aukit = require("aukit")
local austream = shell.resolveProgram("austream")

-- Téléchargement du fichier de la liste de lecture
local playlistURL = "https://raw.githubusercontent.com/Dartsgame974/eonmodded/main/musiclist.json"
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
      playMusic(selectedTitle, selectedURL)
    else
      print("Index de musique invalide.")
    end
  else
    print("Erreur de parsing du fichier de la liste de lecture.")
  end
else
  print("Erreur lors du téléchargement du fichier de la liste de lecture.")
end
